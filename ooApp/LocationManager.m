//
//  LocationManager.m
//  Oomami
//
//  Created by Zack on 9/1/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LocationManager.h"
#import "UserObject.h"

NSString *const kDefaultsUserLocationChoice = @"dontTrackLocation";
NSString *const kDefaultsUserLocationLastKnownLatitude = @"lastKnownLocationLat";
NSString *const kDefaultsUserLocationLastKnownLongitude = @"lastKnownLocationLong";

@interface LocationManager ()
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic,assign) CLLocationCoordinate2D currentLocation;
@end

@implementation LocationManager

//------------------------------------------------------------------------------
// Name:    +sharedInstance
// Purpose: Provides the singleton instance.
//------------------------------------------------------------------------------
+ (instancetype) sharedInstance;
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void) dealloc
{
    [self stopTrackingLocation];
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _currentLocation = [[Settings sharedInstance] mostRecentLocation ];
    }
    return self;
}

//------------------------------------------------------------------------------
// Name:    dontTrackLocation
// Purpose: Reads the current user location tracking choice from settings.
//------------------------------------------------------------------------------
- (TrackingChoice) dontTrackLocation;
{
    NSArray* ary= [[Settings sharedInstance] mostRecentChoice: kDefaultsUserLocationChoice];
    if (!ary) {
        NSLog  (@"User has not yet specified whether to track the location.");
        return TRACKING_UNKNOWN;
    }
    
    BOOL dontTrackLocation= ((NSNumber*)ary[1]).boolValue;
    return dontTrackLocation ? TRACKING_NO : TRACKING_YES;
}

//------------------------------------------------------------------------------
// Name:    askUserWhetherToTrack
// Purpose: This is our own routine in addition to the system's pop-up.
//------------------------------------------------------------------------------
- (void) askUserWhetherToTrack
{
    // RULE: Only show the one Apple pop-up.
    
    [self startTrackingLocation];
}

//------------------------------------------------------------------------------
// Name:    setUserLocationTrackingChoice
// Purpose: Writes the current user location tracking choice from settings.
//------------------------------------------------------------------------------
- (void) setUserLocationTrackingChoice:  (TrackingChoice) choice
{
    [[Settings sharedInstance] setMostRecentChoice: kDefaultsUserLocationChoice
                                                to: @[
                                                      [NSDate date],
                                                      [NSNumber numberWithInteger: choice==TRACKING_NO?1:0]
                                                      ]];
    if (choice==TRACKING_YES ) {
        //  start the location manager if not already started.
//        [self currentUserLocation];
    }
}

//------------------------------------------------------------------------------
// Name:    startTrackingLocation
// Purpose: Sets up the location tracking mechanism.
//------------------------------------------------------------------------------
- (void) startTrackingLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ( status==kCLAuthorizationStatusAuthorizedAlways && status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationLocationBecameAvailable object:nil];
        
        [self setUserLocationTrackingChoice: TRACKING_YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationLocationBecameUnavailable object:nil];
        
        [self setUserLocationTrackingChoice: TRACKING_NO ];
    }
}

//------------------------------------------------------------------------------
// Name:    stopTrackingLocation
// Purpose: Shuts down the location tracking mechanism.
//------------------------------------------------------------------------------
- (void) stopTrackingLocation
{
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager= nil;
    }
}

//------------------------------------------------------------------------------
// Name:    currentUserLocation
// Purpose: Returns current location if available.
//------------------------------------------------------------------------------
- (CLLocationCoordinate2D) currentUserLocation
{
    if (TRACKING_NO == [self dontTrackLocation]) {
//        return CLLocationCoordinate2DMake(37.775,-122.4183333); // San Francisco
        return CLLocationCoordinate2DMake(21.3069444,-157.8583333); // Honolulu Hawaii
        
    }
    if (!self.locationManager) {
        [self startTrackingLocation];
        return [[Settings sharedInstance] mostRecentLocation ];
    }

    return self.currentLocation;
}

#pragma mark - Core location delegate

//------------------------------------------------------------------------------
// Name:    locationManagerDidPauseLocationUpdates:
//------------------------------------------------------------------------------
- (void) locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog (@"Location manager updates paused");
}

//------------------------------------------------------------------------------
// Name:    locationManager:didUpdateToLocation:fromLocation:
//------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D coord = newLocation.coordinate;
    
//    float la = coord.latitude;
//    float lo = coord.longitude;
//    NSLog  (@"New location data lat= %g, long= %g",la,lo);
    self.currentLocation= coord;
    
    [[Settings sharedInstance] setMostRecentLocation:coord ];
}

//------------------------------------------------------------------------------
// Name:    locationManager:didFailWithError:
// Purpose:
//------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog (@"Location manager error %@",error.localizedDescription);

}


@end








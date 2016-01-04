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
    static id sharedInstance;
    static dispatch_once_t once=0;
    dispatch_once(&once,
                  ^{
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
        _currentLocation= [[Settings sharedInstance] mostRecentLocation ];
    }
    return self;
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
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationBecameAvailable object:nil];
        
        self.dontTrackLocation=TRACKING_YES;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationBecameUnavailable object:nil];
        self.dontTrackLocation=TRACKING_NO;

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








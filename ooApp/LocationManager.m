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

@interface LocationManager ()
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic,assign) float currentLatitude, currentLongitude;
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

//------------------------------------------------------------------------------
// Name:    dontTrackLocation
// Purpose: Reads the current user location tracking choice from settings.
//------------------------------------------------------------------------------
- (BOOL) dontTrackLocation
{
    NSArray* ary= [[Settings sharedInstance] mostRecentChoice: kDefaultsUserLocationChoice];
    if (!ary) {
        NSLog  (@"User has not yet specified whether to track the location.");
        return NO;
    }
    
    BOOL dontTrackLocation= ((NSNumber*)ary[1]).boolValue;
    return dontTrackLocation;
}

//------------------------------------------------------------------------------
// Name:    setUserLocationTrackingChoice
// Purpose: Writes the current user location tracking choice from settings.
//------------------------------------------------------------------------------
- (void) setUserLocationTrackingChoice:  (BOOL) choice
{
    [[Settings sharedInstance] setMostRecentChoice: kDefaultsUserLocationChoice
                                                to: @[
                                                      [NSDate date],
                                                      [NSNumber numberWithBool: choice]
                                                      ]];
}

//------------------------------------------------------------------------------
// Name:    startTrackingLocation
// Purpose: Sets up the location tracking mechanism.
//------------------------------------------------------------------------------
- (void) startTrackingLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
}

//------------------------------------------------------------------------------
// Name:    currentUserLocation
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
- (CLLocation*) currentUserLocation
{
    if ([self dontTrackLocation]) {
        return nil;
    }
    if  (!self.locationManager) {
        [self startTrackingLocation];
        return nil;
    }

    CLLocation *loc = [[CLLocation alloc] initWithLatitude: self.currentLatitude longitude:self.currentLongitude ];
    return loc;
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
    
    float la = coord.latitude;
    float lo = coord.longitude;
    NSLog  (@"New location data lat= %g, long= %g",la,lo);
    self.currentLatitude= la;
    self.currentLongitude= lo;
}

//------------------------------------------------------------------------------
// Name:    locationManager:didFailWithError:
// Purpose:
//------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog (@"Location manager error");

}


@end








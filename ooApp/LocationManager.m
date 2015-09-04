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
    // RULE:  if the user previously said no, give them the chance to say yes.
    
    if ([self dontTrackLocation] ==TRACKING_YES) {
        return;
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Do you want to have your location tracked?" message:nil
                                                    delegate: self
                                           cancelButtonTitle: @"No" otherButtonTitles: @"Yes", nil ];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 == No, don't track
    
    [self setUserLocationTrackingChoice: 0==buttonIndex ? TRACKING_NO : TRACKING_YES];
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
                                                      [NSNumber numberWithInteger: choice?1:0]
                                                      ]];
    if (choice==TRACKING_YES ) {
        //  start the location manager if not already started.
        [self currentUserLocation];
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
    [_locationManager startUpdatingLocation];
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
        return CLLocationCoordinate2DMake(0,0);
    }
    if (!self.locationManager) {
        [self startTrackingLocation];
        return CLLocationCoordinate2DMake(0,0);
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
    
    float la = coord.latitude;
    float lo = coord.longitude;
    NSLog  (@"New location data lat= %g, long= %g",la,lo);
    self.currentLocation= coord;
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








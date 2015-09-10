//
//  LocationManager.h
//  Oomami
//
//  Created by Zack on 9/1/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Settings.h"

extern NSString *const kDefaultsUserLocationChoice;

extern NSString *const kDefaultsUserLocationLastKnownLatitude;
extern NSString *const kDefaultsUserLocationLastKnownLongitude;

@interface LocationManager : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate>

+ (instancetype) sharedInstance;

- (CLLocationCoordinate2D)currentUserLocation;
- (void)startTrackingLocation;
- (void)stopTrackingLocation;
- (void)askUserWhetherToTrack;

typedef enum : int {
    TRACKING_UNKNOWN=0,
    TRACKING_YES=1,
    TRACKING_NO=2,
} TrackingChoice;

- (TrackingChoice)dontTrackLocation;

@end


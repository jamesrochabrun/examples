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

@interface LocationManager : NSObject <CLLocationManagerDelegate>

+ (instancetype) sharedInstance;

- (CLLocation*) currentUserLocation;
- (void) startTrackingLocation;
- (void) stopTrackingLocation;

- (void) setUserLocationTrackingChoice:  (BOOL) choice;
- (BOOL) dontTrackLocation;

@end


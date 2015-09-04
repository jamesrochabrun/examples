//
//  CacheManager.h
//  Oomami
//
//  Created by Zack on 9/1/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Settings.h"

@interface CacheManager : NSObject

+ (instancetype) sharedInstance;

- (unsigned long) totalAssets;

- (void) addImage:(UIImage*) image withMetadata: (NSDictionary*)metadata;
- (void) addRestaurant: (NSDictionary*)metadata;

- (NSArray*) lookupImagesByRestaurant: (NSString*)identifier;
- (NSArray*) lookupRestaurantsByLocation: (CLLocationCoordinate2D) location  radius: (float) radius;

- (void) removeAll;
- (void) removeImages;
- (void) removeRestaurants;

- (void) saveListings;

- (void) updateImages;
- (void) updateRestaurants;

@end


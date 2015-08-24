//
//  OOAPI.h
//  ooApp
//
//  Created by Anuj Gujar on 8/6/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OONetworkManager.h"
#import "RestaurantObject.h"

//extern NSString *const kKeyName;

@interface OOAPI : NSObject

/* Read */

- (void)getRestaurantsWithIDs:(NSArray *)restaurantIDs success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
- (void)getUsersWithIDs:(NSArray *)userIDs success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
- (void)getDishesWithIDs:(NSArray *)dishIDs success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

/* Create */

- (void)addRestaurant:(RestaurantObject *)restaurant success:(void (^)(NSArray *dishes))success failure:(void (^)(NSError *))failure;

@end

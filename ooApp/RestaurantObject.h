//
//  RestaurantObject.h
//  ooApp
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantObject : NSObject

@property (nonatomic, strong) NSString *restaurantID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSString *cuisine;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *priceRange;

+ (RestaurantObject *)restaurantFromDict:(NSDictionary *)dict;
+ (NSDictionary *)dictFromRestaurant:(RestaurantObject *)restaurant;

@end

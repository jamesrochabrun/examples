//
//  RestaurantObject.m
//  ooApp
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantObject.h"

NSString *const kKeyName = @"name";
NSString *const kKeyRating = @"rating";
NSString *const kKeyImageURL = @"image_url";
NSString *const kKeyLocation = @"location";
NSString *const kKeyLatitude = @"latitude";
NSString *const kKeyLongitude = @"longitude";
NSString *const kKeyPriceRange = @"price_range";

@implementation RestaurantObject

+ (RestaurantObject *)restaurantFromDict:(NSDictionary *)dict {
    RestaurantObject *restaurant =[[RestaurantObject alloc] init];
    restaurant.name = [dict objectForKey:kKeyName];
    restaurant.rating = [dict objectForKey:kKeyRating];
    restaurant.imageURL = [dict objectForKey:kKeyImageURL];
    
    NSDictionary *location = [dict objectForKey:kKeyLocation];
    restaurant.location = CLLocationCoordinate2DMake([[location objectForKey:kKeyLatitude] doubleValue],
                               [[location objectForKey:kKeyLongitude] doubleValue]);
    
    restaurant.priceRange = [dict objectForKey:kKeyPriceRange];
    
    return restaurant;
}

+ (NSDictionary *)dictFromRestaurant:(RestaurantObject *)restaurant {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:restaurant.name forKey:kKeyName];
    [dict setObject:restaurant.rating forKey:kKeyRating];
    [dict setObject:restaurant.imageURL forKey:kKeyImageURL];
    return dict;
}

@end

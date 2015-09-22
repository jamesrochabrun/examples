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
NSString *const kKeyImageRef = @"image_ref";
NSString *const kKeyLatitude = @"latitude";
NSString *const kKeyLongitude = @"longitude";
NSString *const kKeyPriceRange = @"price_range";

@implementation RestaurantObject

+ (RestaurantObject *)restaurantFromDict:(NSDictionary *)dict {
    RestaurantObject *restaurant =[[RestaurantObject alloc] init];
    restaurant.name = [dict objectForKey:kKeyName];
    restaurant.rating = [dict objectForKey:kKeyRating];
    NSArray *imageRefs = [dict objectForKey:kKeyImageRef];
    restaurant.imageRef = (imageRefs && ![imageRefs isKindOfClass:[NSNull class]]) ? [ImageRefObject imageRefFromDict:[imageRefs objectAtIndex:0]] : nil;
    
    id lat= [dict objectForKey:kKeyLatitude];
    id lon= [dict objectForKey:kKeyLongitude];
    if  (lat && lon  && [lat isKindOfClass:[NSNumber class]]  && [lon isKindOfClass:[NSNumber class]]) {
        restaurant.location = CLLocationCoordinate2DMake([lat doubleValue ], [lon doubleValue]);
    } else {
        restaurant.location= CLLocationCoordinate2DMake(0, 0);
    }
    
    restaurant.priceRange = [dict objectForKey:kKeyPriceRange];
    
    return restaurant;
}

+ (NSDictionary *)dictFromRestaurant:(RestaurantObject *)restaurant {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:restaurant.name forKey:kKeyName];
    [dict setObject:restaurant.rating forKey:kKeyRating];
    return dict;
}

@end

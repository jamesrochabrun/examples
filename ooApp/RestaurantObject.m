//
//  RestaurantObject.m
//  ooApp
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantObject.h"

NSString *const kKeyRestaurantGoogleID = @"google_id";
NSString *const kKeyRestaurantRestaurantID = @"restaurant_id";
NSString *const kKeyRestaurantPlaceID = @"place_id";
NSString *const kKeyRestaurantName = @"name";
NSString *const kKeyRestaurantRating = @"rating";
NSString *const kKeyRestaurantImageRef = @"image_ref";
NSString *const kKeyRestaurantLatitude = @"latitude";
NSString *const kKeyRestaurantLongitude = @"longitude";
NSString *const kKeyRestaurantPriceRange = @"price_range";
NSString *const kKeyRestaurantOpenNow = @"open_now";
NSString *const kKeyRestaurantAddress = @"address";
NSString *const kKeyRestaurantPhone = @"phone";
NSString *const kKeyRestaurantWebsite = @"website";
@implementation RestaurantObject

+ (RestaurantObject *)restaurantFromDict:(NSDictionary *)dict {
    NSLog(@"dict=%@", dict);
    RestaurantObject *restaurant =[[RestaurantObject alloc] init];
    restaurant.googleID = [dict objectForKey:kKeyRestaurantGoogleID];
    restaurant.restaurantID = [dict objectForKey:kKeyRestaurantRestaurantID];
    restaurant.name = [dict objectForKey:kKeyRestaurantName];
    restaurant.rating = [dict objectForKey:kKeyRestaurantRating];
    restaurant.website = [dict objectForKey:kKeyRestaurantWebsite];
    restaurant.phone = [dict objectForKey:kKeyRestaurantPhone];
    restaurant.address = [dict objectForKey:kKeyRestaurantAddress];
    restaurant.isOpen = ([[dict objectForKey:kKeyRestaurantOpenNow] isKindOfClass:[NSNull class]]) ? NO : [[dict objectForKey:kKeyRestaurantOpenNow] boolValue];
    NSArray *imageRefs = [dict objectForKey:kKeyRestaurantImageRef];
    restaurant.imageRef = (imageRefs && ![imageRefs isKindOfClass:[NSNull class]]) ? [ImageRefObject imageRefFromDict:[imageRefs objectAtIndex:0]] : nil;
    
    id lat= [dict objectForKey:kKeyRestaurantLatitude];
    id lon= [dict objectForKey:kKeyRestaurantLongitude];
    if  (lat && lon  && [lat isKindOfClass:[NSNumber class]]  && [lon isKindOfClass:[NSNumber class]]) {
        restaurant.location = CLLocationCoordinate2DMake([lat doubleValue ], [lon doubleValue]);
    } else {
        restaurant.location= CLLocationCoordinate2DMake(0, 0);
    }
    
    restaurant.priceRange = [dict objectForKey:kKeyRestaurantPriceRange];
    
    return restaurant;
}

+ (NSDictionary *)dictFromRestaurant:(RestaurantObject *)restaurant {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:restaurant.name forKey:kKeyRestaurantName];
    [dict setObject:restaurant.rating forKey:kKeyRestaurantRating];
    return dict;
}

@end

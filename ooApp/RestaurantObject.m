//
//  RestaurantObject.m
//  ooApp
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantObject.h"
#import "ImageRefObject.h"
#import "MediaItemObject.h"
#import "HoursOpen.h"

NSString *const kKeyRestaurantGoogleID = @"google_id";
NSString *const kKeyRestaurantRestaurantID = @"restaurant_id";
NSString *const kKeyRestaurantPlaceID = @"place_id";
NSString *const kKeyRestaurantName = @"name";
NSString *const kKeyRestaurantRating = @"rating";
NSString *const kKeyRestaurantImageRef = @"image_ref";
NSString *const kKeyRestaurantMediaItems = @"media_items";
NSString *const kKeyRestaurantLatitude = @"latitude";
NSString *const kKeyRestaurantLongitude = @"longitude";
NSString *const kKeyRestaurantPriceRange = @"price_range";
NSString *const kKeyRestaurantOpenNow = @"open_now";
NSString *const kKeyRestaurantAddress = @"address";
NSString *const kKeyRestaurantPhone = @"phone";
NSString *const kKeyRestaurantWebsite = @"website";
NSString *const kKeyRestaurantHours = @"hours";
NSString *const kKeyRestaurantCuisine = @"cuisine";
NSString *const kKeyRestaurantMobileMenuURL = @"mobile_menu_url";

BOOL isRestaurantObject (id  object)
{
    return [ object isKindOfClass:[RestaurantObject  class]];
}

@implementation RestaurantObject

+ (RestaurantObject *)restaurantFromDict:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    //    NSLog(@"dict=%@", dict);
    RestaurantObject *restaurant = [[RestaurantObject alloc] init];
    restaurant.googleID = [dict objectForKey:kKeyRestaurantGoogleID];
    restaurant.placeID = [dict objectForKey:kKeyRestaurantPlaceID];
    restaurant.restaurantID = [[dict objectForKey:kKeyRestaurantRestaurantID] unsignedIntegerValue];
    restaurant.name = [dict objectForKey:kKeyRestaurantName];
    restaurant.rating = [dict objectForKey:kKeyRestaurantRating];
    restaurant.website = [[dict objectForKey:kKeyRestaurantWebsite] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyRestaurantWebsite];
    restaurant.phone = [[dict objectForKey:kKeyRestaurantPhone] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyRestaurantPhone];
    restaurant.address = [[dict objectForKey:kKeyRestaurantAddress] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyRestaurantAddress];
    restaurant.isOpen = ([[dict objectForKey:kKeyRestaurantOpenNow] isKindOfClass:[NSNull class]]) ? NO : [[dict objectForKey:kKeyRestaurantOpenNow] boolValue];
    restaurant.cuisine = [[dict objectForKey:kKeyRestaurantCuisine] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyRestaurantCuisine];
    
    NSArray *imageRefs = [dict objectForKey:kKeyRestaurantImageRef];
    restaurant.imageRefs = [NSMutableArray array];
    if (imageRefs && ![imageRefs isKindOfClass:[NSNull class]] && [imageRefs count]) {
        [imageRefs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[NSNull class]]) {
                ImageRefObject *iro = [ImageRefObject imageRefFromDict:obj];
                [restaurant.imageRefs addObject:iro];
            }
        }];
    }

    NSArray *mediaItems = [dict objectForKey:kKeyRestaurantMediaItems];
    restaurant.mediaItems = [NSMutableArray array];
    if (mediaItems && ![mediaItems isKindOfClass:[NSNull class]] && [mediaItems count]) {
        [mediaItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[NSNull class]]) {
                MediaItemObject *iro = [MediaItemObject mediaItemFromDict:obj];
                [restaurant.mediaItems addObject:iro];
            }
        }];
    }
    
    id lat = [dict objectForKey:kKeyRestaurantLatitude];
    id lon = [dict objectForKey:kKeyRestaurantLongitude];
    if  (lat && lon  && ![lat isKindOfClass:[NSNull class]]  && ![lon isKindOfClass:[NSNull class]]) {
        restaurant.location = CLLocationCoordinate2DMake([lat doubleValue ], [lon doubleValue]);
    } else {
        restaurant.location= CLLocationCoordinate2DMake(0, 0);
    }
    
    restaurant.priceRange = [[dict objectForKey:kKeyRestaurantPriceRange] isKindOfClass:[NSNull class]] ? 0 : [[dict objectForKey:kKeyRestaurantPriceRange] floatValue];
    
    NSDictionary *hours = [dict objectForKey:kKeyRestaurantHours];

    if (![hours isKindOfClass:[NSNull class]] && hours && [hours count]) {
        NSMutableArray *restaurantHours = [NSMutableArray array];
        HoursOpen *ho;
        for (NSDictionary *dict in hours) {
            ho = [HoursOpen hoursOpenFromDict:dict];
            [restaurantHours addObject:ho];
        }
        restaurant.hours = restaurantHours;
    }
    
    restaurant.mobileMenuURL = [[dict objectForKey:kKeyRestaurantMobileMenuURL] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyRestaurantMobileMenuURL];
    
    //*****set the mobile menu url for testing
//    restaurant.mobileMenuURL = @"https://foursquare.com/v/4acab395f964a520d8c220e3/device_menu";
    
    return restaurant;
}

+ (NSDictionary *)dictFromRestaurant:(RestaurantObject *)restaurant {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:restaurant.name forKey:kKeyRestaurantName];
    [dict setObject:restaurant.rating forKey:kKeyRestaurantRating];
    return dict;
}

- (NSString *)priceRangeText {
    NSString *text;
    if (_priceRange >= 4) {
        text = @"$$$$$";
    } else if (_priceRange >= 3) {
        text = @"$$$$";
    } else if (_priceRange >= 2) {
        text = @"$$$";
    } else if (_priceRange >= 1) {
        text = @"$$";
    } else {
        text = @"$";
    }
    return text;
}

- (NSString *)ratingText {
    CGFloat r = [_rating floatValue];
    NSString *text;
    
    if (r == 5) {
        text = [NSString stringWithFormat:@"%@%@%@%@%@", kFontIconWhatsNewFilled, kFontIconWhatsNewFilled, kFontIconWhatsNewFilled, kFontIconWhatsNewFilled, kFontIconWhatsNewFilled];
    } else if (r >= 4) {
        text = [NSString stringWithFormat:@"%@%@%@%@", kFontIconWhatsNewFilled, kFontIconWhatsNewFilled, kFontIconWhatsNewFilled, kFontIconWhatsNewFilled];
    } else if (r >= 3) {
        text = [NSString stringWithFormat:@"%@%@%@", kFontIconWhatsNewFilled, kFontIconWhatsNewFilled, kFontIconWhatsNewFilled];
    } else if (r >= 2) {
        text = [NSString stringWithFormat:@"%@%@", kFontIconWhatsNewFilled, kFontIconWhatsNewFilled];
  
    } else if (r >= 1) {
        text = [NSString stringWithFormat:@"%@", kFontIconWhatsNewFilled];
    } else {
      text=@"";
    }
    
    return text;
}


- (NSUInteger)hash;
{
    return kHashRestaurant + (_restaurantID & 0xffffff);
}

- (BOOL)isEqual: (NSObject*)other
{
    return self.hash == other.hash;
}

@end

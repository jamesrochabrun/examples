//
//  RestaurantObject.m
//  ooApp
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantObject.h"
#import "ImageRefObject.h"
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
NSString *const kKeyRestaurantVoteCount=  @"totalVotes";
NSString *const kKeyRestaurantPermanentlyClosed = @"permanently_closed";
NSString *const kKeyRestaurantStreetNumber = @"street_number";
NSString *const kKeyRestaurantStreet = @"street";
NSString *const kKeyRestaurantCity = @"city";
NSString *const kKeyRestaurantState = @"state";
NSString *const kKeyRestaurantCountry = @"country";
NSString *const kKeyRestaurantStateCode = @"state_code";
NSString *const kKeyRestaurantCountryCode = @"country_code";
NSString *const kKeyRestaurantPostalCode = @"postal_code";


BOOL isRestaurantObject (id  object)
{
    return [ object isKindOfClass:[RestaurantObject  class]];
}

@implementation RestaurantObject

+ (RestaurantObject *)restaurantFromDict:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSLog(@"dict=%@", dict);
    RestaurantObject *restaurant = [[RestaurantObject alloc] init];
    restaurant.googleID = parseStringOrNullFromServer([dict objectForKey:kKeyRestaurantGoogleID]);
    restaurant.placeID = parseStringOrNullFromServer([dict objectForKey:kKeyRestaurantPlaceID]);
    restaurant.restaurantID = parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyRestaurantRestaurantID]);
    restaurant.name = parseStringOrNullFromServer([dict objectForKey:kKeyRestaurantName]);
    restaurant.rating = [[dict objectForKey:kKeyRestaurantRating] isKindOfClass:[NSNull class]] ? 0 : [[dict objectForKey:kKeyRestaurantRating] floatValue];
    restaurant.website = [[dict objectForKey:kKeyRestaurantWebsite] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyRestaurantWebsite];
    restaurant.phone = [[dict objectForKey:kKeyRestaurantPhone] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyRestaurantPhone];
    restaurant.address = [[dict objectForKey:kKeyRestaurantAddress] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyRestaurantAddress];
    
    restaurant.totalVotes = parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyRestaurantVoteCount ]);
    
    id value= [dict objectForKey:kKeyRestaurantOpenNow];
    if (! value || [value isKindOfClass:[NSNull class]] ) {
        restaurant.isOpen = kRestaurantUnknownWhetherOpen;
    } else {
        if  ( [[dict objectForKey:kKeyRestaurantOpenNow] boolValue ]) {
            restaurant.isOpen = kRestaurantOpen;
        } else {
            restaurant.isOpen = kRestaurantClosed;
        }
    }

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
    
    restaurant.permanentlyClosed = parseBoolOrNullFromServer(dict [kKeyRestaurantPermanentlyClosed]);
    restaurant.streetNumber = parseStringOrNullFromServer(dict[kKeyRestaurantStreetNumber]);
    restaurant.street = parseStringOrNullFromServer(dict[kKeyRestaurantStreet]);
    restaurant.city = parseStringOrNullFromServer(dict[kKeyRestaurantCity]);
    restaurant.state = parseStringOrNullFromServer(dict[kKeyRestaurantState]);
    restaurant.country = parseStringOrNullFromServer(dict[kKeyRestaurantCountry]);
    restaurant.stateCode = parseStringOrNullFromServer(dict[kKeyRestaurantStateCode]);
    restaurant.countryCode = parseStringOrNullFromServer(dict[kKeyRestaurantCountryCode]);
    restaurant.postalCode = parseStringOrNullFromServer(dict[kKeyRestaurantPostalCode]);
    
    return restaurant;
}

+ (NSDictionary *)dictFromRestaurant:(RestaurantObject *)restaurant {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:restaurant.name forKey:kKeyRestaurantName];
    return dict;
}

- (NSString *)priceRangeText {
    NSString *text;
    if (_priceRange >= 4) {
        text = @"$$$$";
    } else if (_priceRange >= 3) {
        text = @"$$$";
    } else if (_priceRange >= 2) {
        text = @"$$";
    } else if (_priceRange >= 1) {
        text = @"$";
    } else {
        text = @"";
    }
    return text;
}

- (NSString *)ratingText {
    CGFloat r = _rating;
    NSString *text;
    
    if (r >= 4.5) {
        text = [NSString stringWithFormat:@"A+"];
    } else if (r >= 4) {
        text = [NSString stringWithFormat:@"A"];
    } else if (r >= 3.5) {
        text = [NSString stringWithFormat:@"B+"];
    } else if (r >= 3) {
        text = [NSString stringWithFormat:@"B"];
    } else if (r >= 2) {
        text = [NSString stringWithFormat:@"C"];
    } else if (r >= 1) {
        text = [NSString stringWithFormat:@"D"];
    } else {
      text=@"";
    }
    
    return text;
}

- (NSString *)distanceOrAddressString {
    NSString *s = @"";
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:self.location.latitude longitude:self.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    
//    NSString *distance = (distanceInMeters) ? [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)] : @"";
    
    NSMutableArray *addressComponents = [NSMutableArray array];
    if ([self.city length]) [addressComponents addObject:self.city];
    //if ([self.stateCode length]) [addressComponents addObject:self.stateCode];
    if ([self.countryCode length]) [addressComponents addObject:self.countryCode];
    
    if (distanceInMeters <= 180) {
        s = [NSString stringWithFormat:@"%0.0f ft", metersToFeet(distanceInMeters)];
    } else if (distanceInMeters > 5000 &&
               ([addressComponents count])) {
        s = [addressComponents componentsJoinedByString:@", "];
    } else {
        s = (distanceInMeters) ? [NSString stringWithFormat:@"%0.1f mi", metersToMiles(distanceInMeters)] : @"";
    }
    
    if (!s) {
        NSLog(@"*** No valid distanceOrAddressString for: %@", self.name);
        s = @"";
    }
    
    return s;
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

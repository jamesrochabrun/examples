//
//  RestaurantObject.h
//  ooApp
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MediaItemObject.h"

extern NSString *const kKeyRestaurantGoogleID;
extern NSString *const kKeyRestaurantRestaurantID;
extern NSString *const kKeyRestaurantPlaceID;
extern NSString *const kKeyRestaurantName;
extern NSString *const kKeyRestaurantRating;
extern NSString *const kKeyRestaurantImageRef;
extern NSString *const kKeyRestaurantMediaItems;
extern NSString *const kKeyRestaurantLatitude;
extern NSString *const kKeyRestaurantLongitude;
extern NSString *const kKeyRestaurantPriceRange;
extern NSString *const kKeyRestaurantOpenNow;
extern NSString *const kKeyRestaurantAddress;
extern NSString *const kKeyRestaurantPhone;
extern NSString *const kKeyRestaurantWebsite;
extern NSString *const kKeyRestaurantHours;
extern NSString *const kKeyRestaurantCuisine;
extern NSString *const kKeyRestaurantMobileMenuURL;
extern NSString *const kKeyRestaurantPermanentlyClosed;
extern NSString *const kKeyRestaurantStreetNumber;
extern NSString *const kKeyRestaurantStreet;
extern NSString *const kKeyRestaurantCity;
extern NSString *const kKeyRestaurantState;
extern NSString *const kKeyRestaurantCountry;
extern NSString *const kKeyRestaurantStateCode;
extern NSString *const kKeyRestaurantCountryCode;
extern NSString *const kKeyRestaurantPostalCode;

typedef enum {
    kRestaurantSourceTypeOomami = 1,
    kRestaurantSourceTypeGoogle = 2
} RestaurantSourceType;

typedef enum: char {
    kRestaurantOpen=1,
    kRestaurantClosed=2,
    kRestaurantUnknownWhetherOpen=3,
} RestaurantOpenStatus;

@interface RestaurantObject : NSObject

@property (nonatomic) NSUInteger restaurantID;
@property (nonatomic, strong) NSString *googleID;
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) RestaurantOpenStatus isOpen;
@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, strong) NSMutableArray *imageRefs;
@property (nonatomic, strong) NSMutableArray *mediaItems;
@property (nonatomic, strong) NSString *cuisine;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) CGFloat priceRange;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *streetNumber;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *stateCode;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSArray *hours;
@property (nonatomic, strong) NSString *mobileMenuURL;
@property (nonatomic, assign) NSInteger totalVotes;// tally of all vote values
@property (nonatomic) BOOL permanentlyClosed;

+ (RestaurantObject *)restaurantFromDict:(NSDictionary *)dict;
+ (NSDictionary *)dictFromRestaurant:(RestaurantObject *)restaurant;
- (NSString *)priceRangeText;
- (NSString *)ratingText;
- (MediaItemObject *)getUserContextMediaItem:(NSUInteger)userID;
- (NSString *)distanceOrAddressString;

@end

extern BOOL isRestaurantObject (id  object);

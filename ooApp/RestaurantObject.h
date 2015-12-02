//
//  RestaurantObject.h
//  ooApp
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

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

typedef enum {
    kRestaurantSourceTypeGoogle = 2
} RestaurantSourceType;

@interface RestaurantObject : NSObject

@property (nonatomic) NSUInteger restaurantID;
@property (nonatomic, strong) NSString *googleID;
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL isOpen;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSMutableArray *imageRefs;
@property (nonatomic, strong) NSMutableArray *mediaItems;
@property (nonatomic, strong) NSString *cuisine;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) CGFloat priceRange;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSArray *hours;
@property (nonatomic, strong) NSString *mobileMenuURL;
@property (nonatomic, assign) NSInteger totalVotes;// tally of all vote values

+ (RestaurantObject *)restaurantFromDict:(NSDictionary *)dict;
+ (NSDictionary *)dictFromRestaurant:(RestaurantObject *)restaurant;
- (NSString *)priceRangeText;
- (NSString *)ratingText;

@end

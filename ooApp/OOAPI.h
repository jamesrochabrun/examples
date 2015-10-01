//
//  OOAPI.h
//  ooApp
//
//  Created by Anuj Gujar on 8/6/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OONetworkManager.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "ImageRefObject.h"
#import "UIImageView+AFNetworking.h"

//extern NSString *const kKeyName;

static const int kOOAPIListTypeFavorites = 0;
static const int kOOAPIListTypeSystem = 1;
static const int kOOAPIListTypeUser = 2;

@interface OOAPI : NSObject

/* Read */

//Restaurants
- (AFHTTPRequestOperation *)getRestaurantsWithIDs:(NSArray *)restaurantIDs
                                          success:(void (^)(NSArray *))success
                                          failure:(void (^)(NSError *))failure;
- (AFHTTPRequestOperation *)getRestaurantWithID:(NSString *)restaurantId source:(NSUInteger)source
                                         success:(void (^)(RestaurantObject *restaurants))success
                                         failure:(void (^)(NSError *))failure;
- (AFHTTPRequestOperation *)getRestaurantsWithKeyword:(NSString *)keyword
                                          andLocation:(CLLocationCoordinate2D)location
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(NSError *))failure;
- (AFHTTPRequestOperation *)getRestaurantImageWithImageRef:(ImageRefObject *)imageRef
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *imageRefs))success
                                                   failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getUsersWithIDs:(NSArray *)userIDs
                                    success:(void (^)(NSArray *))success
                                    failure:(void (^)(NSError *))failure;
- (AFHTTPRequestOperation *)getDishesWithIDs:(NSArray *)dishIDs
                                     success:(void (^)(NSArray *))success
                                     failure:(void (^)(NSError *))failure;

//- (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
//                                   toList: (NSInteger) listIdentifier
//                            success:(void (^)(NSArray *dishes))success
//                            failure:(void (^)(NSError *))failure;

// Lists
//
- (AFHTTPRequestOperation *)addList:(NSString *)listName
                                  success:(void (^)(id response))success
                                  failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getListsOfUser:(NSInteger)userID withRestaurant:(NSUInteger)restaurantID
                                  success:(void (^)(NSArray *lists))success
                                  failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getRestaurantsWithListID:(NSUInteger)listID
                                            success:(void (^)(NSArray *restaurants))success
                                            failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)addRestaurantsToFavorites:(NSArray *)restaurants
                                              success:(void (^)(id response))success
                                              failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation*)deleteRestaurant:(NSUInteger)restaurantID fromList:(NSUInteger)listID
                                    success:(void (^)(NSArray *lists))success
                                    failure:(void (^)(NSError *))failure;

/* Create */
- (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
                                  success:(void (^)(NSArray *dishes))success
                                  failure:(void (^)(NSError *))failure;

// Users
//
+ (AFHTTPRequestOperation *)lookupUsername:(NSString *)string
                                  success:(void (^)(NSArray *users))success
                                  failure:(void (^)(NSError *))failure;

+ (AFHTTPRequestOperation *)fetchSampleUsernamesFor:(NSString *)emailAddressString
                                           success:(void (^)(NSArray *names))success
                                           failure:(void (^)(NSError *))failure;

+ (AFHTTPRequestOperation*)clearUsernameWithSuccess:(void (^)(NSArray *names))success
                                            failure:(void (^)(NSError *))failure;
@end

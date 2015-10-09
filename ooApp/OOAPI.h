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
#import "MediaItemObject.h"
#import "UIImageView+AFNetworking.h"
#import "EventObject.h"

//extern NSString *const kKeyName;

typedef enum {
    kSearchSortTypeBestMatch = 0,
    kSearchSortTypeDistance = 1,
    kSearchSortTypeHighestRated = 2,
} SearchSortType;

static const int kOOAPIListTypeFavorites = 0;
static const int kOOAPIListTypeSystem = 1;
static const int kOOAPIListTypeUser = 2;

static NSString* const kPhotoUploadPath=  @"/users/picture";

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
                                           andOpenOnly:(BOOL)openOnly
                                                 andSort:(SearchSortType)sort
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getRestaurantsWithKeyword:(NSString *)keyword
                                            andFilter: (NSString*)filterName
                                          andLocation:(CLLocationCoordinate2D)location
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getRestaurantImageWithImageRef:(NSString *)imageRef
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *imageRefs))success
                                                   failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)deleteRestaurant:(NSUInteger)restaurantID fromList:(NSUInteger)listID
                                     success:(void (^)(NSArray *lists))success
                                     failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
                                  success:(void (^)(NSArray *dishes))success
                                  failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getDishesWithIDs:(NSArray *)dishIDs
                                     success:(void (^)(NSArray *))success
                                     failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants toList:(NSUInteger)listId
                                   success:(void (^)(id response))success
                                   failure:(void (^)(NSError *))failure;
// Lists
//
- (AFHTTPRequestOperation *)addList:(NSString *)listName
                                  success:(void (^)(id response))success
                                  failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getListsOfUser:(NSUInteger)userID withRestaurant:(NSUInteger)restaurantID
                                  success:(void (^)(NSArray *lists))success
                                  failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getRestaurantsWithListID:(NSUInteger)listID
                                            success:(void (^)(NSArray *restaurants))success
                                            failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getMediaItemsForRestaurant:(RestaurantObject *)restaurant
                                               success:(void (^)(NSArray *mediaItems))success
                                               failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)addRestaurantsToFavorites:(NSArray *)restaurants
                                              success:(void (^)(id response))success
                                              failure:(void (^)(NSError *))failure;


// Users
//
+ (AFHTTPRequestOperation *)getUserImageWithImageID:(NSString *)identifier
                                           maxWidth:(NSUInteger)maxWidth
                                          maxHeight:(NSUInteger)maxHeight
                                            success:(void (^)(NSString *imageRefs))success
                                            failure:(void (^)(NSError *))failure;

- (AFHTTPRequestOperation *)getUsersWithIDs:(NSArray *)userIDs
                                    success:(void (^)(NSArray *))success
                                    failure:(void (^)(NSError *))failure;
+ (AFHTTPRequestOperation *)getUsersWithKeyword:(NSString *)keyword
                                        success:(void (^)(NSArray *restaurants))success
                                        failure:(void (^)(NSError *))failure;

+ (void)uploadUserPhoto:(UIImage *)image
                success:(void (^)(void))success
                failure:(void (^)(NSError *))failure;

+ (AFHTTPRequestOperation *)lookupUsername:(NSString *)string
                                   success:(void (^)(NSArray *users))success
                                   failure:(void (^)(NSError *))failure;

+ (AFHTTPRequestOperation *)fetchSampleUsernamesFor:(NSString *)emailAddressString
                                            success:(void (^)(NSArray *names))success
                                            failure:(void (^)(NSError *))failure;

+ (AFHTTPRequestOperation*)clearUsernameWithSuccess:(void (^)(NSArray *names))success
                                            failure:(void (^)(NSError *))failure;

// Events
//

+ (AFHTTPRequestOperation *)addRestaurant: (NSString*)restaurantID
                                  toEvent:(EventObject *)event
                                  success:(void (^)(id response))success
                                  failure:(void (^)(NSError *))failure;

+ (AFHTTPRequestOperation *)setParticipationInEvent:(EventObject* ) eo
                                                 to: (BOOL) participating
                                            success:(void (^)(NSInteger eventID))success
                                            failure:(void (^)(NSError *))failure;

+ (AFHTTPRequestOperation *)addEvent:(EventObject* ) eo
                                     success:(void (^)(NSInteger eventID))success
                                     failure:(void (^)(NSError *))failure;

+ (AFHTTPRequestOperation *)reviseEvent:(EventObject* ) eo
                                success:(void (^)(id))success
                                failure:(void (^)(NSError *))failure;

+ (AFHTTPRequestOperation *)getEventsForUser:(NSUInteger ) identifier
                                     success:(void (^)(NSArray *events))success
                                     failure:(void (^)(NSError *))failure;
+ (AFHTTPRequestOperation *)getCuratedEventsWithSuccess:(void (^)(NSArray *events))success
                                     failure:(void (^)(NSError *))failure;
@end

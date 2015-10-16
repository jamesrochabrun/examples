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
#import "UserObject.h"

//extern NSString *const kKeyName;

typedef enum {
    kSearchSortTypeBestMatch = 0,
    kSearchSortTypeDistance = 1,
    kSearchSortTypeHighestRated = 2,
} SearchSortType;

static NSString* const kPhotoUploadPath=  @"/users/picture";

@interface OOAPI : NSObject

//------------------------------------------------------------------------------
// Restaurants

- (AFHTTPRequestOperation *)getRestaurantsWithIDs:(NSArray *)restaurantIDs
                                          success:(void (^)(NSArray *restaurants))success
                                          failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantWithID:(NSString *)restaurantId source:(NSUInteger)source
                                         success:(void (^)(RestaurantObject *restaurants))success
                                         failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantsWithKeyword:(NSString *)keyword
                                          andLocation:(CLLocationCoordinate2D)location
                                            andFilter:(NSString *)filterName
                                          andOpenOnly:(BOOL)openOnly
                                                 andSort:(SearchSortType)sort
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantImageWithImageRef:(NSString *)imageRef
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *imageRefs))success
                                                   failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)deleteRestaurant:(NSUInteger)restaurantID fromList:(NSUInteger)listID
                                     success:(void (^)(NSArray *lists))success
                                     failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
                                  success:(void (^)(NSArray *dishes))success
                                  failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)getDishesWithIDs:(NSArray *)dishIDs
                                     success:(void (^)(NSArray *dishes))success
                                     failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants toList:(NSUInteger)listId
                                   success:(void (^)(id response))success
                                   failure:(void (^)(NSError *error))failure;

//------------------------------------------------------------------------------
// Lists
//
- (AFHTTPRequestOperation *)addList:(NSString *)listName
                                  success:(void (^)(id response))success
                                  failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)getListsOfUser:(NSUInteger)userID withRestaurant:(NSUInteger)restaurantID
                                  success:(void (^)(NSArray *lists))success
                                  failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantsWithListID:(NSUInteger)listID
                                            success:(void (^)(NSArray *restaurants))success
                                            failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)getMediaItemsForRestaurant:(RestaurantObject *)restaurant
                                               success:(void (^)(NSArray *mediaItems))success
                                               failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)addRestaurantsToFavorites:(NSArray *)restaurants
                                              success:(void (^)(id response))success
                                              failure:(void (^)(NSError *error))failure;


- (AFHTTPRequestOperation *)deleteList:(NSUInteger)listID
                                     success:(void (^)(NSArray *lists))success
                                     failure:(void (^)(NSError *error))failure;


//------------------------------------------------------------------------------
// Users
//
+ (AFHTTPRequestOperation *)getUserImageWithImageID:(NSString *)identifier
                                           maxWidth:(NSUInteger)maxWidth
                                          maxHeight:(NSUInteger)maxHeight
                                            success:(void (^)(NSString *imageRefs))success
                                            failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)setFollowingUser:(UserObject *) user
                                          to:(BOOL)following
                                     success:(void (^)(id ))success
                                     failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)isFollowingUser:(UserObject *) user
                                     success:(void (^)(BOOL))success
                                     failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)getUsersWithIDs:(NSArray *)userIDs
                                    success:(void (^)(NSArray *users))success
                                    failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)getFollowersWithSuccess:(void (^)(NSArray *users))success
                                        failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)getFollowingWithSuccess:(void (^)(NSArray *users))success
                                                failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)getUsersWithKeyword:(NSString *)keyword
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(NSError *error))failure;
+ (void)uploadUserPhoto:(UIImage *)image
                success:(void (^)(void))success
                failure:(void (^)(NSError *error))failure;

+ (void)uploadUserPhoto_AFNetworking:(UIImage *)image
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)lookupUsername:(NSString *)string
                                   success:(void (^)(NSArray *users))success
                                   failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)fetchSampleUsernamesFor:(NSString *)emailAddressString
                                            success:(void (^)(NSArray *names))success
                                            failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation*)clearUsernameWithSuccess:(void (^)(NSArray *names))success
                                            failure:(void (^)(NSError *error))failure;

//------------------------------------------------------------------------------
// Groups
//
+ (AFHTTPRequestOperation *)getUsersOfGroup: (NSInteger)groupID
                                    success:(void (^)(NSArray *groups))success
                                    failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)getGroupsWithSuccess:(void (^)(NSArray *groups))success
                                         failure:(void (^)(NSError *error))failure;

//------------------------------------------------------------------------------
// Events
//

+ (AFHTTPRequestOperation *)determineIfCurrentUserCanEditEvent:(EventObject *)event
                                                       success:(void (^)(bool))success
                                                       failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)getParticipantsInEvent:(EventObject *)eo
                                           success:(void (^)(NSArray *users))success
                                           failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject*)restaurantID
                                  toEvent:(EventObject *)event
                                  success:(void (^)(id response))success
                                  failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)setParticipantsInEvent:(EventObject *)eo
                                                to:(NSArray *)participants
                                           success:(void (^)())success
                                           failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)setParticipationInEvent:(EventObject *)eo
                                                 to:(BOOL)participating
                                            success:(void (^)(NSInteger eventID))success
                                            failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)addEvent:(EventObject *)eo
                                     success:(void (^)(NSInteger eventID))success
                                     failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)reviseEvent:(EventObject *)eo
                                success:(void (^)(id))success
                                failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)getEventsForUser:(NSUInteger)identifier
                                     success:(void (^)(NSArray *events))success
                                     failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)getCuratedEventsWithSuccess:(void (^)(NSArray *events))success
                                     failure:(void (^)(NSError *error))failure;
@end

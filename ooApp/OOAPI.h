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
    kSearchSortTypeDistance = 1,
    kSearchSortTypeBestMatch = 2,
} SearchSortType;

static NSString* const kPhotoUploadPath=  @"/users/picture";

@interface OOAPI : NSObject

//------------------------------------------------------------------------------
// Restaurants

- (AFHTTPRequestOperation *)getRestaurantsWithIDs:(NSArray *)restaurantIDs
                                          success:(void (^)(NSArray *restaurants))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantWithID:(NSString *)restaurantId source:(NSUInteger)source
                                         success:(void (^)(RestaurantObject *restaurants))success
                                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantsWithKeyword:(NSString *)keyword
                                          andLocation:(CLLocationCoordinate2D)location
                                            andFilter:(NSString *)filterName
                                          andOpenOnly:(BOOL)openOnly
                                                 andSort:(SearchSortType)sort
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantImageWithImageRef:(NSString *)imageRef
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *imageRefs))success
                                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantImageWithMediaItem:(MediaItemObject *)mediaItem
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *imageRefs))success
                                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)deleteRestaurant:(NSUInteger)restaurantID fromList:(NSUInteger)listID
                                     success:(void (^)(NSArray *lists))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
                                  success:(void (^)(NSArray *dishes))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getDishesWithIDs:(NSArray *)dishIDs
                                     success:(void (^)(NSArray *dishes))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants toList:(NSUInteger)listID
                                   success:(void (^)(id response))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)addRestaurantsToSpecialList:(NSArray *)restaurants listType:(ListType)listType
                                                success:(void (^)(id response))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


//------------------------------------------------------------------------------
// Lists
//
- (AFHTTPRequestOperation *)addList:(NSString *)listName
                            success:(void (^)(ListObject *listObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getListsOfUser:(NSUInteger)userID withRestaurant:(NSUInteger)restaurantID
                                  success:(void (^)(NSArray *lists))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantsWithListID:(NSUInteger)listID
                                            success:(void (^)(NSArray *restaurants))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getMediaItemsForRestaurant:(RestaurantObject *)restaurant
                                               success:(void (^)(NSArray *mediaItems))success
                                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)deleteList:(NSUInteger)listID
                                     success:(void (^)(NSArray *lists))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


//------------------------------------------------------------------------------
// Users
//
+ (AFHTTPRequestOperation *)getUserImageWithImageID:(NSString *)identifier
                                           maxWidth:(NSUInteger)maxWidth
                                          maxHeight:(NSUInteger)maxHeight
                                            success:(void (^)(NSString *imageRefs))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)setFollowingUser:(UserObject *) user
                                          to:(BOOL)following
                                     success:(void (^)(id ))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)isFollowingUser:(UserObject *) user
                                     success:(void (^)(BOOL))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getUsersWithIDs:(NSArray *)userIDs
                                    success:(void (^)(NSArray *users))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getFollowersOf: (unsigned long)userid
                                   success:(void (^)(NSArray *users))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getFollowingWithSuccess:(void (^)(NSArray *users))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUsersWithKeyword:(NSString *)keyword
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)uploadUserPhoto:(UIImage *)image
                success:(void (^)(void))success
                failure:(void (^)(NSError *error))failure;

+ (void)uploadPhoto:(UIImage *)image
      forRestaurant:(RestaurantObject *)restaurant
            success:(void (^)(void))success
            failure:(void (^)( NSError *error))failure;

+ (AFHTTPRequestOperation *)lookupUsername:(NSString *)string
                                   success:(void (^)(BOOL))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure;

+ (AFHTTPRequestOperation *)lookupUserByEmail:(NSString *)emailString
                                   success:(void (^)(UserObject *))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure;

+ (AFHTTPRequestOperation *)fetchSampleUsernamesFor:(NSString *)emailAddressString
                                            success:(void (^)(NSArray *names))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation*)clearUsernameWithSuccess:(void (^)(NSArray *names))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getAllUsersWithSuccess:(void (^)(NSArray *users))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//------------------------------------------------------------------------------
// Groups
//
+ (AFHTTPRequestOperation *)getUsersOfGroup: (NSInteger)groupID
                                    success:(void (^)(NSArray *groups))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getGroupsWithSuccess:(void (^)(NSArray *groups))success
                                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//------------------------------------------------------------------------------
// Events
//

+ (AFHTTPRequestOperation *)deleteEvent:(NSUInteger)eventID
                                success:(void (^)())success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getEventByID:(NSUInteger) identifier
                                 success:(void (^)(EventObject *event))success
                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *) getVenuesForEvent:(EventObject *)eo
                                       success:(void (^)(NSArray *venues))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)addEvent:(EventObject *)eo
                             success:(void (^)(NSInteger eventID))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)determineIfCurrentUserCanEditEvent:(EventObject *)event
                                                       success:(void (^)(bool))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getParticipantsInEvent:(EventObject *)eo
                                           success:(void (^)(NSArray *users))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject*)restaurantID
                                  toEvent:(EventObject *)event
                                  success:(void (^)(id response))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)removeRestaurant:(RestaurantObject *)restaurant
                                   fromEvent:(EventObject *)event
                                     success:(void (^)(id response))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)setParticipationOf:(UserObject*) user
                                       inEvent:(EventObject *)eo
                                            to:(BOOL) participating
                                       success:(void (^)(NSInteger eventID))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)reviseEvent:(EventObject *)eo
                                success:(void (^)(id))success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getEventsForUser:(NSUInteger)identifier
                                     success:(void (^)(NSArray *events))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getCuratedEventsWithSuccess:(void (^)(NSArray *events))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getVoteForEvent:(EventObject*)event
                                    success:(void (^)(NSArray *votes))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)setVoteTo:(NSInteger)  vote
                             forEvent:(NSUInteger) eventID
                        andRestaurant: (NSUInteger) venueID
                              success:(void (^)(NSInteger eventID))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getVoteTalliesForEvent:(NSUInteger)eventID
                                           success:(void (^)(NSArray *venues))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getFeed:(void (^)(NSArray *feedItems))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

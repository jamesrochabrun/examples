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
#import "AppLogObject.h"
#import "UserStatsObject.h"
#import "LocationManager.h"
#import "AFURLRequestSerialization.h"
#import "CommentObject.h"

//extern NSString *const kKeyName;

typedef enum {
    kSearchSortTypeDistance = 1,
    kSearchSortTypeBestMatch = 2,
} SearchSortType;

typedef enum {
    kFoodFeedTypeFriends = 1,
    kFoodFeedTypeAll = 2,
    kFoodFeedTypeAroundMe = 3
} FoodFeedType;

static NSUInteger kAllUsersID = 0; //means user not specified so trying to get info for all users

@interface OOAPI : NSObject

+ (NSString *) URL;

//------------------------------------------------------------------------------
// Restaurants

- (AFHTTPRequestOperation *)getRestaurantsFromSystemList:(ListType)systemListType
                                                 success:(void (^)(NSArray *restaurants))success
                                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getRestaurantWithID:(NSUInteger)restaurantID
                                         success:(void (^)(RestaurantObject *restaurant))success
                                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantWithID:(NSString *)restaurantID source:(NSUInteger)source
                                        success:(void (^)(RestaurantObject *restaurant))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantsWithKeywords:(NSArray *)keywords
                                           andLocation:(CLLocationCoordinate2D)location
                                             andFilter:(NSString *)filterName
                                             andRadius:(CGFloat)radius
                                           andOpenOnly:(BOOL)openOnly
                                               andSort:(SearchSortType)sort
                                              minPrice:(NSUInteger)minPrice
                                              maxPrice:(NSUInteger)maxPrice
                                                isPlay:(BOOL)isPlay
                                               success:(void (^)(NSArray *restaurants))success
                                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getRestaurantsViaYouSearchForUser:(NSUInteger) userid
                                                     withTerm: (NSString*)term
                                                      success:(void (^)(NSArray *restaurants))success
                                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantImageWithImageRef:(NSString *)imageRef
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *link))success
                                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantImageWithMediaItem:(MediaItemObject *)mediaItem
                                                   maxWidth:(NSUInteger)maxWidth
                                                  maxHeight:(NSUInteger)maxHeight
                                                    success:(void (^)(NSString *link))success
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

- (AFHTTPRequestOperation *)addRestaurantsFromList:(NSUInteger)fromListID toList:(NSUInteger)toListID
                                           success:(void (^)(id response))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants toList:(NSUInteger)listID
                                   success:(void (^)(id response))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)addRestaurantsToSpecialList:(NSArray *)restaurants listType:(ListType)listType
                                                success:(void (^)(id response))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *) convertGoogleIDToRestaurant:(NSString *)googleID
                                                 success:(void (^)(RestaurantObject *restaurant))success
                                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//------------------------------------------------------------------------------
// Lists
//
- (AFHTTPRequestOperation *)addList:(NSString *)listName
                            success:(void (^)(ListObject *listObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)updateList:(ListObject *)list
                               success:(void (^)(ListObject *listObject))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getListsOfUser:(NSUInteger)userID
                            withRestaurant:(NSUInteger)restaurantID
                                includeAll:(BOOL)includeAll
                                   success:(void (^)(NSArray *lists))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getList:(NSUInteger)listID
                            success:(void (^)(ListObject *list))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getRestaurantsWithListID:(NSUInteger)listID
                                         andLocation:(CLLocationCoordinate2D)location
                                             success:(void (^)(NSArray *restaurants))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getMediaItemsForRestaurant:(RestaurantObject *)restaurant
                                               success:(void (^)(NSArray *mediaItems))success
                                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)deleteList:(NSUInteger)listID
                               success:(void (^)(NSArray *lists))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)removeVenue:(RestaurantObject *)venue
                               fromList:(ListObject *)list
                                success:(void (^)(id response))success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//------------------------------------------------------------------------------
// Users
//
+ (AFHTTPRequestOperation *)getUserImageWithImageID:(NSString *)identifier
                                           maxWidth:(NSUInteger)maxWidth
                                          maxHeight:(NSUInteger)maxHeight
                                            success:(void (^)(NSString *imageRefs))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (AFHTTPRequestOperation *)getUserSpecialties: (NSUInteger)userid
                                       success:(void (^)(NSArray *specialties))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getPhotosOfUser:(NSUInteger )userid
                                           maxWidth:(NSUInteger)maxWidth
                                          maxHeight:(NSUInteger)maxHeight
                                            success:(void (^)(NSArray *mediaObjects))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)reportPhoto:(MediaItemObject *)mio success:(void (^)(void))success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)setAboutInfoFor:(NSUInteger)userID
                                         to:(NSString*)text
                                    success:(void (^)( void))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUserStatsFor:(NSUInteger) userid
                                     success:(void (^)(UserStatsObject* ))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)setFollowingUser:(UserObject *) user
                                          to:(BOOL)following
                                     success:(void (^)(id ))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)isFollowingUser:(UserObject *) user
                                    success:(void (^)(BOOL))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)lookupUserByID:(NSUInteger)userID
                                   success:(void (^)(UserObject *user))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getFollowersForUser:(NSUInteger)userid
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getFollowingForUser:(NSUInteger)userid
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUsersWithKeyword:(NSString *)keyword
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUsersOfType:(UserType)userType
                                   success:(void (^)(NSArray *users))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUserWithID:(NSUInteger)identifier
                                  success:(void (^)(UserObject *user))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUserWithUsername:(NSString *)username
                                  success:(void (^)(UserObject *user))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)deletePhoto:(MediaItemObject *)mio success:(void (^)(void))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getMediaItem:(NSUInteger)mediaItemID success:(void (^)(MediaItemObject *mio))success
                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (void)uploadPhoto:(UIImage *)image
          forObject:(id)object
            success:(void (^)(void))success
            failure:(void (^)(NSError *error))failure;

+ (AFHTTPRequestOperation *)lookupUsername:(NSString *)string
                                   success:(void (^)(BOOL))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure;
+ (void)uploadPhoto:(UIImage *)image
          forObject:(id)object
            success:(void (^)(MediaItemObject *mio))success
            failure:(void (^)( NSError *error))failure
           progress:(void (^)(NSUInteger , long long , long long ))progress;

+ (AFHTTPRequestOperation *)lookupUserByEmail:(NSString *)emailString
                                      success:(void (^)(UserObject *))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure;

+ (AFHTTPRequestOperation *)fetchSampleUsernamesFor:(NSString *)emailAddressString
                                            success:(void (^)(NSArray *names))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getAllUsersWithSuccess:(void (^)(NSArray *users))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getMediaItemYummers:(MediaItemObject *)mediaItem
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getFoodieUsersForUser:(UserObject*)user
                                          success:(void (^)(NSArray *users))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getStatsForUser:(NSUInteger)identifier
                                    success:(void (^)(NSDictionary *response))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUsersTheCurrentUserIsNotFollowingUsingEmails: (NSArray*)arrayOfEmailAddresses
                                                                    success:(void (^)(NSArray *users))success
                                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUnfollowedFacebookUsers:(NSArray *)array
                                               forUser:(NSUInteger)userID
                                               success:(void (^)(NSArray *users))success
                                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//------------------------------------------------------------------------------
// Groups
//
+ (AFHTTPRequestOperation *)getUsersOfGroup: (NSInteger)groupID
                                    success:(void (^)(NSArray *groups))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getGroupsWithSuccess:(void (^)(NSArray *groups))success
                                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getFolloweesForRestaurant:(RestaurantObject *)restaurant
                                               success:(void (^)(NSArray *users))success
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

+ (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants
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

+ (AFHTTPRequestOperation *)getVotesForEvent:(EventObject*)event
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

+ (AFHTTPRequestOperation *)getFeedItemsWithSuccess:(void (^)(NSArray *feedItems))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//Tags management
+ (AFHTTPRequestOperation *)getTagsForUser:(NSUInteger)userID
                                   success:(void (^)(NSArray *tags))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getAllTagsWithSuccess:(void (^)(NSArray *tags))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)setTag:(NSUInteger)tagID
                           forUser:(NSUInteger)userID
                           success:(void (^)())success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)unsetTag:(NSUInteger)tagID
                             forUser:(NSUInteger)userID
                             success:(void (^)())success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)uploadAPNSDeviceToken:(NSString *)token
                                          success:(void (^)(id response))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)flagMediaItem:(NSUInteger)mediaItemID
                                  success:(void (^)(NSArray *names))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getFoodFeedType:(NSUInteger)type
                                    success:(void (^)(NSArray *restaurants))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getNumMediaItemLikes:(NSUInteger)mediaItemID
                                      success:(void (^)(NSUInteger count))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getMediaItemLiked:(NSUInteger)mediaItemID
                                       byUser:(NSUInteger)userID
                                      success:(void (^)(BOOL ))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (AFHTTPRequestOperation *)unsetMediaItemLike:(NSUInteger)mediaItemID
                                       forUser:(NSUInteger)userID
                                       success:(void (^)())success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (AFHTTPRequestOperation *)setMediaItemLike:(NSUInteger)mediaItemID
                                       forUser:(NSUInteger)userID
                                       success:(void (^)())success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)setMediaItemCaption:(NSUInteger)mediaItemID
                                        caption:(NSString *)caption
                                        success:(void (^)())success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (AFHTTPRequestOperation *)setMediaItem:(NSUInteger)mediaItemID
                              properties:(NSDictionary *)properties
                                 success:(void (^)())success
                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)authWithFacebookToken:(NSString *)facebookToken
                                          success:(void (^)(UserObject *user, NSString *token))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getRecentUsersSuccess:(void (^)(NSArray *users))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Authentication and user modification
+ (AFHTTPRequestOperation *)authWithEmail:(NSString *)email
                                 password:(NSString *)password
                                  success:(void (^)(UserObject *user, NSString *token))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)createUserWithEmail:(NSString *)email
                                    andPassword:(NSString *)password
                                   andFirstName:(NSString *)firstName
                                    andLastName:(NSString *)lastName
                                        success:(void (^)(UserObject *user, NSString *token))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)updateUser:(UserObject *)user
                               success:(void (^)(void))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUsersAroundLocation:(CLLocationCoordinate2D)location
                                           forUser:(NSUInteger)userID
                                           success:(void (^)(NSArray *users))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)resetPasswordWithEmail:(NSString *)email
                                           success:(void (^)())success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)resendVerificationForCurrentUserSuccess:(void (^)(BOOL))success
                                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)isCurrentUserVerifiedSuccess:(void (^)(BOOL result))success
                                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)sendAppLog:(AppLogObject *)appLog
                               success:(void (^)())success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)getUserRelevantMediaItemForRestaurant:(NSUInteger)restaurantID
                                                          success:(void (^)(NSArray *mediaItems))success
                                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//comments

+ (AFHTTPRequestOperation *)uploadComment:(CommentObject *)comment
                                forObject:(MediaItemObject *)mio
                                  success:(void (^)(CommentObject *))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


+ (AFHTTPRequestOperation *)getCommentsFromMediaItem:(MediaItemObject *)mediaItem
                                             success:(void (^)(NSArray *comments))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)deleteCommentFromMediaItem:(CommentObject *)comment
                                               success:(void (^)(CommentObject *))success
                                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Auto complete


//+ (AFHTTPRequestOperation *) getAutoCompleteDataForString: (NSString*)string
//                                                 location: (CLLocationCoordinate2D)location
//                                                  success:(void (^)(NSArray *results))success
//                                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end

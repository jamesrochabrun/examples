//
//  OOAPI.m
//  ooApp
//
//  Created by Anuj Gujar on 8/6/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "OOAPI.h"
#import "UserObject.h"
#import "Common.h"
#import "Settings.h"
#import "EventObject.h"
#import "GroupObject.h"
#import "AppDelegate.h"

NSString *const kKeySearchRadius = @"radius";
NSString *const kKeySearchSort = @"sort";
NSString *const kKeySearchFilter = @"filter";

@interface OOAPI()
- (NSString *)ooURL;
@end

@implementation OOAPI

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}
- (NSString *)ooURL {
    return [OOAPI URL];
}
//------------------------------------------------------------------------------
// Name:    getRestaurantsWithIDs
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsWithIDs:(NSArray *)restaurantIds
                                          success:(void (^)(NSArray *restaurants))success
                                          failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/restaurants", [self ooURL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *restaurants = [NSMutableArray array];
        for (id dict in responseObject) {
            //NSLog(@"rest name: %@", [RestaurantObject restaurantFromDict:dict].name);
            [restaurants addObject:[RestaurantObject restaurantFromDict:dict]];
        }
        success(restaurants);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantMediaItems
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getMediaItemsForRestaurant:(RestaurantObject *)restaurant
                                          success:(void (^)(NSArray *mediaItems))success
                                          failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/restaurants/%lu/photos", [self ooURL], ( unsigned long) restaurant.restaurantID];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *mediaItems = [NSMutableArray array];
        for (id dict in responseObject) {
            //NSLog(@"rest name: %@", [RestaurantObject restaurantFromDict:dict].name);
            [mediaItems addObject:[MediaItemObject mediaItemFromDict:dict]];
        }
        success(mediaItems);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantsWithIDs
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantWithID:(NSString *)restaurantId source:(NSUInteger)source
                                          success:(void (^)(RestaurantObject *))success
                                          failure:(void (^)(NSError *error))failure
{
    if (!restaurantId) return nil;
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/restaurants/%@?source=%lu", [self ooURL], restaurantId,( unsigned long) source];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
//        NSMutableArray *restaurants = [NSMutableArray array];
//        for (id dict in responseObject) {
//            NSLog(@"rest name: %@", [RestaurantObject restaurantFromDict:dict].name);
//            [restaurants addObject:[RestaurantObject restaurantFromDict:dict]];
//        }
        RestaurantObject *restaurant = [RestaurantObject restaurantFromDict:responseObject];
        success(restaurant);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantImageWithImageRef
// Purpose:
//------------------------------------------------------------------------------
//
// Only one of max width or max height is heeded. Preference is given to max width
//
- (AFHTTPRequestOperation *)getRestaurantImageWithImageRef:(NSString *)imageRef
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *link))success
                                                   failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/restaurants/photos", [self ooURL]];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:imageRef forKey:@"reference"];
    
    if (maxWidth) {
        maxWidth = (isRetinaDisplay()) ? 2*maxWidth:maxWidth;
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)maxWidth] forKey:@"maxwidth"];
    } else if (maxHeight) {
        maxHeight = (isRetinaDisplay()) ? 2*maxHeight:maxHeight;
        [parameters setObject:[NSString stringWithFormat:@"%lu", ( unsigned long) maxWidth] forKey:@"maxHeight"];
    }
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        success([responseObject objectForKey:@"link"]);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantsWithKeyword andLocation
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsWithKeyword:(NSString *)keyword
                                          andLocation:(CLLocationCoordinate2D)location
                                            andFilter:(NSString*)filterName
                                           andOpenOnly:(BOOL)openOnly
                                           andSort:(SearchSortType)sort
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(NSError *error))failure
{
    if (!keyword) {
        failure(nil);
        return nil;
    }
    
    if (!filterName) {
        filterName = @"";
    }
    
    if (!sort) {
        sort = kSearchSortTypeBestMatch;
    }
    
    double radius= [Settings sharedInstance].searchRadius;
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/search", [OOAPI URL]];
    NSDictionary *parameters = @{@"keyword":keyword,
                                 kKeySearchSort:[NSNumber numberWithUnsignedInteger:sort],
                                 kKeySearchRadius:[NSNumber numberWithUnsignedInteger:radius],
                                 kKeyRestaurantLatitude:[NSNumber numberWithFloat:location.latitude],
                                 kKeyRestaurantLongitude:[NSNumber numberWithFloat:location.longitude],
//                                 kKeyRestaurantLatitude:[NSNumber numberWithFloat:37.773972],
//                                 kKeyRestaurantLongitude:[NSNumber numberWithFloat:-122.431297],
                                 kKeyRestaurantOpenNow:[NSNumber numberWithBool:openOnly],
                                 kKeySearchFilter:filterName};
    
//    NSLog (@" URL= %@",urlString);
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        NSMutableArray *restaurants = [NSMutableArray array];
        for (id dict in responseObject) {
            //NSLog(@"rest name: %@", [RestaurantObject restaurantFromDict:dict].name);
            [restaurants addObject:[RestaurantObject restaurantFromDict:dict]];
        }
        success(restaurants);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getAllUsers
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getAllUsersWithSuccess:(void (^)(NSArray *users))success
                                           failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users", [OOAPI URL]];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *users = [NSMutableArray array];
        for (id dict in responseObject) {
            UserObject *u=[UserObject userFromDict:dict];
            if ( u) {
                NSLog(@"FOUND USER: %@", u.username);
                [users addObject:u];
            }
        }
        success(users);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getUsersWithKeyword
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUsersWithKeyword:(NSString *)keyword
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(NSError *error))failure
{
    if (!keyword  || !keyword.length) {
        failure(nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/search/users", [OOAPI URL]];
    NSDictionary *parameters = @{
                                 @"keyword":keyword,
                                 };
    
    //    NSLog (@" URL = %@",urlString);
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        NSMutableArray *users = [NSMutableArray array];
        for (id dict in responseObject) {
            UserObject *u=[UserObject userFromDict:dict];
            NSLog(@"FOUND USER: %@", u.username);
            [users addObject:u];
        }
        success(users);
    } failure:^(NSError *error) {
//        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getUsersWithIDs
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation*)getUsersWithIDs:(NSArray *)userIDs
                                   success:(void (^)(NSArray *users))success
                                   failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users", [OOAPI URL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *users = [NSMutableArray array];
        for (id dict in responseObject) {
//            NSLog(@"user: %@", dict);
            [users addObject:[UserObject userFromDict:dict]];
        }
        success(users);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getDishesWithIDs
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation*)getDishesWithIDs:(NSArray *)dishIDs
                                    success:(void (^)(NSArray *dishes))success
                                    failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/dishes", [OOAPI URL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    

    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        for (id dict in responseObject) {
            NSLog(@"dish: %@", dict);
        }
    } failure:^(NSError *error) {
        failure(error);
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getListsOfUser:withRestaurant
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation*)getListsOfUser:(NSUInteger)userID
                           withRestaurant:(NSUInteger)restaurantID
                                  success:(void (^)(NSArray *lists))success
                                  failure:(void (^)(NSError *error))failure
{
    if (!userID) {
        failure(nil);
        return nil;
    }
    
    NSString *restaurantResource = @"";
    if (restaurantID) {
        restaurantResource = [NSString stringWithFormat:@"/restaurants/%ld", (long)restaurantID];
    }
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%ld%@/lists",
                           [OOAPI URL], (long)userID, restaurantResource];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *lists = [NSMutableArray array];
        for (id dict in responseObject) {
            [lists addObject:[ListObject listFromDict:dict]];
        }
        success(lists);
    } failure:^(NSError *error) {
        ;
    }];
}

//------------------------------------------------------------------------------
// Name:    deleteRestaurant:fromList
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)deleteRestaurant:(NSUInteger)restaurantID fromList:(NSUInteger)listID
                                  success:(void (^)(NSArray *lists))success
                                  failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists/%lu/restaurants/%lu",
                           [OOAPI URL], (unsigned long)listID, (unsigned long)restaurantID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm DELETE:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *lists = [NSMutableArray array];
        success(lists);
    } failure:^(NSError *error) {
        ;
    }];
}

//------------------------------------------------------------------------------
// Name:    lookupUserByEmail
// Purpose: Ascertain what existing user have a given email address.
// NOTE:    The backend guarantees there is only one account per email address.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)lookupUserByEmail:(NSString *)emailString
                                      success:(void (^)(UserObject *users))success
                                      failure:(void (^)(NSError *))failure;
{
    if (!emailString || !emailString.length) {
        failure(nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/emails/%@",
                           [OOAPI URL], emailString];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        if ( [responseObject isKindOfClass:[NSDictionary class]]) {
            UserObject* user= [UserObject userFromDict: responseObject];
            if  (user ) {
                success( user);
            } else {
                success( nil);
            }
        }
    }
           failure:failure];
}

//------------------------------------------------------------------------------
// Name:    deleteList
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)deleteList:(NSUInteger)listID
                               success:(void (^)(NSArray *))success
                               failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists/%lu",
                           [OOAPI URL], (unsigned long)listID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm DELETE:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *lists = [NSMutableArray array];
        success(lists);
    } failure:^(NSError *error) {
        ;
    }];
}

//------------------------------------------------------------------------------
// Name:    lookupUsername
// Purpose: Ascertain whether a username is already in use.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)lookupUsername:(NSString *)string
                                  success:(void (^)(BOOL exists))success
                                  failure:(void (^)(NSError *))failure;
{
    if (!string || !string.length) {
        failure(nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/usernames/%@",
                           [OOAPI URL], string];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSArray *array= responseObject;
        NSMutableArray *users= [NSMutableArray new];
        for (NSDictionary* d  in  array) {
            UserObject* user= [UserObject userFromDict:d];
            if  (user ) {
                [users  addObject: user];
            }
        }
        success( users.count>0);
    }
           failure:failure];
}

//------------------------------------------------------------------------------
// Name:    clearUsernameOf
// Purpose: For testing.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)clearUsernameWithSuccess:(void (^)(NSArray *names))success
                                   failure:(void (^)(NSError *error))failure;
{
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    
    NSString *requestString =[NSString stringWithFormat:@"https://%@/users/%lu", [OOAPI URL], (unsigned long)userID];
    
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    return [[OONetworkManager sharedRequestManager] PUT:requestString
                                             parameters:@{
                                                     @"username":@""
                                                     }
                                                success:success
                                                failure:failure];
}

//------------------------------------------------------------------------------
// Name:    fetchSampleUsernames
// Purpose: Ascertain whether a username is already in use.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)fetchSampleUsernamesFor:(NSString *)emailAddressString
                                  success:(void (^)(NSArray *names))success
                                  failure:(void (^)(NSError *error))failure;
{
    if (!emailAddressString || !emailAddressString.length) {
        failure(nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/usernames?email=%@",
                           [OOAPI URL], emailAddressString];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:success failure:failure];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantsWithListID
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsWithListID:(NSUInteger)listID
                                            success:(void (^)(NSArray *restaurants))success
                                            failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists/%ld/restaurants",
                           [OOAPI URL],
                           (long)listID];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *restaurants = [NSMutableArray array];
        if ([responseObject count]) {
            for (id dict in responseObject) {
                [restaurants addObject:[RestaurantObject restaurantFromDict:dict]];
            }
        }
        success(restaurants);
    } failure:^(NSError *error) {
        ;
    }];

    
    //return [rm GET:urlString parameters:nil success:success failure:failure];
}

//------------------------------------------------------------------------------
// Name:    addRestaurant
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
                                 success:(void (^)(NSArray *dishes))success
                                 failure:(void (^)(NSError *error))failure
{
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/restaurants", [OOAPI URL]];
    
    AFHTTPRequestOperation *op = [rm POST:urlString
                               parameters:[RestaurantObject dictFromRestaurant:restaurant]
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    addList
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addList:(NSString *)listName
                            success:(void (^)(ListObject *listObject))success
                            failure:(void (^)(NSError *error))failure;
{
    if (!listName) {
        failure(nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID= userInfo.userID;
    if (!userID) {
        failure(nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/lists", [OOAPI URL], (unsigned long)userID];
    NSDictionary *parameters = @{
                                 @"name":listName,
                                  @"type":[NSString stringWithFormat:@"%d", kListTypeUser],
                                  @"user": @(userID)
                                };
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      ListObject *l = [ListObject listFromDict:responseObject];
                                      success(l);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    addRestaurants:ToList
// Purpose: Add restaurants to a user's favorites list
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants toList:(NSUInteger)listID
                                   success:(void (^)(id response))success
                                   failure:(void (^)(NSError *error))failure {
    NSMutableArray *restaurantIDs;
    if (!restaurants || !listID) {
        failure(nil);
        return nil;
    } else {
        restaurantIDs = [NSMutableArray array];
        [restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RestaurantObject *ro = (RestaurantObject *)obj;
            [restaurantIDs addObject:[NSString stringWithFormat:@"%lu",(unsigned long)ro.restaurantID]];
        }];
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID= userInfo.userID;
    if (!userID) {
        failure(nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists/%lu/restaurants", [OOAPI URL], (unsigned long)listID];
    
    NSString *IDs = [restaurantIDs componentsJoinedByString:@","];
    NSDictionary *parameters = @{
                                 @"restaurant_ids":IDs
                                 };
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
    
    return op;
}


//------------------------------------------------------------------------------
// Name:    addRestaurantsToSpecialList:listType
// Purpose: Add restaurants to a user's favorites list
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addRestaurantsToSpecialList:(NSArray *)restaurants listType:(ListType)listType
                                              success:(void (^)(id response))success
                                              failure:(void (^)(NSError *error))failure;
{
    NSMutableArray *restaurantIDs;
    if (!restaurants) {
        failure(nil);
        return nil;
    } else {
        restaurantIDs = [NSMutableArray array];
        [restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RestaurantObject *ro = (RestaurantObject *)obj;
            [restaurantIDs addObject:[NSString stringWithFormat:@"%lu",(unsigned long)ro.restaurantID]];
        }];
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID= userInfo.userID;
    if (!userID) {
        failure(nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];

    NSString *urlString;
    if (listType == kListTypeFavorites) {
        urlString = [NSString stringWithFormat:@"https://%@/users/%lu/favorites/restaurants", [OOAPI URL], (unsigned long)userID];
    } else if (listType == kListTypeToTry) {
        urlString = [NSString stringWithFormat:@"https://%@/users/%lu/totry/restaurants", [OOAPI URL], (unsigned long)userID];
    } else {
        failure(nil);
        return nil;
    }
    
    NSString *IDs = [restaurantIDs componentsJoinedByString:@","];
    NSDictionary *parameters = @{
                                 @"restaurant_ids":IDs
                                 };
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    getUserImageWithImageID
// Purpose:
//------------------------------------------------------------------------------
//
// Only one of max width or max height is heeded. Preference is given to max width
//
+ (AFHTTPRequestOperation *)getUserImageWithImageID:(NSString *)identifier
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *link))success
                                                   failure:(void (^)(NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/photos", [OOAPI URL]];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:identifier forKey:@"identifier"];
    
    if (maxWidth) {
        maxWidth = (isRetinaDisplay()) ? 2*maxWidth:maxWidth;
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)maxWidth] forKey:@"maxwidth"];
    } else if (maxHeight) {
        maxHeight = (isRetinaDisplay()) ? 2*maxHeight:maxHeight;
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)maxWidth] forKey:@"maxHeight"];
    }
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        success([responseObject objectForKey:@"link"]);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


+ (AFHTTPRequestOperation *)isFollowingUser:(UserObject *)user
                                    success:(void (^)(BOOL))success
                                    failure:(void (^)(NSError *error))failure;
{
    if (!user) {
        failure(nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger selfUserID = userInfo.userID;
    if (!selfUserID) {
        failure(nil);
        return nil;
    }
    NSUInteger otherUserID = user.userID;
    if (!otherUserID) {
        failure(nil);
        return nil;
    }
    if  (selfUserID ==otherUserID ) {
        NSLog  (@"CANNOT FOLLOW ONESELF.");
        success(NO);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/follow/%lu", [OOAPI URL], (unsigned long)selfUserID,(unsigned long)otherUserID];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               for (id dict in responseObject) {
                   UserObject *followee = [UserObject userFromDict:dict];
                   if (followee.userID  == otherUserID ) {
                       success(YES);
                       return;
                   }
               }
               success(NO);
           } failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure(error);
           }];
}

//------------------------------------------------------------------------------
// Name:    setFollowingUser
// Purpose: Specify whether the current user is following a specific other user.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)setFollowingUser:(UserObject *) user
                                                 to: (BOOL) following
                                            success:(void (^)(id responseObject))success
                                            failure:(void (^)(NSError *error))failure;
{
    if (!user) {
        failure(nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger selfUserID= userInfo.userID;
    if (!selfUserID) {
        failure(nil);
        return nil;
    }
    NSUInteger otherUserID= user.userID;
    if (!otherUserID) {
        failure(nil);
        return nil;
    }
    if  (selfUserID == otherUserID  ) {
        NSLog  (@"CANNOT FOLLOW ONESELF.");
        failure(nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/following/%lu", [OOAPI URL], (unsigned long)selfUserID,(unsigned long)otherUserID];
    
    AFHTTPRequestOperation *op;
    if (following) {
        op = [rm PUT: urlString parameters:nil
               success:^(id responseObject) {
	   success(responseObject);
               } failure:^(NSError *error) {
                   failure(error);
               }];
    } else {
        op = [rm DELETE: urlString parameters:nil
                success:^(id responseObject) {
                    success(responseObject);
                } failure:^(NSError *error) {
                    failure(error);
                }];
        
    }
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    setParticipationInEvent
// Purpose:
// Note:    If user is nil then it is the current user.h
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)setParticipationOf:(UserObject*) user
                                       inEvent:(EventObject *)event
                                                 to:(BOOL) participating
                                               success:(void (^)(NSInteger eventID))success
                                               failure:(void (^)(NSError *error))failure;
{
    if (!event ) {
        failure(nil);
        return nil;
    }
    
    UserObject *userInfo= [Settings sharedInstance].userObject;
    if (!user) {
        user= userInfo;
    }
    NSUInteger userID= user.userID;
    if (!userID) {
        failure(nil);
        return nil;
    }
    
    NSUInteger eventID= event.eventID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
//    NSString *IDs = [restaurantIDs componentsJoinedByString:@","];

    AFHTTPRequestOperation *op;
    if (participating) {
        NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%lu/users", [OOAPI URL],  (unsigned long)eventID];
        NSLog (@"POST %@", urlString);
        op = [rm POST:urlString parameters: @{
                                              @"user_ids":  @(user.userID)
                                              }
                                       success:^(id responseObject) {
                                           NSInteger identifier= 0;
                                           if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                               NSNumber *eventID= ((NSDictionary *)responseObject)[ @"event_id"];
                                               identifier= parseIntegerOrNullFromServer(eventID);
                                           }
                                           success(identifier);
                                       } failure:^(NSError *error) {
                                           failure(error);
                                       }];
    } else {
        NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%lu/users/%lu",
                               [OOAPI URL],
                                (unsigned long)eventID, (unsigned long)user.userID];
        
        NSLog (@"DELETE %@", urlString);
        op = [rm DELETE:urlString parameters: nil
                                        success:^(id responseObject) {
                                            NSInteger identifier= 0;
                                            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                NSNumber *eventID= ((NSDictionary *)responseObject)[ @"event_id"];
                                                identifier= parseIntegerOrNullFromServer(eventID);
                                            }
                                            success(identifier);
                                        } failure:^(NSError *error) {
                                            failure(error);
                                        }];
        
    }
    
    return op;
}

+ (AFHTTPRequestOperation *) getVenuesForEvent:(EventObject *)eo
                                           success:(void (^)(NSArray *venues))success
                                           failure:(void (^)(NSError *error))failure;
{
    if (!eo) {
        failure(nil);
        return nil;
    }
    NSInteger eventID = eo.eventID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%ld/restaurants", [OOAPI URL], (unsigned long)eventID];
    
    AFHTTPRequestOperation *op;
    
    op = [rm GET : urlString parameters:nil
          success:^(id responseObject) {
              NSArray *array= responseObject;
              NSMutableArray *venues= [NSMutableArray new];
              for (NSDictionary *d in array) {
                  RestaurantObject *venue = [RestaurantObject restaurantFromDict:d];
                  if (venue) {
                      [venues addObject:venue];
                  }
              }
              success(venues);
          } failure:^(NSError *error) {
              // RULE: Leave the venues unchanged.
              failure(error);
          }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    getParticipantsInEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getParticipantsInEvent:(EventObject *)eo
                                           success:(void (^)(NSArray *users))success
                                           failure:(void (^)(NSError *error))failure;
{
    if (!eo) {
        failure(nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    if (!userID) {
        failure(nil);
        return nil;
    }
    NSInteger eventID = eo.eventID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%lu/users", [OOAPI URL], (unsigned long)eventID];
    
    AFHTTPRequestOperation *op;
    
    op = [rm GET : urlString parameters:nil
           success:^(id responseObject) {
               NSArray *array= responseObject;
               NSMutableArray *users= [NSMutableArray new];
               for (NSDictionary *d in array) {
                   UserObject *user = [UserObject userFromDict:d];
                   if (user) {
                       [users addObject:user];
                   }
               }
               success(users);
           } failure:^(NSError *error) {
               failure(error);
           }];
    
    return op;
}


//------------------------------------------------------------------------------
// Name:    uploadUserPhoto
// Purpose: This is the native approach.
//------------------------------------------------------------------------------
+ (void)uploadUserPhoto:(UIImage *)image
                success:(void (^)(void))success
                failure:(void (^)(NSError *error))failure;
{
    if (!image) {
        failure(nil);
        return ;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSLog (@"IMAGE DIMENSIONS=  %@", NSStringFromCGSize(image.size));
    NSLog (@"JPEG IMAGE SIZE=  %ld bytes",[imageData length]);
    [APP.diagnosticLogString appendFormat: @"IMAGE DIMENSIONS=  %@\r", NSStringFromCGSize(image.size)];
    [APP.diagnosticLogString appendFormat:@"JPEG IMAGE SIZE=  %ld bytes\r",[imageData length]];

    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID= userInfo.userID;
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/photos", [OOAPI URL], (unsigned long)userID];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[ NSURL  URLWithString:urlString]];
    if (!request) {
        failure(nil);
        return ;
    }
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    
    NSUInteger timeoutLength=5 + 5 * ([imageData length] >> 19);
    [request setTimeoutInterval: timeoutLength];
    NSLog (@"SETTING TIMEOUT TO: %lu seconds", ( unsigned long)timeoutLength);
    
    NSString*const boundary = @"----WebKitFormBoundaryPnHdnY89ti1wsHcj";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]
        forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData new];
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.jpg\"\r\n", @"upload"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg, image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", ( unsigned long) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    NSURLSessionDataTask *task = [session dataTaskWithRequest: request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        if (failure) failure(error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                        NSLog (@"IMAGE UPLOAD RESPONSE:  %ld", (long)httpResp.statusCode);
                                                        if (httpResp.statusCode == 200) {
                                                            if (success) success();
                                                        }else {
                                                            if (failure) failure(nil);
                                                        }
                                                        
                                                    }
                                                }];
    [task resume];
}

//------------------------------------------------------------------------------
// Name:    deleteEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)deleteEvent:(NSUInteger)eventID
                                success:(void (^)())success
                                failure:(void (^)(NSError *error))failure
{
    if  (!eventID) {
        failure (nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%lu",
                           [OOAPI URL], (unsigned long)eventID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm DELETE:urlString parameters:nil success:^(id responseObject) {
        success();
    } failure:^(NSError *error) {
        failure (error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getEventsForUser
// Purpose: Obtain a list of user events that are either complete or incomplete.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getEventsForUser:(NSUInteger) identifier
                                     success:(void (^)(NSArray *events))success
                                     failure:(void (^)(NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/events",[OOAPI URL], (unsigned long)identifier];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSLog  (@"RESPONSE TO EVENTS QUERY: %@",responseObject);
               if ( [responseObject isKindOfClass:[NSArray class]]) {
                   NSMutableArray *events = [NSMutableArray array];
                   for (id dict in responseObject) {
                       EventObject *e=[EventObject eventFromDictionary:dict];
                       NSLog  (@"EVENT  %@",dict);
                       //NSLog(@"Event name: %@", [RestaurantObject restaurantFromDict:dict].name);
                       [events addObject:e];
                   }
                   success(events);
               } else {
                   NSLog  (@"RESPONSE IS NOT AN ARRAY OF EVENTS.");
                   failure(nil);
               }
           } failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure(error);
           }];
}
//------------------------------------------------------------------------------
// Name:    getEventByID
// Purpose: Obtain a list of user events that are either complete or incomplete.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getEventByID:(NSUInteger)identifier
                                 success:(void (^)(EventObject *event))success
                                 failure:(void (^)(NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%lu",[OOAPI URL], (unsigned long)identifier];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSLog  (@"RESPONSE TO EVENTS QUERY: %@",responseObject);
               if ( [responseObject isKindOfClass:[NSDictionary  class]]) {
                 
                   EventObject *e=[EventObject eventFromDictionary: responseObject];
                   NSLog  (@"EVENT  %@",responseObject);
                   
                   success(e);
               }else {
                   NSLog  (@"RESPONSE IS NOT AN ARRAY OF EVENTS.");
                   failure(nil);
               }
           } failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure(error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getCuratedEventsWithSuccess
// Purpose: Obtain a list of curated events that are complete.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getCuratedEventsWithSuccess:(void (^)(NSArray *events))success
                                                failure:(void (^)(NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events",[OOAPI URL]];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSLog  (@"RESPONSE TO EVENTS QUERY: %@",responseObject);
        if ( [responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray *events = [NSMutableArray array];
            for (id dict in responseObject) {
                EventObject *e=[EventObject eventFromDictionary:dict];
                NSLog  (@"EVENT  %@",dict);
                //NSLog(@"Event name: %@", [RestaurantObject restaurantFromDict:dict].name);
                [events addObject:e];
            }
            success(events);
        }else {
            NSLog(@"RESPONSE IS NOT AN ARRAY OF EVENTS.");
            failure(nil);
        }
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

//------------------------------------------------------------------------------
// Name:    addRestaurant toEvent
// Purpose: Add a restaurant to an event.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
                                 toEvent:(EventObject *)event
                                  success:(void (^)(id response))success
                                  failure:(void (^)(NSError *error))failure;
{
    if (!event || !restaurant) {
        failure(nil);
        return nil;
    }
    
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userid = userInfo.userID;
    if (!userid) {
        failure(nil);
        return nil;
    }
    
    NSString *identifier = [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.restaurantID];
    NSString *googleIdentifier = restaurant.googleID;
    NSMutableDictionary* parameters = @{}.mutableCopy;
    
    if (identifier) {
        [parameters setObject:identifier forKey:kKeyRestaurantRestaurantIDPlural];
    }
    else if (googleIdentifier.length) {
        [parameters setObject:googleIdentifier forKey:kKeyRestaurantGoogleID];
    }
    else {
        NSLog (@"MISSING VENUE IDENTIFIER");
        failure(nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%lu/restaurants", [OOAPI URL],
                           (unsigned long)event.eventID];
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    removeRestaurant fromEvent
// Purpose: Add a restaurant to an event.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)removeRestaurant:(RestaurantObject *)restaurant
                                  fromEvent:(EventObject *)event
                                  success:(void (^)(id response))success
                                  failure:(void (^)(NSError *error))failure;
{
    if (!event  || !restaurant) {
        failure(nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userid = userInfo.userID;
    if (!userid) {
        failure(nil);
        return nil;
    }
    NSString *identifier = [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.restaurantID];
    NSString *googleIdentifier = restaurant.googleID;
    NSMutableDictionary* parameters = @{}.mutableCopy;
    if (identifier.length) {
        [parameters setObject:identifier forKey:kKeyRestaurantRestaurantID];
    }
    else if (googleIdentifier.length) {
        [parameters setObject:googleIdentifier forKey:kKeyRestaurantGoogleID];
    }
    else {
        NSLog (@"MISSING VENUE IDENTIFIER");
        failure(nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%lu/restaurants", [OOAPI URL],
                            (unsigned long)event.eventID];
    
    AFHTTPRequestOperation *op = [rm DELETE: urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
    return op;
}

//------------------------------------------------------------------------------
// Name:    addEvent
// Purpose: Create a new event and receive in return the new event's ID.
// Note:    The event does not need to be completely described in the EventObject.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)addEvent:(EventObject *)eo
                               success:(void (^)(NSInteger eventID))success
                               failure:(void (^)(NSError *error))failure;
{
    if (!eo) {
        failure(nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (!userid) {
        failure(nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/events", [OOAPI URL], (unsigned long)userid];
    
    NSDictionary *parameters= [eo dictionaryFromEvent];
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      NSInteger identifier= 0;
                                      if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                          NSNumber *eventID= ((NSDictionary *)responseObject)[@"event_id"];
                                          identifier= parseIntegerOrNullFromServer(eventID);
                                      }
                                      if (!identifier) {
                                          message( @"event ID is zero.");
//                                          failure(nil);
//                                          return;
                                      }
                                      success(identifier);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    reviseEvent
// Purpose: Create a new event and receive in return the new event's ID.
// Note:    The event does not need to be completely described in the EventObject.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)reviseEvent:(EventObject *)eo
                             success:(void (^)(id))success
                             failure:(void (^)(NSError *error))failure;
{
    if (!eo) {
        failure(nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (! userid) {
        failure(nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%lu", [OOAPI URL],  (unsigned long)eo.eventID];
    
    NSDictionary *parameters= [eo dictionaryFromEvent];

    AFHTTPRequestOperation *op = [rm PUT:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    getFollowersWithSuccess
// Purpose: Fetch an array of users that are following the current user.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFollowersWithSuccess:(void (^)(NSArray *users))success
                                            failure:(void (^)(NSError *error))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (!userid) {
        failure(nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/followers", [OOAPI URL], (unsigned long)userid];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
        NSMutableArray *users = [NSMutableArray array];
        for (id dict in responseObject) {
            [users addObject:[UserObject userFromDict:dict]];
        }
        success(users);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getFollowingWithSuccess
// Purpose: Fetch an array of users that the current user is following.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFollowingWithSuccess:(void (^)(NSArray *users))success
                                            failure:(void (^)(NSError *error))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (!userid) {
        failure(nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/following", [OOAPI URL], (unsigned long)userid];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *users = [NSMutableArray array];
               for (id dict in responseObject) {
                   [users addObject:[UserObject userFromDict:dict]];
               }
               success(users);
           } failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure(error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getGroupsWithSuccess
// Purpose: Fetch an array of groups of which the current user is a member .
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getGroupsWithSuccess:(void (^)(NSArray *groups))success
                                            failure:(void (^)(NSError *error))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (!userid) {
        failure(nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/groups",
                           [OOAPI URL], (unsigned long)userid];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *groups = [NSMutableArray array];
               for (id object in responseObject) {

                   if ( [ object isKindOfClass:[NSDictionary class]]) {
                       [groups  addObject:[GroupObject groupFromDictionary:object]];
                   }
               }
               
               NSLog  (@"TOTAL GROUPS FOUND: %ld", (unsigned long)groups.count);
               success(groups);
           }
           failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure(error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getUsersOfGroup
// Purpose: Fetch an array of users who belong to a specified group.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUsersOfGroup: (NSInteger)groupID
                                    success:(void (^)(NSArray *groups))success
                                    failure:(void (^)(NSError *error))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (!userid) {
        failure(nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/groups/%lu/users",
                           [OOAPI URL], (unsigned long)groupID];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *users = [NSMutableArray array];
               for (id object in responseObject) {
                   
                   if ( [ object isKindOfClass:[NSDictionary class]]) {
                       [users  addObject:  [UserObject userFromDict: object]];
                   }
               }
               
               NSLog  (@"TOTAL USERS FOUND: %ld", (unsigned long)users.count);
               success(users);
           }
           failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure(error);
           }];
}

//------------------------------------------------------------------------------
// Name:    determineIfCurrentUserCanEditEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)determineIfCurrentUserCanEditEvent:(EventObject *) event
                                                       success:(void (^)(bool))success
                                                       failure:(void (^)(NSError *error))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    if (!userID) {
        failure(nil);
        return nil;
    }

    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%lu/users/%lu",
                           [OOAPI URL],
                           (unsigned long)event.eventID,
                           ( unsigned long) userID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    AFHTTPRequestOperation *operation = [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               if ([responseObject isKindOfClass:[NSDictionary class]]) {
                   UserObject *user= [UserObject userFromDict:responseObject];
                   if (user &&
                        (user.participantType == PARTICIPANT_TYPE_ORGANIZER ||
                         user.participantType == PARTICIPANT_TYPE_CREATOR)
                       ) {
                       success(YES);
                       return;
                   }
               }
               success(NO);
           }
           failure:^(NSError *error) {
               NSInteger statusCode = operation.response.statusCode;
               if (statusCode == 404) {
                   success(NO);
               } else {
                   NSLog(@"Error: %@", error);
                   failure(error);
               }
           }];
    
    return operation;
}

//------------------------------------------------------------------------------
// Name:    getVotesForEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getVoteForEvent:(EventObject*)event
                                    success:(void (^)(NSArray *votes))success
                                    failure:(void (^)(NSError *error))failure;
{

    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%ld/votes", [OOAPI URL], (unsigned long)event.eventID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters: nil
           success:^(id responseObject) {
               NSMutableArray *votes = [NSMutableArray array];
               for (id dict in responseObject) {
                   VoteObject* object=[VoteObject voteFromDictionary:dict];
                   if  (object ) {
                       [votes addObject: object];
                   }
               }
               success(votes);
           }
           failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure(error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getVoteTalliesForEvent
// Purpose: Fetch an array of restaurants.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getVoteTalliesForEvent:(NSUInteger)eventID
                                    success:(void (^)(NSArray *venues))success
                                    failure:(void (^)(NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%ld/votes/results", [OOAPI URL], (unsigned long)eventID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters: nil
           success:^(id responseObject) {
               NSMutableArray *venues = [NSMutableArray array];
               for (NSDictionary* d in responseObject) {
                   RestaurantObject* object=[RestaurantObject restaurantFromDict:d];
                   if  (object ) {
                       [venues addObject: object];
                   }
               }
               success(venues);
           }
           failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure(error);
           }];
}

//------------------------------------------------------------------------------
// Name:    setVoteTo forEvent andRestaurant
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)setVoteTo:(NSInteger)  vote
                             forEvent:(NSUInteger) eventID
                        andRestaurant: (NSUInteger) venueID
                              success:(void (^)(NSInteger eventID))success
                              failure:(void (^)(NSError *error))failure;
{
    if (!eventID  || !venueID ) {
        failure(nil);
        return nil;
    }
    
    if  (vote != 1 ) {
        vote= 0;
    }
    
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID= userInfo.userID;
    if (!userID) {
        failure(nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    AFHTTPRequestOperation *op;
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/votes", [OOAPI URL]];
    
    op = [rm POST:urlString parameters: @{
                                          @"user_id": @(userID),
                                           @"restaurant_id": @(venueID),
                                           @"event_id": @(eventID),
                                           @"vote": @(vote)
                                          }
          success:^(id responseObject) {
              NSInteger identifier= 0;
              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                  NSNumber *eventID= ((NSDictionary *)responseObject)[ @"event_id"];
                  identifier= parseIntegerOrNullFromServer(eventID);
              }
              success(identifier);
          } failure:^(NSError *error) {
              failure(error);
          }];
    
    return op;
}

+ (NSString *) URL {
    // XX If not I want hello are you yeah that sounds good cool thanks Sia!using staging server, use production URL.
    return kOOURL;
}
@end

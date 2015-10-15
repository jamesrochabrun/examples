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

NSString *const kKeySearchRadius = @"radius";
NSString *const kKeySearchSort = @"sort";

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
    return kOOURL;
}
//------------------------------------------------------------------------------
// Name:    getRestaurantsWithIDs
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsWithIDs:(NSArray *)restaurantIds
                                          success:(void (^)(NSArray *restaurants))success
                                          failure:(void (^)(NSError *))failure
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
                                          failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/restaurants/%@/photos", [self ooURL], restaurant.restaurantID];
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
                                          failure:(void (^)(NSError *))failure
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
                                                   failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/restaurants/photos", [self ooURL]];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:imageRef forKey:@"reference"];
    
    if (maxWidth) {
        maxWidth = (isRetinaDisplay()) ? 2*maxWidth:maxWidth;
        [parameters setObject:[NSString stringWithFormat:@"%tu", maxWidth] forKey:@"maxwidth"];
    } else if (maxHeight) {
        maxHeight = (isRetinaDisplay()) ? 2*maxHeight:maxHeight;
        [parameters setObject:[NSString stringWithFormat:@"%tu", maxWidth] forKey:@"maxHeight"];
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
                                           andOpenOnly:(BOOL)openOnly
                                           andSort:(SearchSortType)sort
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(NSError *))failure
{
    if (!keyword) {
        failure (nil);
        return nil;
    }
    
    if (!sort) {
        sort = kSearchSortTypeBestMatch;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/search", kOOURL];
    NSDictionary *parameters = @{@"keyword":keyword,
                                 kKeySearchSort:[NSNumber numberWithUnsignedInteger:sort],
                                 kKeySearchRadius:[NSNumber numberWithUnsignedInteger:10000],
                                 kKeyRestaurantLatitude:[NSNumber numberWithFloat:location.latitude],
                                 kKeyRestaurantLongitude:[NSNumber numberWithFloat:location.longitude],
                                 kKeyRestaurantOpenNow:[NSNumber numberWithBool:openOnly]};
    
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
// Name:    getRestaurantsWithKeyword andFilter andLocation
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsWithKeyword:(NSString *)keyword
                                            andFilter:(NSString*)filterName
                                          andLocation:(CLLocationCoordinate2D)location
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(NSError *))failure
{
    if (!keyword || !filterName) {
        failure (nil);
        return nil;
    }
    
    double radius= [Settings sharedInstance].searchRadius;
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/search", kOOURL];
    NSDictionary *parameters = @{@"keyword":keyword,
                                 @"latitude":@(location.latitude),
                                 @"longitude":@(location.longitude),
                                 @"filter":filterName ?:@"",
                                 @"radius":@(radius)
                                 };
    
//    NSLog (@" URL = %@",urlString);
    NSLog  (@" radius = %f", radius);
    
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
// Name:    getUsersWithKeyword
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUsersWithKeyword:(NSString *)keyword
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(NSError *))failure
{
    if (!keyword  || !keyword.length) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/search/users", kOOURL];
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
                                   failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users", kOOURL];
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
                                    failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/dishes", kOOURL];
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
- (AFHTTPRequestOperation*)getListsOfUser:(NSUInteger)userID withRestaurant:(NSUInteger)restaurantID
                                  success:(void (^)(NSArray *lists))success
                                  failure:(void (^)(NSError *))failure
{
    if (!userID) {
        UserObject *userInfo= [Settings sharedInstance].userObject;
        userID = [userInfo.userID unsignedIntegerValue];
    }
    
    NSString *restaurantResource = @"";
    if (restaurantID) {
        restaurantResource = [NSString stringWithFormat:@"/restaurants/%ld", restaurantID];
    }
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%ld%@/lists",
                           kOOURL, userID, restaurantResource];
    
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
                                  failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists/%tu/restaurants/%tu",
                           kOOURL, listID, restaurantID];
    
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
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/emails/%@",
                           kOOURL, emailString];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        if ( [responseObject isKindOfClass:[NSDictionary class]]) {
            UserObject* user= [UserObject userFromDict: responseObject];
            if  (user ) {
                success ( user);
            } else {
                success ( nil);
            }
        }
    }
           failure:failure];
}

//------------------------------------------------------------------------------
// Name:    lookupUsername
// Purpose: Ascertain whether a username is already in use.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)lookupUsername:(NSString *)string
                                  success:(void (^)(bool exists))success
                                  failure:(void (^)(NSError *))failure;
{
    if (!string || !string.length) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/usernames/%@",
                           kOOURL, string];
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
        success ( users.count>0);
    }
           failure:failure];
}

//------------------------------------------------------------------------------
// Name:    clearUsernameOf
// Purpose: For testing.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)clearUsernameWithSuccess:(void (^)(NSArray *names))success
                                   failure:(void (^)(NSError *))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userID= userInfo.userID;
    
    NSString *requestString=[NSString stringWithFormat:@"https://%@/users/%@", kOOURL, userID];
    
    requestString= [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
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
                                  failure:(void (^)(NSError *))failure;
{
    if (!emailAddressString || !emailAddressString.length) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/usernames?email=%@",
                           kOOURL, emailAddressString];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:success failure:failure];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantsWithListID
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsWithListID:(NSUInteger)listID
                                            success:(void (^)(NSArray *restaurants))success
                                            failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists/%ld/restaurants",
                           kOOURL,
                           listID];
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
                                 failure:(void (^)(NSError *))failure
{
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/restaurants", kOOURL];
    
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
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError *))failure;
{
    if (!listName) {
        failure (nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userID= userInfo.userID;
    if (!userID) {
        failure (nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/lists", kOOURL, userID];
    NSDictionary*parameters = @{
                                 @"name":listName,
                                  @"type":@2,
                                  @"user":userID
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
// Name:    addRestaurantsToFavorites
// Purpose: Add restaurants to a user's favorites list
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addRestaurantsToFavorites:(NSArray *)restaurants
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError *))failure;
{
    NSMutableArray *restaurantIDs;
    if (!restaurants) {
        failure (nil);
        return nil;
    } else {
        restaurantIDs = [NSMutableArray array];
        [restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RestaurantObject *ro = (RestaurantObject *)obj;
            [restaurantIDs addObject:ro.restaurantID];
        }];
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userID= userInfo.userID;
    if (!userID) {
        failure (nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/favorites/restaurants", kOOURL, userID];
    
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
// Name:    addRestaurants:ToList
// Purpose: Add restaurants to a user's favorites list
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants toList:(NSUInteger)listId
                                              success:(void (^)(id response))success
                                              failure:(void (^)(NSError *))failure;
{
    if (!listId) {
        failure(nil);
        return nil;
    }
    
    NSMutableArray *restaurantIDs;
    if (!restaurants) {
        failure (nil);
        return nil;
    } else {
        restaurantIDs = [NSMutableArray array];
        [restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RestaurantObject *ro = (RestaurantObject *)obj;
            [restaurantIDs addObject:ro.restaurantID];
        }];
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userID= userInfo.userID;
    if (!userID) {
        failure (nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists/%tu/restaurants", kOOURL, listId];
    
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
                                                   failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/photos", kOOURL];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:identifier forKey:@"identifier"];
    
    if (maxWidth) {
        maxWidth = (isRetinaDisplay()) ? 2*maxWidth:maxWidth;
        [parameters setObject:[NSString stringWithFormat:@"%tu", maxWidth] forKey:@"maxwidth"];
    } else if (maxHeight) {
        maxHeight = (isRetinaDisplay()) ? 2*maxHeight:maxHeight;
        [parameters setObject:[NSString stringWithFormat:@"%tu", maxWidth] forKey:@"maxHeight"];
    }
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        success([responseObject objectForKey:@"link"]);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


+ (AFHTTPRequestOperation *)isFollowingUser:(UserObject *) user
                                    success:(void (^)(BOOL ))success
                                    failure:(void (^)(NSError *))failure;
{
    if (!user) {
        failure (nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *selfUserID= userInfo.userID;
    if (!selfUserID) {
        failure (nil);
        return nil;
    }
    NSNumber *otherUserID= user.userID;
    if (!otherUserID) {
        failure (nil);
        return nil;
    }
    if  ([selfUserID isEqualToNumber: otherUserID ] ) {
        NSLog  (@"CANNOT FOLLOW ONESELF.");
        success (NO);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/follow/%@", kOOURL, selfUserID,otherUserID];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               for (id dict in responseObject) {
                   UserObject *followee = [UserObject userFromDict:dict];
                   if ([followee.userID isEqualToNumber: otherUserID ] ) {
                       success (YES);
                       return;
                   }
               }
               success(NO);
           } failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure (error);
           }];
}


//------------------------------------------------------------------------------
// Name:    setFollowingUser
// Purpose: Specify whether the current user is following a specific other user.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)setFollowingUser:(UserObject *) user
                                                 to: (BOOL) following
                                            success:(void (^)(id responseObject))success
                                            failure:(void (^)(NSError *))failure;
{
    if (!user) {
        failure (nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *selfUserID= userInfo.userID;
    if (!selfUserID) {
        failure (nil);
        return nil;
    }
    NSNumber *otherUserID= user.userID;
    if (!otherUserID) {
        failure (nil);
        return nil;
    }
    if  ([selfUserID isEqualToNumber: otherUserID ] ) {
        NSLog  (@"CANNOT FOLLOW ONESELF.");
        failure (nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/following/%@", kOOURL, selfUserID,otherUserID];
    
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
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)setParticipationInEvent:(EventObject *)eo
                                                 to:(BOOL) participating
                                               success:(void (^)(NSInteger eventID))success
                                               failure:(void (^)(NSError *))failure;
{
    if (!eo) {
        failure (nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userID= userInfo.userID;
    if (!userID) {
        failure (nil);
        return nil;
    }
    NSInteger eventID= eo.eventID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%ld/users/%@", kOOURL, (unsigned long) eventID,userID];
    
    AFHTTPRequestOperation *op;
    if (participating) {
        NSLog (@"PATCH %@", urlString);
        op = [rm PATCH:urlString parameters:nil
                                       success:^(id responseObject) {
                                           NSInteger identifier= 0;
                                           if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                               NSNumber *eventID= ( (NSDictionary*)responseObject)[ @"event_id"];
                                               identifier= parseIntegerOrNullFromServer(eventID);
                                           }
                                           success(identifier);
                                       } failure:^(NSError *error) {
                                           failure(error);
                                       }];
    } else {
        NSLog (@"DELETE %@", urlString);
       op = [rm DELETE:urlString parameters:nil
                                        success:^(id responseObject) {
                                            NSInteger identifier= 0;
                                            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                NSNumber *eventID= ( (NSDictionary*)responseObject)[ @"event_id"];
                                                identifier= parseIntegerOrNullFromServer(eventID);
                                            }
                                            success(identifier);
                                        } failure:^(NSError *error) {
                                            failure(error);
                                        }];
        
    }
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    setParticipantsInEvent
// Purpose:
//------------------------------------------------------------------------------
#if 0
+ (AFHTTPRequestOperation *)setParticipantsInEvent:(EventObject *)eo
                                                 to: (NSArray*) participants
                                               success:(void (^)())success
                                               failure:(void (^)(NSError *))failure;
{
    if (!eo) {
        failure (nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userID= userInfo.userID;
    if (!userID) {
        failure (nil);
        return nil;
    }
    NSInteger eventID= eo.eventID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%ld/users", kOOURL, (unsigned long) eventID];
    
    AFHTTPRequestOperation *op;
    
    NSMutableArray *userids= [NSMutableArray new];
    for (UserObject* participant  in participants) {
        NSNumber *value=  participant.userID;
        if  (value ) {
            [userids addObject: value];
        }
    }
    
    op = [rm POST : urlString parameters: @{
                                          @"user_ids": userids
                                          }
         success:^(id responseObject) {
             NSInteger identifier= 0;
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSNumber *eventID= ( (NSDictionary*)responseObject)[ @"event_id"];
                 identifier= parseIntegerOrNullFromServer(eventID);
             }
             success();
         } failure:^(NSError *error) {
             failure(error);
         }];
    
    return op;
}
#endif

//------------------------------------------------------------------------------
// Name:    getParticipantsInEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getParticipantsInEvent:(EventObject *)eo
                                           success:(void (^)(NSArray*))success
                                           failure:(void (^)(NSError *))failure;
{
    if (!eo) {
        failure (nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userID= userInfo.userID;
    if (!userID) {
        failure (nil);
        return nil;
    }
    NSInteger eventID= eo.eventID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%ld/users", kOOURL, (unsigned long) eventID];
    
    AFHTTPRequestOperation *op;
    
    op = [rm GET : urlString parameters:nil
           success:^(id responseObject) {
               NSArray *array= responseObject;
               NSMutableArray *users= [NSMutableArray new];
               for (NSDictionary* d  in  array) {
                   UserObject* user= [UserObject userFromDict:d];
                   if  (user ) {
                       [users  addObject: user];
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
                failure:(void (^)(NSError *))failure;
{
    if (!image) {
        failure(nil);
        return ;
    }
    
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userID= userInfo.userID;
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/photos", kOOURL, userID];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[ NSURL  URLWithString:urlString]];
    if (!request) {
        failure (nil);
        return ;
    }
    [request setHTTPMethod:@"POST"];

    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    
    NSString*const boundary = @"WebKitFormBoundaryPnHdnY89ti1wsHcj";
    NSString*const filename=  @"file.jpg";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    //    [body appendData: [@"Accept-Language: en-US\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //    [body appendData: [@"Accept-Encoding: text/html\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]
        forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData new];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"%@\"\r\n",filename] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString* token= userInfo.backendAuthorizationToken;
    if  (token  &&  token.length ) {
        [body appendData: [[NSString stringWithFormat: @"Authorization: %@", token.lowercaseString ] dataUsingEncoding:NSUTF8StringEncoding]];
    }else {
        NSLog (@"NOT A PROBLEM FOR POST: MISSING BACKEND AUTHORIZATION TOKEN");
    }
    
     [body appendData:[[NSString stringWithFormat:@"%@\r\n", @"Some Caption"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=file.jpg\r\n", @"upload"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n",(int)[imageData length]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
//    NSLog  (@" body=  %s", [body bytes]);
    
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest: request
                                                         fromData: imageData
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    NSString *stringFromData= [NSString stringWithCharacters:[data  bytes] length:[ data length]];
                                                    NSLog  (@"stringFromData = %@",stringFromData);
                                                    
                                                    if (error) {
                                                        if (failure) failure(error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                        NSLog (@"IMAGE UPLOAD RESPONSE:  %ld", (long)httpResp.statusCode);
                                                        if (httpResp.statusCode == 200) {
                                                            if (success) success();
                                                        }else {
                                                            if (failure) failure(error);
                                                        }// NOTE:  typically error 400
                                                        
                                                    }
                                                }];
    [task resume];
}

//------------------------------------------------------------------------------
// Name:    uploadUserPhoto
// Purpose: This is the AFNetworking approach.
//------------------------------------------------------------------------------
+ (void)uploadUserPhoto_AFNetworking:(UIImage *)image
                success:(void (^)(void))success
                failure:(void (^)(NSError *))failure;
{
    if  (!image) {
        failure (nil);
        return ;
    }
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSNumber*userid= userInfo.userID;
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/photos", kOOURL, userid];
    
    OONetworkManager *nm = [OONetworkManager sharedRequestManager];
    nm.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    nm.requestManager.responseSerializer.acceptableContentTypes = [NSMutableSet setWithObjects:@"application/json", @"text/html", nil];
    
    NSString* token= userInfo.backendAuthorizationToken;
    if  (token  &&  token.length ) {
        [nm.requestManager.requestSerializer setValue:  token.lowercaseString forHTTPHeaderField:@"authorization"];
    }else {
        NSLog (@"NOT A PROBLEM FOR POST: MISSING BACKEND AUTHORIZATION TOKEN");
    }
    
    NSDictionary*params=  @{
                            };
    [nm.requestManager POST: urlString
                 parameters:params
  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      if(image){
          [formData appendPartWithFileData:UIImageJPEGRepresentation( image, 0.5) name:@"files"
                                  fileName:@"xyz.jpg" mimeType:@"image/jpeg"];
      }
  } success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog  (@" success");
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog  (@" failure %@",error);// NOTE:  typically error 500
  }];
}

//------------------------------------------------------------------------------
// Name:    getEventsForUser
// Purpose: Obtain a list of user events that are either complete or incomplete.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getEventsForUser:(NSUInteger) identifier
                                     success:(void (^)(NSArray *events))success
                                     failure:(void (^)(NSError *))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%lu/events",kOOURL, (unsigned long)identifier];
    
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
                                                failure:(void (^)(NSError *))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events",kOOURL];
    
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
            NSLog  (@"RESPONSE IS NOT AN ARRAY OF EVENTS.");
            failure(nil);
        }
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
        failure (error);
    }];
}

//------------------------------------------------------------------------------
// Name:    addRestaurant toEvent
// Purpose: Add a restaurant to an event.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
                                 toEvent:(EventObject *)event
                                  success:(void (^)(id response))success
                                  failure:(void (^)(NSError *))failure;
{
    if (!event  || !restaurant) {
        failure (nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSNumber *userid = userInfo.userID;
    if (!userid) {
        failure (nil);
        return nil;
    }
    NSString *identifier = restaurant.restaurantID;
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
    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%ld/restaurants", kOOURL,
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
// Name:    addEvent
// Purpose: Create a new event and receive in return the new event's ID.
// Note:    The event does not need to be completely described in the EventObject.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)addEvent:(EventObject *)eo
                               success:(void (^)(NSInteger eventID))success
                               failure:(void (^)(NSError *))failure;
{
    if (!eo) {
        failure (nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userid= userInfo.userID;
    if (!userid) {
        failure (nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/events", kOOURL, userid];
    
    NSDictionary *parameters= [eo dictionaryFromEvent];
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      NSInteger identifier= 0;
                                      if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                          NSNumber *eventID= ( (NSDictionary*)responseObject)[ @"event_id"]; 
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
                             failure:(void (^)(NSError *))failure;
{
    if (!eo) {
        failure (nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userid= userInfo.userID;
    if (! userid) {
        failure (nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/events", kOOURL, userid];
    
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
                                            failure:(void (^)(NSError *))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userid= userInfo.userID;
    if (!userid) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/followers", kOOURL, userid];
    
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
        failure (error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getFollowingWithSuccess
// Purpose: Fetch an array of users that the current user is following.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFollowingWithSuccess:(void (^)(NSArray *users))success
                                            failure:(void (^)(NSError *))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userid= userInfo.userID;
    if (!userid) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/following", kOOURL, userid];
    
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
               failure (error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getGroupsWithSuccess
// Purpose: Fetch an array of groups of which the current user is a member .
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getGroupsWithSuccess:(void (^)(NSArray *groups))success
                                            failure:(void (^)(NSError *))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userid= userInfo.userID;
    if (!userid) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/groups",
                           kOOURL, userid];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *groups = [NSMutableArray array];
               for (id object in responseObject) {

                   if ( [ object isKindOfClass:[NSDictionary class]]) {
                       [groups  addObject:[GroupObject groupFromDictionary:object]];
                   }
               }
               
               NSLog  (@"TOTAL GROUPS FOUND: %ld", groups.count);
               success(groups);
           }
           failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure (error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getUsersOfGroup
// Purpose: Fetch an array of users who belong to a specified group.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUsersOfGroup: (NSInteger)groupID
                                    success:(void (^)(NSArray *groups))success
                                    failure:(void (^)(NSError *))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userid= userInfo.userID;
    if (!userid) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/groups/%ld/users",
                           kOOURL, groupID];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *users = [NSMutableArray array];
               for (id object in responseObject) {
                   
                   if ( [ object isKindOfClass:[NSDictionary class]]) {
                       [users  addObject:  [UserObject userFromDict: object]];
                   }
               }
               
               NSLog  (@"TOTAL USERS FOUND: %ld", users.count);
               success(users);
           }
           failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
               failure (error);
           }];
}

//------------------------------------------------------------------------------
// Name:    determineIfCurrentUserCanEditEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)determineIfCurrentUserCanEditEvent:(EventObject *) event
                                                       success:(void (^)(bool))success
                                                       failure:(void (^)(NSError *))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSNumber *userID = userInfo.userID;
    if (!userID) {
        failure (nil);
        return nil;
    }

    NSString *urlString = [NSString stringWithFormat:@"https://%@/events/%ld/users/%@",
                           kOOURL,
                           event.eventID,
                           userID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    AFHTTPRequestOperation *operation = [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               if ([responseObject isKindOfClass:[NSDictionary class]]) {
                   UserObject *user= [UserObject userFromDict:responseObject];
                   if (user &&
                        (user.participantType == PARTICIPANT_TYPE_ADMIN ||
                         user.participantType == PARTICIPANT_TYPE_CREATOR)
                       ) {
                       success (YES);
                       return;
                   }
               }
               success(NO);
           }
           failure:^(NSError *error) {
               NSInteger statusCode = operation.response.statusCode;
               if (statusCode == 404) {
                   success (NO);
               } else {
                   NSLog(@"Error: %@", error);
                   failure (error);
               }
           }];
    
    return operation;
}

@end

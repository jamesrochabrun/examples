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
#import "VoteObject.h"
#import "FeedObject.h"
#import "TagObject.h"
#import "AutoCompleteObject.h"

NSString *const kKeySearchRadius = @"radius";
NSString *const kKeySearchSort = @"sort";
NSString *const kKeySearchFilter = @"filter";

NSString *const kKeyRestaurantIDs = @"restaurant_ids";
NSString *const kKeyUserIDs = @"user_ids";
NSString *const kKeyEventIDs = @"event_ids";
NSString *const kKeyTagIDs = @"tag_ids";

@interface OOAPI()
- (NSString *)ooURL;
@end

@implementation OOAPI

static NSArray*autoCompleteWhiteList= nil;
static NSArray*autoCompleteBlackList= nil;
static NSArray* autoCompleteSpecificNonfoodCompanies= nil;
static NSArray*autoCompleteSpecificFoodCompanies= nil;

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
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/restaurants", kHTTPProtocol, [self ooURL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *restaurants = [NSMutableArray array];
        for (id dict in responseObject) {
            //NSLog(@"rest name: %@", [RestaurantObject restaurantFromDict:dict].name);
            [restaurants addObject:[RestaurantObject restaurantFromDict:dict]];
        }
        success(restaurants);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantMediaItems
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getMediaItemsForRestaurant:(RestaurantObject *)restaurant
                                               success:(void (^)(NSArray *mediaItems))success
                                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/restaurants/%lu/photos", kHTTPProtocol, [self ooURL], ( unsigned long) restaurant.restaurantID];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *mediaItems = [NSMutableArray array];
        for (id dict in responseObject) {
            [mediaItems addObject:[MediaItemObject mediaItemFromDict:dict]];
        }
        success(mediaItems);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantsWithIDs
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantWithID:(NSString *)restaurantId source:(NSUInteger)source
                                        success:(void (^)(RestaurantObject *))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if (!restaurantId) return nil;
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/restaurants/%@?source=%lu", kHTTPProtocol, [self ooURL],
                           restaurantId,( unsigned long) source];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        //        NSMutableArray *restaurants = [NSMutableArray array];
        //        for (id dict in responseObject) {
        //            NSLog(@"rest name: %@", [RestaurantObject restaurantFromDict:dict].name);
        //            [restaurants addObject:[RestaurantObject restaurantFromDict:dict]];
        //        }
        RestaurantObject *restaurant = [RestaurantObject restaurantFromDict:responseObject];
        success(restaurant);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
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
                                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/restaurants/photos", kHTTPProtocol, [self ooURL]];
    
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
    }];
}

- (AFHTTPRequestOperation *)getRestaurantImageWithMediaItem:(MediaItemObject *)mediaItem
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *link))success
                                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/restaurants/photos", kHTTPProtocol, [self ooURL]];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (maxWidth) {
        maxWidth = (isRetinaDisplay()) ? 2*maxWidth:maxWidth;
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)maxWidth] forKey:@"maxwidth"];
    } else if (maxHeight) {
        maxHeight = (isRetinaDisplay()) ? 2*maxHeight:maxHeight;
        [parameters setObject:[NSString stringWithFormat:@"%lu", ( unsigned long) maxWidth] forKey:@"maxHeight"];
    }
    
    if (mediaItem.reference && mediaItem.source == kMediaItemTypeGoogle) {
        [parameters setObject:mediaItem.reference forKey:kKeyMediaItemReference];
    } else if (mediaItem.url && mediaItem.source == kMediaItemTypeOomami) {
        success(mediaItem.url);
        return nil;
    }

    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        success([responseObject objectForKey:@"link"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantsWithKeyword andLocation
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsWithKeywords:(NSArray *)keywords
                                          andLocation:(CLLocationCoordinate2D)location
                                            andFilter:(NSString*)filterName
                                             andRadius:(CGFloat)radius
                                          andOpenOnly:(BOOL)openOnly
                                              andSort:(SearchSortType)sort
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableString *searchTerms = [[NSMutableString alloc] init];
    
    if (!keywords || ![keywords count]) {
        failure(nil,nil);
        return nil;
    } else {
        [keywords enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *s = [NSString stringWithFormat:@"(%@)", (NSString *)obj];
            if ([searchTerms length]) {
                [searchTerms appendString:@"OR"];
            }
            [searchTerms appendString:s];
        }];
    }
    
    if (!filterName) {
        filterName = @"";
    }
    
    if (!sort) {
        sort = kSearchSortTypeBestMatch;
    }
    
    if (!radius) {
        radius = [Settings sharedInstance].searchRadius;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/search", kHTTPProtocol, [OOAPI URL]];
    NSDictionary *parameters = @{@"keyword":searchTerms,
                                 kKeySearchSort:[NSNumber numberWithUnsignedInteger:sort],
                                 kKeySearchRadius:[NSNumber numberWithUnsignedInteger:radius],
                                 kKeyRestaurantLatitude:[NSNumber numberWithFloat:location.latitude],
                                 kKeyRestaurantLongitude:[NSNumber numberWithFloat:location.longitude],
//                                 kKeyRestaurantLatitude:[NSNumber numberWithFloat:37.773972],
//                                 kKeyRestaurantLongitude:[NSNumber numberWithFloat:-122.431297],
                                 kKeyRestaurantOpenNow:[NSNumber numberWithBool:openOnly]
//                                 kKeySearchFilter:filterName// Not used by backend.
                                 };
    
    NSLog(@"search URL = %@", urlString);
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        NSMutableArray *restaurants = [NSMutableArray array];
        for (id dict in responseObject) {
            //NSLog(@"rest name: %@", [RestaurantObject restaurantFromDict:dict].name);
            [restaurants addObject:[RestaurantObject restaurantFromDict:dict]];
        }
        success(restaurants);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSInteger statusCode= operation.response.statusCode;
        NSLog(@"Error: %@, status code %ld", error, statusCode);
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *) getAutoCompleteDataForString: (NSString*)string
                                                 location: (CLLocationCoordinate2D)location
                                                  success:(void (^)(NSArray *results))success
                                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self setUpAutoCompleteLists];
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/autocomplete?input=%@&latitude=%g&longitude=%g",
                           kHTTPProtocol,
                           [OOAPI URL],
                           string,
                           ( float) location.latitude, ( float) location.longitude];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *autoCompleteItems = [NSMutableArray array];
               for (id dict in responseObject) {
                   NSString *desc= dict[@"description"];
                   int include=0;
                   NSArray *chunks= [[desc lowercaseString] componentsSeparatedByString:@","];
               
                   if  (chunks.count ) {
                       NSString *firstChunk=[chunks[0] lowercaseString];
                       
                       for (NSString* string  in  autoCompleteSpecificNonfoodCompanies) {
                           if ( [ firstChunk isEqualToString: string]) {
                               include= -1;
                               break;
                           }
                       }
                       if  (include >= 0 ) {
                           NSArray *words= [firstChunk componentsSeparatedByString:@" "];
                           for (NSString* string  in  words) {
                               if ( [ autoCompleteWhiteList containsObject: string]) {
                                   include= 1;
                                   break;
                               }
                           }
                           if  (! include ) {
                               for (NSString* string  in  words) {
                                   if ( [ autoCompleteBlackList containsObject: string]) {
                                       include= -1;
                                       break;
                                   }
                               }
                           }
                       }
                       
                       if  (include !=  -1 ) {
                           AutoCompleteObject *item = [AutoCompleteObject autoCompleteObjectFromDictionary: dict];
                           if (item) {
                               NSLog(@"parsed auto complete item: %@", item.desc);
                               [autoCompleteItems addObject: item];
                           }
                       }
                   }
               }
               success(autoCompleteItems);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getFeedItems
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFeedItemsWithSuccess:(void (^)(NSArray *feedItems))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
        
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/feed", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *feedItems = [NSMutableArray array];
               for (id dict in responseObject) {
                   FeedObject *item = [FeedObject feedObjectFromDictionary:dict];
                   if (item) {
                       NSLog(@"parsed feed item: %@", item.verb);
                       [feedItems addObject: item];
                   }
               }
               success(feedItems);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getAllUsers
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getAllUsersWithSuccess:(void (^)(NSArray *users))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users", kHTTPProtocol, [OOAPI URL]];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *users = [NSMutableArray array];
        for (id dict in responseObject) {
            UserObject *u= [UserObject userFromDict:dict];
            if (u) {
                NSLog(@"FOUND USER: %@", u.username);
                [users addObject:u];
            }
        }
        success(users);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
        failure(operation, error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getUsersWithKeyword
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUsersWithKeyword:(NSString *)keyword
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if (!keyword  || !keyword.length) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/search/users", kHTTPProtocol, [OOAPI URL]];
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
}

//------------------------------------------------------------------------------
// Name:    lookupUserByID
// Purpose:
//------------------------------------------------------------------------------

+ (AFHTTPRequestOperation *)lookupUserByID:(NSUInteger)userID
                                   success:(void (^)(UserObject *user))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if  (!userID) {
        failure (nil,nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:  nil
           success:^(id responseObject) {
               UserObject *user= [UserObject userFromDict: responseObject];
              
               success(user);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getDishesWithIDs
// Purpose:
//------------------It's------------------------------------------------------------
- (AFHTTPRequestOperation*)getDishesWithIDs:(NSArray *)dishIDs
                                    success:(void (^)(NSArray *dishes))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/dishes", kHTTPProtocol, [OOAPI URL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        for (id dict in responseObject) {
            NSLog(@"dish: %@", dict);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
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
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *restaurantResource = @"";
    if (restaurantID) {
        restaurantResource = [NSString stringWithFormat:@"/restaurants/%ld", (long)restaurantID];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%ld%@/lists", kHTTPProtocol,
                           [OOAPI URL], (long)userID, restaurantResource];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *lists = [NSMutableArray array];
        for (id dict in responseObject) {
            [lists addObject:[ListObject listFromDict:dict]];
        }
        success(lists);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        ;
    }];
}

//------------------------------------------------------------------------------
// Name:    deleteRestaurant:fromList
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)deleteRestaurant:(NSUInteger)restaurantID fromList:(NSUInteger)listID
                                     success:(void (^)(NSArray *lists))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%lu/restaurants/%lu", kHTTPProtocol,
                           [OOAPI URL], (unsigned long)listID, (unsigned long)restaurantID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm DELETE:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *lists = [NSMutableArray array];
        success(lists);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
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
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure;
{
    if (!emailString || !emailString.length) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/emails/%@", kHTTPProtocol,
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
        failure(operation, error);
    }
            ];
}

//------------------------------------------------------------------------------
// Name:    deleteList
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)deleteList:(NSUInteger)listID
                               success:(void (^)(NSArray *))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%lu", kHTTPProtocol,
                           [OOAPI URL], (unsigned long)listID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm DELETE:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *lists = [NSMutableArray array];
        success(lists);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        ;
    }];
}

//------------------------------------------------------------------------------
// Name:    lookupUsername
// Purpose: Ascertain whether a username is already in use.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)lookupUsername:(NSString *)string
                                   success:(void (^)(BOOL exists))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure;
{
    if (!string || !string.length) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/usernames/%@", kHTTPProtocol,
                           [OOAPI URL], string];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSArray *array = responseObject;
        NSMutableArray *users = [NSMutableArray new];
        for (NSDictionary* d  in  array) {
            UserObject *user = [UserObject userFromDict:d];
            if  (user) {
                [users addObject: user];
            }
        }
        success( users.count>0);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
        failure(operation, error);
    }
            ];
}

//------------------------------------------------------------------------------
// Name:    clearUsernameOf
// Purpose: For testing.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)clearUsernameWithSuccess:(void (^)(NSArray *names))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    
    NSString *requestString =[NSString stringWithFormat:@"%@://%@/users/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    
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
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!emailAddressString || !emailAddressString.length) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/usernames?email=%@", kHTTPProtocol,
                           [OOAPI URL], emailAddressString];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure(operation, error);
    } ];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantsWithListID
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsWithListID:(NSUInteger)listID
                                             success:(void (^)(NSArray *restaurants))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%ld/restaurants", kHTTPProtocol,
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
    
    
    //return [rm GET:urlString parameters:nil success:success failure:failure];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantsWithListID
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsFromSystemList:(ListType)systemListType
                                             success:(void (^)(NSArray *restaurants))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *type;
    if (systemListType == kListTypePopular) {
        type=@"popular";
    } else if (systemListType == kListTypeTrending) {
        type =@"trending";
    } else {
        failure(nil, nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%@", kHTTPProtocol, [OOAPI URL], type];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *restaurants = [NSMutableArray array];
        if ([responseObject count]) {
            for (id dict in responseObject) {
                [restaurants addObject:[RestaurantObject restaurantFromDict:dict]];
            }
        }
        success(restaurants);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
}

//------------------------------------------------------------------------------
// Name:    addRestaurant
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
                                  success:(void (^)(NSArray *dishes))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/restaurants", kHTTPProtocol, [OOAPI URL]];
    
    AFHTTPRequestOperation *op = [rm POST:urlString
                               parameters:[RestaurantObject dictFromRestaurant:restaurant]
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    addList
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addList:(NSString *)listName
                            success:(void (^)(ListObject *listObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!listName) {
        failure(nil,nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/lists", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    NSDictionary *parameters = @{
                                 @"name":listName,
                                 @"type":[NSString stringWithFormat:@"%d", kListTypeUser],
                                 @"user": @(userID)
                                 };
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      ListObject *l = [ListObject listFromDict:responseObject];
                                      success(l);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    addRestaurants:ToList
// Purpose: Add restaurants to a user's favorites list
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants toList:(NSUInteger)listID
                                   success:(void (^)(id response))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSMutableArray *restaurantIDs;
    if (!restaurants || !listID) {
        failure(nil,nil);
        return nil;
    } else {
        restaurantIDs = [NSMutableArray array];
        [restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RestaurantObject *ro = (RestaurantObject *)obj;
            [restaurantIDs addObject:[NSString stringWithFormat:@"%lu", (unsigned long)ro.restaurantID]];
        }];
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID= userInfo.userID;
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%lu/restaurants", kHTTPProtocol, [OOAPI URL], (unsigned long)listID];
    
    NSString *IDs = [restaurantIDs componentsJoinedByString:@","];
    NSDictionary *parameters = @{
                                 kKeyRestaurantIDs: [NSString stringWithFormat:@"[%@]", IDs]
                                 };
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    
    return op;
}


//------------------------------------------------------------------------------
// Name:    addRestaurantsToSpecialList:listType
// Purpose: Add restaurants to a user's favorites list
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addRestaurantsToSpecialList:(NSArray *)restaurants listType:(ListType)listType
                                                success:(void (^)(id response))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSMutableArray *restaurantIDs;
    if (!restaurants) {
        failure(nil,nil);
        return nil;
    } else {
        restaurantIDs = [NSMutableArray array];
        [restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RestaurantObject *ro = (RestaurantObject *)obj;
            [restaurantIDs addObject:[NSString stringWithFormat:@"%lu", (unsigned long)ro.restaurantID]];
        }];
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID= userInfo.userID;
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    NSString *urlString;
    if (listType == kListTypeFavorites) {
        urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/favorites/restaurants", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    } else if (listType == kListTypeToTry) {
        urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/totry/restaurants", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    } else {
        failure(nil,nil);
        return nil;
    }
    
    NSString *IDs = [restaurantIDs componentsJoinedByString:@","];
    NSDictionary *parameters = @{
                                 kKeyRestaurantIDs: [NSString stringWithFormat:@"[%@]", IDs]
                                 };
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
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
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/photos", kHTTPProtocol, [OOAPI URL]];
    
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
    }];
}

+ (AFHTTPRequestOperation *)isFollowingUser:(UserObject *)user
                                    success:(void (^)(BOOL))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!user) {
        failure(nil,nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger selfUserID = userInfo.userID;
    if (!selfUserID) {
        failure(nil,nil);
        return nil;
    }
    NSUInteger otherUserID = user.userID;
    if (!otherUserID) {
        failure(nil,nil);
        return nil;
    }
    if  (selfUserID ==otherUserID ) {
        NSLog  (@"CANNOT FOLLOW ONESELF.");
        success(NO);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/follow/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)selfUserID,(unsigned long)otherUserID];
    
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
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    setFollowingUser
// Purpose: Specify whether the current user is following a specific other user.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)setFollowingUser:(UserObject *) user
                                          to: (BOOL) following
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!user) {
        failure(nil,nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger selfUserID= userInfo.userID;
    if (!selfUserID) {
        failure(nil,nil);
        return nil;
    }
    NSUInteger otherUserID= user.userID;
    if (!otherUserID) {
        failure(nil,nil);
        return nil;
    }
    if  (selfUserID == otherUserID  ) {
        NSLog  (@"CANNOT FOLLOW ONESELF.");
        failure(nil,nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    AFHTTPRequestOperation *op;
    if (following) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/followees", kHTTPProtocol, [OOAPI URL], (unsigned long)selfUserID];
        op = [rm POST: urlString parameters: @{
                                               @"user_id": @(otherUserID)
                                              }
             success:^(id responseObject) {
                 success(responseObject);
             } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                 failure(operation, error);
             }];
    } else {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/followees/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)selfUserID,(unsigned long)otherUserID];
        op = [rm DELETE: urlString parameters:nil
                success:^(id responseObject) {
                    success(responseObject);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                    failure(operation, error);
                }];
        
    }
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    setParticipationInEvent
// Purpose:
// Note:    If user is nil then it is the current user.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)setParticipationOf:(UserObject *)user
                                       inEvent:(EventObject *)event
                                            to:(BOOL) participating
                                       success:(void (^)(NSInteger eventID))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!event ) {
        failure(nil,nil);
        return nil;
    }
    
    UserObject *userInfo= [Settings sharedInstance].userObject;
    if (!user) {
        user= userInfo;
    }
    NSUInteger userID= user.userID;
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    
    NSUInteger eventID= event.eventID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    AFHTTPRequestOperation *op;
    if ( participating) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu/users",
                               kHTTPProtocol, [OOAPI URL],
                               (unsigned long)eventID  ];
        NSLog (@"POST %@", urlString);
        op = [rm POST:urlString parameters: @{
                                              @"user_ids": @[@(user.userID)],
                                               @"participant_state":@1
                                               }
              
               success:^(id responseObject) {
                   NSInteger identifier= 0;
                   if ([responseObject isKindOfClass:[NSDictionary class]]) {
                       NSNumber *eventID= ((NSDictionary *)responseObject)[ @"event_id"];
                       identifier= parseIntegerOrNullFromServer(eventID);
                   }
                   success(identifier);
               } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                   failure(operation, error);
               }];
    } else {
        
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu/users/%lu",
                               kHTTPProtocol, [OOAPI URL],
                               (unsigned long)eventID ,
                               (unsigned long)user.userID];
        NSLog (@"DELETE %@", urlString);
        op = [rm DELETE:urlString parameters: nil
              success:^(id responseObject) {
                  NSInteger identifier= 0;
                  if ([responseObject isKindOfClass:[NSDictionary class]]) {
                      NSNumber *eventID= ((NSDictionary *)responseObject)[ @"event_id"];
                      identifier= parseIntegerOrNullFromServer(eventID);
                  }
                  success(identifier);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                  failure(operation, error);
              }];
    }
 
    
    return op;
}

+ (AFHTTPRequestOperation *)getVenuesForEvent:(EventObject *)eo
                                      success:(void (^)(NSArray *venues))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!eo) {
        failure(nil,nil);
        return nil;
    }
    NSInteger eventID = eo.eventID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%ld/restaurants", kHTTPProtocol, [OOAPI URL], (unsigned long)eventID];
    
    AFHTTPRequestOperation *op;
    
    op = [rm GET:urlString parameters:nil
          success:^(id responseObject) {
              NSArray *array = responseObject;
              NSMutableArray *venues= [NSMutableArray new];
              for (NSDictionary *d in array) {
                  RestaurantObject *venue = [RestaurantObject restaurantFromDict:d];
                  if (venue) {
                      [venues addObject:venue];
                  }
              }
              success(venues);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
              // RULE: Leave the venues unchanged.
              failure(operation, error);
          }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    getFolloweesForRestaurant
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFolloweesForRestaurant:(RestaurantObject *)restaurant
                                              success:(void (^)(NSArray *users))success
                                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!restaurant) {
        failure(nil,nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    NSInteger restaurantID = restaurant.restaurantID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/restaurants/%lu/followees", kHTTPProtocol, [OOAPI URL], (unsigned long)userID, (long)restaurantID];
    
    AFHTTPRequestOperation *op;
    
    op = [rm GET:urlString parameters:nil
          success:^(id responseObject) {
              NSArray *array = responseObject;
              NSMutableArray *users = [NSMutableArray new];
              for (NSDictionary *d in array) {
                  UserObject *user = [UserObject userFromDict:d];
                  if (user) {
                      [users addObject:user];
                  }
              }
              success(users);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
              failure(operation, error);
          }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    getParticipantsInEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getParticipantsInEvent:(EventObject *)eo
                                           success:(void (^)(NSArray *users))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!eo) {
        failure(nil,nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    NSInteger eventID = eo.eventID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu/users", kHTTPProtocol, [OOAPI URL], (unsigned long)eventID];
    
    AFHTTPRequestOperation *op;
    
    op = [rm GET:urlString parameters:nil
          success:^(id responseObject) {
              NSArray *array = responseObject;
              NSMutableArray *users= [NSMutableArray new];
              for (NSDictionary *d in array) {
                  UserObject *user = [UserObject userFromDict:d];
                  if (user) {
                      [users addObject:user];
                  }
              }
              success(users);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
              failure(operation, error);
          }];
    
    return op;
}

+ (AFHTTPRequestOperation *)getTagsForUser:(NSUInteger)userID
                                success:(void (^)(NSArray *tags))success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    NSString *urlString;
    if (userID) {
        urlString= [NSString stringWithFormat:@"%@://%@/users/%lu/tags", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    } else {
        urlString= [NSString stringWithFormat:@"%@://%@/tags", kHTTPProtocol, [OOAPI URL]];
    }
    
    AFHTTPRequestOperation *op;
    
    op = [rm GET:urlString parameters:nil
          success:^(id responseObject) {
              NSArray *array = responseObject;
              NSMutableArray *tags= [NSMutableArray new];
              for (NSDictionary *d in array) {
                  TagObject *tag = [TagObject tagFromDict:d];
                  if (tag) {
                      [tags addObject:tag];
                  }
              }
              success(tags);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
              failure(operation, error);
          }];
    
    return op;
}


+ (AFHTTPRequestOperation *)unsetTag:(NSUInteger)tagID
                             forUser:(NSUInteger)userID
                                   success:(void (^)())success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if  (!userID || !tagID) {
        failure (nil,nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/tags/%lu",
                           kHTTPProtocol, [OOAPI URL], (unsigned long)userID, (unsigned long)tagID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm DELETE:urlString parameters:nil success:^(id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)setTag:(NSUInteger)tagID
                           forUser:(NSUInteger)userID
                                     success:(void (^)())success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if  (!userID || !tagID) {
        failure (nil,nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/tags",
                           kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    
    NSDictionary *parameters = @{kKeyTagIDs : [NSString stringWithFormat:@"[%lu]", (unsigned long)tagID]};
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    
    return op;
}


//------------------------------------------------------------------------------
// Name:    uploadPhoto
// Purpose: This is the AFNetworking approach.
//------------------------------------------------------------------------------
+ (void)uploadPhoto:(UIImage *)image
      forObject:(id)object
                success:(void (^)(void))success
                failure:(void (^)( NSError *error))failure;
{
    if (!image || !object) {
        failure(nil);
        return ;
    }
    
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    NSLog(@"img dims = %@", NSStringFromCGSize(image.size));
    NSLog(@"img size = %lu bytes",(unsigned long)[imageData length]);

    NSDictionary *parameters;
    
    if ([object isKindOfClass:[RestaurantObject class]]) {
        RestaurantObject *restaurant = (RestaurantObject *)object;
        parameters = @{kKeyRestaurantRestaurantID : [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.restaurantID]};
    } else if ([object isKindOfClass:[UserObject class]]) {
        UserObject *user = (UserObject *)object;
        parameters = @{kKeyUserID : [NSString stringWithFormat:@"%lu", (unsigned long)user.userID]};
    } else if ([object isKindOfClass:[ListObject class]]) {
        ListObject *list = (ListObject *)object;
        parameters = @{kKeyListID : [NSString stringWithFormat:@"%lu", (unsigned long)list.listID]};
    } else if ([object isKindOfClass:[EventObject class]]) {
        EventObject *event = (EventObject *)object;
        parameters = @{kKeyEventEventID : [NSString stringWithFormat:@"%lu", (unsigned long)event.eventID]};
    } else {
        NSLog(@"Unhandled object type in photo upload %@", [object class]);
        failure(nil);
        return;
    }
    
    AFHTTPRequestOperation *op;
    
    op = [rm POST:[NSString stringWithFormat:@"%@://%@/users/%lu/photos", kHTTPProtocol, [OOAPI URL], (unsigned long)userID] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"upload" fileName:@"photo.png" mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        failure(error);
    }];
    [op start];
}

//------------------------------------------------------------------------------
// Name:    uploadPhoto
// Purpose: This is the native approach.
// Note:    This uploads the image for the current user.
//------------------------------------------------------------------------------

// Might as well use the AFnetworking approach until we find problem with it
+ (void)uploadPhoto:(UIImage *)image
                 to: (UploadDestination )destination
         identifier: (NSUInteger) identifier
            success:(void (^)(void))success
            failure:(void (^)( NSError *error))failure;
{
    if (!image) {
        failure(nil);
        return ;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSLog (@"IMAGE DIMENSIONS=  %@", NSStringFromCGSize(image.size));
    NSLog (@"JPEG IMAGE SIZE=  %lu bytes",(unsigned long)[imageData length]);
    [APP.diagnosticLogString appendFormat: @"IMAGE DIMENSIONS=  %@\r", NSStringFromCGSize(image.size)];
    [APP.diagnosticLogString appendFormat:@"JPEG IMAGE SIZE=  %lu bytes\r",(unsigned long)[imageData length]];
    
    NSString *urlString= nil;
    NSString *postParameter=  @"";
    UserObject *userInfo= [Settings sharedInstance].userObject;
    switch ( destination) {
        case UPLOAD_DESTINATION_USER_PROFILE:
            postParameter= @"user_id";
            if ( !identifier) {
                identifier=  userInfo.userID;
            }
            urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/photos", kHTTPProtocol, [OOAPI URL], (unsigned long) identifier];
            break;
            
        case UPLOAD_DESTINATION_RESTAURANT:
            postParameter= @"restaurant_id";
            urlString = [NSString stringWithFormat:@"%@://%@/restaurants/%lu/photos", kHTTPProtocol, [OOAPI URL], (unsigned long) identifier];
            break;
            
        case UPLOAD_DESTINATION_EVENT:
            postParameter= @"event_id";
            urlString = [NSString stringWithFormat:@"%@://%@/events/%lu/photos", kHTTPProtocol, [OOAPI URL], (unsigned long) identifier];
            break;
            
        case UPLOAD_DESTINATION_LIST:
            postParameter= @"list_id";
            urlString = [NSString stringWithFormat:@"%@://%@/lists/%lu/photos", kHTTPProtocol, [OOAPI URL], (unsigned long) identifier];
            break;
            
        case UPLOAD_DESTINATION_GROUP:
            postParameter= @"group_id";
            urlString = [NSString stringWithFormat:@"%@://%@/groups/%lu/photos", kHTTPProtocol, [OOAPI URL], (unsigned long) identifier];
            break;
            
        case UPLOAD_DESTINATION_DIAGNOSTIC:
            postParameter= @"diagnostic";
            urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/diagnostic", kHTTPProtocol, [OOAPI URL], (unsigned long) userInfo.userID];
            break;
    }
    
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
    
    // Add the userid as a POST parameter.
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", postParameter] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%lu\r\n", (unsigned long) identifier] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // All done.
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", ( unsigned long) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                if (error) {
                                                    if (failure)
                                                        failure(error);
                                                } else {
                                                    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                    NSLog (@"IMAGE UPLOAD RESPONSE:  %ld", (long)httpResp.statusCode);
                                                    if (httpResp.statusCode == 200) {
                                                        if (success) success();
                                                    }else {
                                                        if (failure)
                                                            failure(nil);
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
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if  (!eventID) {
        failure (nil,nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu",
                           kHTTPProtocol, [OOAPI URL], (unsigned long)eventID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm DELETE:urlString parameters:nil success:^(id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getEventsForUser
// Purpose: Obtain a list of user events that are either complete or incomplete.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getEventsForUser:(NSUInteger) identifier
                                     success:(void (^)(NSArray *events))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/events", kHTTPProtocol, [OOAPI URL], (unsigned long)identifier];
    
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
                   failure(nil,nil);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getEventByID
// Purpose: Obtain a list of user events that are either complete or incomplete.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getEventByID:(NSUInteger)identifier
                                 success:(void (^)(EventObject *event))success
                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)identifier];
    
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
                   failure(nil,nil);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getCuratedEventsWithSuccess
// Purpose: Obtain a list of curated events that are complete.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getCuratedEventsWithSuccess:(void (^)(NSArray *events))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events", kHTTPProtocol, [OOAPI URL]];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
//        NSLog  (@"RESPONSE TO EVENTS QUERY: %@",responseObject);
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
            failure(nil,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
        failure(operation, error);
    }];
}

//------------------------------------------------------------------------------
// Name:    addRestaurant toEvent
// Purpose: Add a restaurant to an event.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)addRestaurant:(RestaurantObject *)restaurant
                                  toEvent:(EventObject *)event
                                  success:(void (^)(id response))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!event || !restaurant) {
        failure(nil,nil);
        return nil;
    }
    
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userid = userInfo.userID;
    if (!userid) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *identifier = [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.restaurantID];
    NSString *googleIdentifier = restaurant.googleID;
    NSMutableDictionary* parameters = @{}.mutableCopy;
    
    if (identifier) {
        [parameters setObject:identifier forKey:kKeyRestaurantIDs];
    }
    else if (googleIdentifier.length) {
        [parameters setObject:googleIdentifier forKey:kKeyRestaurantGoogleID];
    }
    else {
        NSLog (@"MISSING VENUE IDENTIFIER");
        failure(nil,nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu/restaurants", kHTTPProtocol, [OOAPI URL],
                           (unsigned long)event.eventID];
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
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
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!event  || !restaurant) {
        failure( nil,nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userid = userInfo.userID;
    if (!userid) {
        failure(nil,nil);
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
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu/restaurants", kHTTPProtocol, [OOAPI URL],
                           (unsigned long)event.eventID];
    
    AFHTTPRequestOperation *op = [rm DELETE: urlString parameters:parameters
                                    success:^(id responseObject) {
                                        success(responseObject);
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                        failure(operation, error);
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
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!eo) {
        failure(nil,nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (!userid) {
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/events", kHTTPProtocol, [OOAPI URL], (unsigned long)userid];
    
    NSDictionary *parameters= [eo dictionaryFromEvent];
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      NSInteger identifier= 0;
                                      if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                          NSNumber *eventID= ((NSDictionary *)responseObject)[@"event_id"];
                                          identifier= parseIntegerOrNullFromServer(eventID);
                                      }
                                      if (!identifier) {
                                          failure(nil,nil);
                                          return;
                                      }
                                      success(identifier);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
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
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!eo) {
        failure(nil,nil);
        return nil;
    }
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (! userid) {
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu", kHTTPProtocol, [OOAPI URL],  (unsigned long)eo.eventID];
    
    NSDictionary *parameters= [eo dictionaryFromEvent];
    
    AFHTTPRequestOperation *op = [rm PUT:urlString parameters:parameters
                                 success:^(id responseObject) {
                                     success(responseObject);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                     failure(operation, error);
                                 }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    getFollowers…
// Purpose: Fetch an array of users that are following the current user.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFollowersOf: (unsigned long)userid
                                   success:(void (^)(NSArray *users))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/followers", kHTTPProtocol, [OOAPI URL], (unsigned long)userid];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *users = [NSMutableArray array];
               for (id dict in responseObject) {
                   [users addObject:[UserObject userFromDict:dict]];
               }
               success(users);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getFollowingWithSuccess
// Purpose: Fetch an array of users that the current user is following.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFollowingWithSuccess:(void (^)(NSArray *users))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (!userid) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/followees", kHTTPProtocol, [OOAPI URL], (unsigned long)userid];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *users = [NSMutableArray array];
               for (id dict in responseObject) {
                   [users addObject:[UserObject userFromDict:dict]];
               }
               success(users);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getGroupsWithSuccess
// Purpose: Fetch an array of groups of which the current user is a member .
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getGroupsWithSuccess:(void (^)(NSArray *groups))success
                                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (!userid) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/groups",
                           kHTTPProtocol, [OOAPI URL], (unsigned long)userid];
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
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getUsersOfGroup
// Purpose: Fetch an array of users who belong to a specified group.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUsersOfGroup: (NSInteger)groupID
                                    success:(void (^)(NSArray *groups))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    if (!userid) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/groups/%lu/users",
                           kHTTPProtocol, [OOAPI URL], (unsigned long)groupID];
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
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    determineIfCurrentUserCanEditEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)determineIfCurrentUserCanEditEvent:(EventObject *) event
                                                       success:(void (^)(bool))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu/users/%lu",
                           kHTTPProtocol, [OOAPI URL],
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
                                            
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                            NSInteger statusCode= operation.response.statusCode;
                                            
                                            if (statusCode == 404) {
                                                success(NO);
                                            } else {
                                                NSLog(@"Error: %@", error);
                                                failure(operation, error);
                                            }
                                        }];
    
    return operation;
}

//------------------------------------------------------------------------------
// Name:    getVotesForEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getVotesForEvent:(EventObject*)event
                                    success:(void (^)(NSArray *votes))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%ld/votes", kHTTPProtocol, [OOAPI URL], (unsigned long)event.eventID];
    
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
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getVoteTalliesForEvent
// Purpose: Fetch an array of restaurants.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getVoteTalliesForEvent:(NSUInteger)eventID
                                           success:(void (^)(NSArray *venues))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%ld/votes/results", kHTTPProtocol, [OOAPI URL], (unsigned long)eventID];
    
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
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
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
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!eventID  || !venueID ) {
        failure(nil,nil);
        return nil;
    }
    
    if  (vote != VOTE_STATE_YES && vote !=  VOTE_STATE_NO ) {
        vote= VOTE_STATE_DONT_CARE;
    }
    
    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID= userInfo.userID;
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    AFHTTPRequestOperation *op;
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/votes", kHTTPProtocol, [OOAPI URL]];
    
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
          } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
              failure(operation, error);
          }];
    
    return op;
}

+ (NSString *) URL {
    if ( APP.usingStagingServer) {
        return kOOURLStage;
    } else {
        return kOOURLProduction;
    }
}

+ (void)setUpAutoCompleteLists
{
    if  (autoCompleteWhiteList ) {
        return;
    }
    autoCompleteWhiteList=  @[
                              @"bread",
                              @"soup",
                              @"breads",
                              @"soups",
                              @"cafe",
                              @"café",
                              @"caffe",
                              @"caffè",
                              @"coffee",
                              @"deli",
                              @"lunch",
                              @"dinner",
                              @"delicatessen",
                              @"food",
                              @"foods",
                              @"restaurant",
                              @"bistro",
                              @"bar",
                              @"grill",
                              @"grullense",
                              @"carniceria",
                              @"casita",
                              @"eats",
                              @"mangia",
                              @"ristorante",
                              @"chez",
                              @"burrito",
                              @"burritos",
                              @"chipotle",
                              @"taco",
                              @"tacos",
                              @"taqueria",
                              @"chaat",
                              @"sushi",
                              @"dining",
                              @"cantina",
                              @"tavern",
                              @"salad",
                              @"salads",
                              @"arby's",
                              @"mcdonald's",
                              @"cheese",
                              @"paneria",
                              @"kitchen",
                              @"flavors",
                              @"vegan",
                              @"vegetarian",
                              @"patisserie",
                              @"fromagerie",
                              @"charcuterie",
                              @"brasserie",
                              @"hofbrau",
                              @"essen",
                              @"noodle",
                              @"pasta",
                              @"buca",
                              @"bouche",
                              @"curry",
                              @"rice",
                              @"cream",
                              @"spaghetti",
                              @"larder",
                              @"pantry",
                              @"fruit",
                              @"donut",
                              @"dough",
                              @"doughnut",
                              @"doughnuts",
                              @"steak",
                              @"steakhouse",
                              @"fried",
                              @"chicken",
                              @"cuisine",
                              @"seafood",
                              @"fish",
                              @"wraps",
                              @"creamery",
                              @"pizza",
                              @"winery",
                              @"bakery",
                              @"tea",
                              @"pho",
                              @"pan-asian",
                              @"lounge",
                              @"crustacean",
                              @"crawfish",
                              @"picnic",
                              @"sandwich",
                              @"sandwiches",
                              @"pizzeria",
                              @"sushirrito",
                              @"delices",
                              @"starbucks",
                              @"peet's",
                              @"85c",
                              @"applebee's",
                              @"hooters",
                              @"waffle",
                              @"foodbag"
                              ];
    autoCompleteBlackList=  @[
                              @"supermarket",
                              @"fry's",
                              @"twitter",
                              @"hotel",
                              @"bicycle",
                              @"group",
                              @"paintball",
                              @"bowling",
                              @"tennis",
                              @"atm",
                              @"federal",
                              @"martial",
                              @"swim",
                              @"swimming",
                              @"museum",
                              @"bank",
                              @"massage",
                              @"gamespot",
                              @"games",
                              @"tutors",
                              @"hardware",
                              @"b&b",
                              @"auberge",
                              @"electric",
                              @"electronic",
                              @"electronics",
                              @"investments",
                              @"barber",
                              @"barbers",
                              @"ymca",
                              @"university",
                              @"college",
                              @"villa",
                              @"computers",
                              @"automotive",
                              @"theater",
                              @"theatre",
                              @"shopping",
                              @"motorcycle",
                              @"motorcycles",
                              @"cement",
                              @"amphitheater",
                              @"attorneys",
                              @"school",
                              @"hospital",
                              @"clinic",
                              @"law",
                              @"dentist",
                              @"dental",
                              @"investigations",
                              @"hair",
                              @"nails",
                              @"google",
                              @"consulting",
                              @"contractors",
                              @"adult",
                              @"travel",
                              @"gym",
                              @"trader",
                              @"voyages",
                              @"toys",
                              @"buy",
                              @"taxidermist",
                              @"office",
                              @"sport",
                              @"sports",
                              @"store",
                              @"app",
                              @"derma",
                              @"botox",
                              @"phone",
                              @"phones",
                              @"surgery",
                              @"editor",
                              @"news",
                              @"newspapers",
                              @"parking",
                              @"park",
                              @"salon",
                              @"dds",
                              @"m.d.",
                              @"garage",
                              @"photo",
                              @"photography",
                              @"graphic",
                              @"photon",
                              @"repair",
                              @"archery",
                              @"academy",
                              @"pool",
                              @"rink",
                              @"hostel",
                              @"tech",
                              @"skateboard",
                              @"manufacturing",
                              @"aaa",
                              @"amc",
                              @"cinema",
                              @"cinemas",
                              @"aquarium",
                              @"bungee",
                              @"airport",
                              @"shooting",
                              @"guns",
                              @"laser",
                              @"veterinarian",
                              @"cars",
                              @"movie",
                              @"moving",
                              @"relocation",
                              @"apartments",
                              @"alcoholics",
                              @"parenthood",
                              @"daycare",
                              @"recovery",
                              @"books",
                              @"magazine",
                              @"credit",
                              @"emergency",
                              @"paycheck",
                              @"psychologist",
                              @"psychotherapy",
                              @"abercrombie",
                              @"police",
                              @"detention",
                              @"prison",
                              ];
    autoCompleteSpecificFoodCompanies=  @[
                                             @"banana republic"
                                             ];
    autoCompleteSpecificNonfoodCompanies=  @[
                                             @"banana republic"
                                             ];
}

@end

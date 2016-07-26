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
#import "SpecialtyObject.h"
#import "CommentObject.h"

NSString *const kKeySearchRadius = @"radius";
NSString *const kKeySearchSort = @"sort";
NSString *const kKeySearchFilter = @"filter";
NSString *const kKeySearchMinPrice = @"minprice";
NSString *const kKeySearchMaxPrice = @"maxprice";
NSString *const kKeySearchLatitude = @"latitude";
NSString *const kKeySearchLongitude = @"longitude";
NSString *const kKeySearchLimit = @"limit";
NSString *const kKeySearchIncludeAll = @"include_all";

NSString *const kKeyRestaurantIDs = @"restaurant_ids";
NSString *const kKeyUserIDs = @"user_ids";
NSString *const kKeyEventIDs = @"event_ids";
NSString *const kKeyTagIDs = @"tag_ids";
NSString *const kKeyDays = @"days";

NSString *const kKeyDeviceToken = @"device_token";
NSString *const kKeyFacebookAccessToken = @"access_token";

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

+ (AFHTTPRequestOperation *)getRestaurantWithID:(NSUInteger)restaurantID
                                          success:(void (^)(RestaurantObject *restaurant))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/restaurants/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)restaurantID];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (user.userID) {
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)user.userID] forKey:kKeyUserID];
    }
    
    return [rm GET:urlString parameters:parameters
           success:^(id responseObject) {
               RestaurantObject *restaurant = [RestaurantObject restaurantFromDict:responseObject];
               success(restaurant);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
           }];
}

///comment requestoperation test
+ (AFHTTPRequestOperation *)getCommentsFromMediaItem:(MediaItemObject *)mediaItem
                                              success:(void (^)(NSArray *comments))success
                                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu/comments", kHTTPProtocol, [OOAPI URL], (unsigned long)mediaItem.mediaItemId];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *comments = [NSMutableArray array];
        for (id dict in responseObject) {
            CommentObject *comment = [CommentObject commentFromDict:dict];
            if (comment) {
                [comments addObject:comment];
            }
        }
        success(comments);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
        failure(operation, error);
    }];
}


+ (AFHTTPRequestOperation *)uploadComment:(CommentObject *)comment
                                forObject:(MediaItemObject *)mio
                                        success:(void (^)(CommentObject *))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    if  (!comment || !mio) {
        failure (nil,nil);
        return nil;
    }
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    if (!user || !user.userID) {
        failure (nil,nil);
        return nil;
    }
    
    NSLog(@"the comment is %@", comment.content);
    
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
      NSString *str = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu/comments", kHTTPProtocol, [OOAPI URL], (unsigned long)mio.mediaItemId];
    
    NSLog(@"%@", str);
    
    NSDictionary *parameters = @{
                                 //kKeyCommentMediaItemCommentID : [NSString stringWithFormat:@"%lu", (unsigned long)comment.mediaItemCommentID],
                                 kKeyCommentUserID : [NSString stringWithFormat:@"%lu", (unsigned long)user.userID],
                                 //kKeyCommentMediaItemID : [NSString stringWithFormat:@"%lu", (unsigned long)comment.mediaItemID],
                                 kKeyCommentContent : comment.content};
    
    
    
    AFHTTPRequestOperation *op = [rm POST:str parameters:parameters
                                 success:^(id responseObject) {
                                     CommentObject *co = [CommentObject commentFromDict:responseObject];
                                     
                                     success(co);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                     failure(operation, error);
                                 }];
    
    NSLog(@"the operation returns %@", op.responseString);
    return op;
}


+ (AFHTTPRequestOperation *)setMediaItemCaption:(NSUInteger)mediaItemID
                                        caption:(NSString *)caption
                                        success:(void (^)())success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if  (!mediaItemID) {
        failure (nil,nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu",
                           kHTTPProtocol, [OOAPI URL], (unsigned long)mediaItemID];
    
    NSDictionary *parameters = @{kKeyMediaItemCaption : caption};
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    AFHTTPRequestOperation *op = [rm PUT:urlString parameters:parameters
                                 success:^(id responseObject) {
                                     success(responseObject);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                     failure(operation, error);
                                 }];
    
    return op;
}

+ (AFHTTPRequestOperation *)getNumMediaItemLikes:(NSUInteger)mediaItemID
                                      success:(void (^)(NSUInteger count))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    if (!mediaItemID) {
        failure(nil, nil);
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu/likes/count", kHTTPProtocol, [OOAPI URL],(unsigned long) mediaItemID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject objectForKey:@"like_count"]) {
            NSUInteger numLikes = parseUnsignedIntegerOrNullFromServer([responseObject objectForKey:@"like_count"]);
            success (numLikes);
        } else {
            success (0);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSInteger statusCode = operation.response.statusCode;
        NSLog(@"Error: %@, status code %ld", error, (long)statusCode);
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)getMediaItemLiked:(NSUInteger)mediaItemID
                                           byUser:(NSUInteger)userID
                                           success:(void (^)(BOOL ))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    if (!mediaItemID || !userID) {
        failure(nil, nil);
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/mediaItems/%lu/likes", kHTTPProtocol, [OOAPI URL],(unsigned long) userID, (unsigned long)mediaItemID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            NSLog(@"like: %@", responseObject);
            NSUInteger uid, mid;
            NSDictionary *dict = responseObject;
            uid = parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyUserID]);
            mid = parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyMediaItemID]);
            if (uid == userID && mid == mediaItemID) {
                success(YES);
            } else {
                success(NO);
            }
        } else {
            success(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSInteger statusCode = operation.response.statusCode;
        NSLog(@"Error: %@, status code %ld", error, (long)statusCode);
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)unsetMediaItemLike:(NSUInteger)mediaItemID
                             forUser:(NSUInteger)userID
                             success:(void (^)())success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if  (!userID || !mediaItemID) {
        failure (nil,nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu/users/%lu/likes",
                           kHTTPProtocol, [OOAPI URL],(unsigned long) mediaItemID,(unsigned long) userID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm DELETE:urlString parameters:nil success:^(id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)setMediaItemLike:(NSUInteger)mediaItemID
                           forUser:(NSUInteger)userID
                           success:(void (^)())success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if  (!userID || !mediaItemID) {
        failure (nil,nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu/likes",
                           kHTTPProtocol, [OOAPI URL], (unsigned long)mediaItemID];
    
    NSDictionary *parameters = @{kKeyUserID : [NSString stringWithFormat:@"%lu", (unsigned long)userID]};
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    return op;
}

+ (AFHTTPRequestOperation *)setMediaItem:(NSUInteger)mediaItemID
                              properties:(NSDictionary *)properties
                                 success:(void (^)())success
                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if  (!mediaItemID || ![properties isKindOfClass:[NSDictionary class]]) {
        failure (nil,nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu",
                           kHTTPProtocol, [OOAPI URL], (unsigned long)mediaItemID];
    
    NSDictionary *parameters = properties;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    AFHTTPRequestOperation *op = [rm PUT:urlString parameters:parameters
                                 success:^(id responseObject) {
                                     success(responseObject);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                     failure(operation, error);
                                 }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    getRestaurantMediaItems
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getMediaItemsForRestaurant:(RestaurantObject *)restaurant
                                               success:(void (^)(NSArray *mediaItems))success
                                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    UserObject *userObject = [Settings sharedInstance].userObject;
    
    NSString *urlString;
    
    if (userObject && userObject.userID) {
        urlString = [NSString stringWithFormat:@"%@://%@/restaurants/%lu/photos?user_id=%lu", kHTTPProtocol, [self ooURL], (unsigned long)restaurant.restaurantID, (unsigned long)userObject.userID];
    } else {
        urlString = [NSString stringWithFormat:@"%@://%@/restaurants/%lu/photos", kHTTPProtocol, [self ooURL], (unsigned long)restaurant.restaurantID];
    }
    
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *mediaItems = [NSMutableArray array];
        //NSLog(@"rest name = %@ \nmedia items %@", restaurant.name, responseObject);
        for (id dict in responseObject) {
            [mediaItems addObject:[MediaItemObject mediaItemFromDict:dict]];
        }
        success(mediaItems);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    getRestaurantWithID
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantWithID:(NSString *)restaurantID source:(NSUInteger)source
                                        success:(void (^)(RestaurantObject *restaurant))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if (!restaurantID) {
        if (failure)
            failure(nil,nil);
        return nil;
    }

    NSString *urlString;
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    urlString = [NSString stringWithFormat:@"%@://%@/restaurants/%@", kHTTPProtocol, [self ooURL], restaurantID];
    
    if (source == kRestaurantSourceTypeOomami) {
        
    } else {
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)source] forKey:@"source"];
    }
    
    if (user.userID) {
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)user.userID] forKey:kKeyUserID];
    }
    
    

    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        RestaurantObject *restaurant = [RestaurantObject restaurantFromDict:responseObject];
        success(restaurant);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
        failure(operation,error);
    }];
}

+ (AFHTTPRequestOperation *) convertGoogleIDToRestaurant:(NSString *)googleID
                                        success:(void (^)(RestaurantObject *restaurant))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    OOAPI *api = [[OOAPI alloc] init];
    return [api getRestaurantWithID:googleID source:kRestaurantSourceTypeGoogle success:success failure:failure  ];
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
        failure(nil, nil);
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
                                              minPrice:(NSUInteger)minPrice
                                              maxPrice:(NSUInteger)maxPrice
                                               isPlay:(BOOL)isPlay
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableString *searchTerms = [[NSMutableString alloc] init];
    
    if (!keywords) {
        failure(nil,nil);
        return nil;
    } else {
        [keywords enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString *s = (NSString *)obj;
            NSString *fs;
            if ([s containsString:@" "]) {
                fs = [NSString stringWithFormat:@"(\"%@\")", (NSString *)obj];
            } else {
                fs = [NSString stringWithFormat:@"(%@)", (NSString *)obj];
            }
                
            if ([searchTerms length]) {
                [searchTerms appendString:@"OR"];
            }
            [searchTerms appendString:fs];
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
    
    NSString *urlString;
    if (isPlay) {
        UserObject *userInfo= [Settings sharedInstance].userObject;
        if (userInfo && userInfo.userID) {
            urlString = [NSString stringWithFormat:@"%@://%@/search/users/%lu/play", kHTTPProtocol, [OOAPI URL], (unsigned long)userInfo.userID];
        } else {
            failure(nil,nil);
        }
    } else {
        urlString = [NSString stringWithFormat:@"%@://%@/search", kHTTPProtocol, [OOAPI URL]];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"keyword":searchTerms,
                                 kKeySearchSort:[NSNumber numberWithUnsignedInteger:sort],
                                 kKeySearchRadius:[NSNumber numberWithUnsignedInteger:radius],
                                 kKeyRestaurantLatitude:[NSNumber numberWithFloat:location.latitude],
                                 kKeyRestaurantLongitude:[NSNumber numberWithFloat:location.longitude],
//                                 kKeyRestaurantLatitude:[NSNumber numberWithFloat:37.773972],
//                                 kKeyRestaurantLongitude:[NSNumber numberWithFloat:-122.431297],
                                 kKeyRestaurantOpenNow:[NSNumber numberWithBool:openOnly]
//                                 kKeySearchFilter:filterName// Not used by backend.
                                 }];
    
    if (!(minPrice == 0 && maxPrice == 0)) {
        if (!(minPrice == 0 && maxPrice == 3)) {
            [parameters setObject:[NSNumber numberWithUnsignedInteger:minPrice+1] forKey:kKeySearchMinPrice];
            [parameters setObject:[NSNumber numberWithUnsignedInteger:maxPrice+1] forKey:kKeySearchMaxPrice];
        }
    }
  
    NSLog(@"search URL = %@", urlString);
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        NSMutableArray *restaurants = [NSMutableArray array];
        for (id dict in responseObject) {
            //NSLog(@"rest name: %@", [RestaurantObject restaurantFromDict:dict].name);
            [restaurants addObject:[RestaurantObject restaurantFromDict:dict]];
        }
        success(restaurants);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSInteger statusCode= operation.response.statusCode;
        NSLog(@"Error: %@, status code %ld", error, (long)statusCode);
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)getAllTagsWithSuccess:(void (^)(NSArray *tags))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{    
    return [OOAPI getTagsForUser:kAllUsersID success:success failure:failure];
}

#if 0
+ (AFHTTPRequestOperation *) getAutoCompleteDataForString: (NSString*)string
                                                 location: (CLLocationCoordinate2D)location
                                                  success:(void (^)(NSArray *results))success
                                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
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
#endif

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
// Name:    getMediaItemYummers
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getMediaItemYummers:(MediaItemObject *)mediaItem
                                        success:(void (^)(NSArray *users))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu/likes/users", kHTTPProtocol, [OOAPI URL], (unsigned long)mediaItem.mediaItemId];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSMutableArray *users = [NSMutableArray array];
        for (id dict in responseObject) {
            UserObject *u = [UserObject userFromDict:dict];
            if (u) {
                [users addObject:u];
            }
        }
        success(users);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
        failure(operation, error);
    }];
}


+ (AFHTTPRequestOperation *)getUserWithID:(NSUInteger)userID
                                  success:(void (^)(UserObject *user))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu", kHTTPProtocol, [OOAPI URL], ( unsigned long)userID];
    
    NSLog (@"URL = %@",urlString);
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        UserObject *object= [UserObject userFromDict:responseObject];
        success(object);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)getUserWithUsername:(NSString *)username
                                  success:(void (^)(UserObject *user))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!username || !username.length) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/usernames/%@", kHTTPProtocol,
                           [OOAPI URL], username];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        //NSArray *array = responseObject;
        //for (NSDictionary* d  in array) {
        
        UserObject *user = [UserObject userFromDict:responseObject];
            success(user);
        //}
        failure(nil, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
        failure(operation, error);
    }

            ];
}

+ (AFHTTPRequestOperation *)getStatsForUser:(NSUInteger)identifier
                                   success:(void (^)(NSDictionary *response))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
//    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/stats", kHTTPProtocol, [OOAPI URL], ( unsigned long)identifier];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/stats?ids[]=%lu", kHTTPProtocol, [OOAPI URL], ( unsigned long)identifier];
    
        NSLog (@"GET STATS URL = %@",urlString);
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        // XX:  this is temporary
        if ([responseObject isKindOfClass:[NSArray class]])  {
            NSArray*array= responseObject;
            id dictionary= array.count? [array  firstObject ]:nil;
            if ([dictionary isKindOfClass:[NSDictionary class]])  {
                @try {
                    success(dictionary);
                }
                @catch (NSException *exception) {
                    NSLog (@"");
                }
                @finally {
                    NSLog  (@"");
                }
            } else {
                success (nil);
            }
        } else {
            success (nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
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
// Name:    getUsersWithKeyword
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUsersOfType:(UserType)userType
                                        success:(void (^)(NSArray *users))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users", kHTTPProtocol, [OOAPI URL]];
    NSDictionary *parameters = @{
                                 @"type":[NSString stringWithFormat:@"%lu", (unsigned long)userType],
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
                               includeAll:(BOOL)includeAll
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
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (includeAll) {
        [parameters setObject:[NSString stringWithFormat:@"%d", 1] forKey:kKeySearchIncludeAll];
    } else {
        NSLog(@"don't include autogenerated lists");
    }
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/emails/%@",
                           kHTTPProtocol,
                           [OOAPI URL],
                           emailString];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    NSLog (@"LOOKUP USER %@",emailString);
    
    return [rm GET:urlString parameters: nil
           success:^(id responseObject) {
        if ( [responseObject isKindOfClass:[NSArray class]]) {
            NSArray *a= responseObject;
            if  (a.count ) {
                UserObject* user= [UserObject userFromDict: a[0]];
                if  (user ) {
                    success( user);
                } else {
                    success( nil);
                }
            } else {
                success( nil);
            }
        } else {
            success( nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
        failure(operation, error);
    }
            ];
}

//------------------------------------------------------------------------------
// Name:    getList
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getList:(NSUInteger)listID
                            success:(void (^)(ListObject *list))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%lu", kHTTPProtocol,
                           [OOAPI URL], (unsigned long)listID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        ListObject *list = [ListObject listFromDict:responseObject];
        success(list);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        ;
    }];
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
                                         andLocation:(CLLocationCoordinate2D)location
                                             success:(void (^)(NSArray *restaurants))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%ld/restaurants", kHTTPProtocol,
                           [OOAPI URL],
                           (long)listID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (CLLocationCoordinate2DIsValid(location)) {
        [parameters setObject:[NSString stringWithFormat:@"%f", location.latitude] forKey:kKeySearchLatitude];
        [parameters setObject:[NSString stringWithFormat:@"%f", location.longitude] forKey:kKeySearchLongitude];
    }
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
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
// Name:    getFoodFeedType
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFoodFeedType:(NSUInteger)type
                                             success:(void (^)(NSArray *restaurants))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{    
    UserObject *uo = [Settings sharedInstance].userObject;

    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/mediaItems/restaurants?limit=%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)uo.userID, (unsigned long)kFoodFeedPageSize];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (type == kFoodFeedTypeFriends) {
        [parameters setObject:[NSNumber numberWithUnsignedInteger:kFoodFeedPageSize] forKey:kKeySearchLimit];
        [parameters setObject:[NSNumber numberWithInt:2] forKey:kKeySearchFilter];
        urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/mediaItems/restaurants", kHTTPProtocol, [OOAPI URL], (unsigned long)uo.userID];
    } else if (type == kFoodFeedTypeAll) {
        [parameters setObject:[NSNumber numberWithUnsignedInteger:kFoodFeedPageSize] forKey:kKeySearchLimit];
        urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/mediaItems/restaurants", kHTTPProtocol, [OOAPI URL], (unsigned long)uo.userID];
    } else if (type == kFoodFeedTypeAroundMe) {
        CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
        [parameters setObject:[NSNumber numberWithUnsignedInteger:kFoodFeedPageSize] forKey:kKeySearchLimit];
        [parameters setObject:[NSNumber numberWithFloat:loc.latitude] forKey:kKeySearchLatitude];
        [parameters setObject:[NSNumber numberWithFloat:loc.longitude] forKey:kKeySearchLongitude];
        urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/mediaItems/restaurants", kHTTPProtocol, [OOAPI URL], (unsigned long)uo.userID];
    } else {
        failure(nil, nil);
        return nil;
    }

    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
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
// Name:    getRestaurantsFromSystemList
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
// Name:    getRestaurantsViaYouSearchForUser withTerm
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getRestaurantsViaYouSearchForUser:(NSUInteger) userid
                                                     withTerm: (NSString*)term
                                                      success:(void (^)(NSArray *restaurants))success
                                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    term= [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/search/users/%lu/restaurants?term=%@",
                           kHTTPProtocol,
                           [OOAPI URL],
                           ( unsigned long)userid,
                           term];
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
// Name:    addList
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)updateList:(ListObject *)list
                            success:(void (^)(ListObject *listObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!list) {
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
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)list.listID];
    NSDictionary *parameters = @{
                                 kKeyListName:list.name,
                                 kKeyListType:[NSString stringWithFormat:@"%d", list.type],
                                 };
    AFHTTPRequestOperation *op = [rm PUT:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      ListObject *l = [ListObject listFromDict:responseObject];
                                      success(l);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    removeVenue fromList
// Purpose: Remove a restaurant from a list.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)removeVenue:(RestaurantObject *)venue
                                   fromList:(ListObject *)list
                                     success:(void (^)(id response))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!list  || !venue) {
        failure( nil,nil);
        return nil;
    }
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userid = userInfo.userID;
    if (!userid) {
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%lu/restaurants/%lu",
                           kHTTPProtocol,
                           [OOAPI URL],
                           (unsigned long)list.listID,
                           (unsigned long)venue.restaurantID];
    
    AFHTTPRequestOperation *op = [rm DELETE: urlString parameters:nil
                                    success:^(id responseObject) {
                                        NSLog (@"REMOVED VENUE FROM LIST");
                                        success(responseObject);
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                        NSLog  (@"FAILED TO REMOVE VENUE FROM LIST");
                                        failure(operation, error);
                                    }];
    return op;
}

//------------------------------------------------------------------------------
// Name:    addRestaurantsFromList:toList
// Purpose: Add restaurants to a user's favorites list
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)addRestaurantsFromList:(NSUInteger)fromListID toList:(NSUInteger)toListID
                                   success:(void (^)(id response))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    if (!fromListID || !toListID) {
        failure(nil,nil);
        return nil;
    }

    UserObject *userInfo= [Settings sharedInstance].userObject;
    NSUInteger userID= userInfo.userID;
    if (!userID) {
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/lists/%lu/restaurants", kHTTPProtocol, [OOAPI URL], (unsigned long)fromListID];
    
    NSDictionary *parameters = @{
                                 kKeyListID: [NSString stringWithFormat:@"[%lu]", (unsigned long)fromListID]
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
// Name:    addRestaurants:toList
// Purpose: Add restaurants to a user's favorites list
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants toList:(NSUInteger)listID
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
                                      [FBSDKAppEvents logEvent:kAppEventPlaceAddedToList parameters:@{kAppEventParameterKeyListType:kAppEventParameterValueCustomList}];
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
    } else if (listType == kListTypeNotNow) {
            urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/notnow/restaurants", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
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
                                      [FBSDKAppEvents logEvent:kAppEventPlaceAddedToList parameters:@{kAppEventParameterKeyListType:kAppEventParameterValueSpecialList}];
                                      success(responseObject);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    
    return op;
}

+ (AFHTTPRequestOperation *)getPhotosOfUser:(NSUInteger )userid
                                   maxWidth:(NSUInteger)maxWidth
                                  maxHeight:(NSUInteger)maxHeight
                                    success:(void (^)(NSArray *mediaObjects))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    UserObject *currentUser = [Settings sharedInstance].userObject;
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/photos", kHTTPProtocol, [OOAPI URL], (unsigned long)userid];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (maxWidth) {
        maxWidth = (isRetinaDisplay()) ? 2*maxWidth:maxWidth;
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)maxWidth] forKey:@"maxwidth"];
    } else if (maxHeight) {
        maxHeight = (isRetinaDisplay()) ? 2*maxHeight:maxHeight;
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)maxWidth] forKey:@"maxHeight"];
    }
    
    if (currentUser) {
        [parameters setObject:[NSString stringWithFormat:@"%lu", (unsigned long)currentUser.userID]  forKey:kKeyUserID];
    }
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        NSMutableArray *array= [NSMutableArray new];
        if ( [responseObject isKindOfClass:[NSArray class] ]) {
            NSArray *objects= responseObject;
            
            for (NSDictionary*  dictionary  in objects) {
                if  ([dictionary isKindOfClass:[NSDictionary  class ] ] ) {
                    MediaItemObject *object= [ MediaItemObject  mediaItemFromDict:  dictionary];
                    if  (object ) {
                        [array  addObject:  object];
                    }
                }
            }
        }
        success( array);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        NSLog(@"Error: %@", error);
    }];
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
        op = [rm POST:urlString parameters: @{
                                               @"user_id": @(otherUserID)
                                              }
             success:^(id responseObject) {
                 [FBSDKAppEvents logEvent:kAppEventUserFollowed];
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
//                                               @"participant_state":@1
                                               }
              
               success:^(id responseObject) {
                   NSInteger identifier= 0;
                   if ([responseObject isKindOfClass:[NSDictionary class]]) {
                       NSNumber *eventID= ((NSDictionary *)responseObject)[kKeyEventEventID];
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
                      NSNumber *eventID= ((NSDictionary *)responseObject)[kKeyEventEventID];
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
    NSUInteger restaurantID = restaurant.restaurantID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/restaurants/%lu/followees", kHTTPProtocol, [OOAPI URL], (unsigned long)userID, (unsigned long)restaurantID];
    
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
// Name:    getUnfollowedFacebookUsers
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUnfollowedFacebookUsers:(NSArray *)array
                                               forUser:(NSUInteger)userID
                                               success:(void (^)(NSArray *users))success
                                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!array.count) {
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
//    UserObject *userInfo = [Settings sharedInstance].userObject;
//    NSUInteger userID = userInfo.userID;
    NSMutableString *urlString= [NSMutableString stringWithFormat:@"%@://%@/users/%lu/connect/facebookIds?",
                                 kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    
    for (NSString* string  in  array) {
        NSString *expression= [NSString  stringWithFormat: @"ids[]=%@&", string];
        [ urlString  appendString: expression];
    }
    
    NSLog  (@"URL WITH FB IDs EMBEDDED: %@", urlString);
    
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

//------------------------------------------------------------------------------
// Name:    getUsersTheCurrentUserIsNotFollowingUsingEmails
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUsersTheCurrentUserIsNotFollowingUsingEmails: (NSArray*)arrayOfEmailAddresses
                                                                    success:(void (^)(NSArray *users))success
                                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!arrayOfEmailAddresses) {
        failure(nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    NSMutableString *urlString= [NSMutableString stringWithFormat:@"%@://%@/users/%lu/connect/emails?",
                                 kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    for (NSString* string  in  arrayOfEmailAddresses) {
        NSString *expression= [NSString  stringWithFormat: @"emails[]=%@&", string];
        [ urlString  appendString: expression];
    }
    
    NSLog  (@"URL WITH EMAIL ADDRESSES EMBEDDED: %@", urlString);
    
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

//------------------------------------------------------------------------------
// Name:    getFoodieUsersForUser
// Purpose: Obtain "foodie" users for a particular user, which may be different
//          than for other users.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFoodieUsersForUser:(UserObject*)user
                                          success:(void (^)(NSArray *users))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!user) {
        failure (nil,nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    NSString *urlString;
        urlString= [NSString stringWithFormat:@"%@://%@/users/%lu/connect/foodies",
                    kHTTPProtocol, [OOAPI URL], (unsigned long)user.userID];
    
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

+ (AFHTTPRequestOperation *)getUsersAroundLocation:(CLLocationCoordinate2D)location
                                           forUser:(NSUInteger)userID
                                           success:(void (^)(NSArray *users))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    //eg. /users/aroundyou?latitude=33.8088231&longitude=-117.8515011
    
    NSString *urlString;
    urlString= [NSString stringWithFormat:@"%@://%@/users/%lu/aroundyou",
                kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    if (!CLLocationCoordinate2DIsValid(location)) {
        failure(nil, nil);
        return nil;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:
                                    @{
                                      kKeyRestaurantLatitude:[NSNumber numberWithFloat:location.latitude],
                                      kKeyRestaurantLongitude:[NSNumber numberWithFloat:location.longitude],
                                      kKeySearchRadius:[NSNumber numberWithFloat:30000]
                                      }
                                       ];
                                                                                      
    AFHTTPRequestOperation *op;
    
    op = [rm GET:urlString parameters:parameters
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

+ (AFHTTPRequestOperation *)getRecentUsersSuccess:(void (^)(NSArray *users))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    UserObject *user = [Settings sharedInstance].userObject;
    
    if (!user) {
        failure(nil, nil);
        return nil;
    }
    
    //eg. /users/recent?days=30&limit=5
    
    NSString *urlString;
    urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/recent", kHTTPProtocol, [OOAPI URL], (unsigned long)user.userID];
    
    AFHTTPRequestOperation *op;
    
    NSDictionary *parameters = @{kKeyDays:@(15), kKeySearchLimit:@(5)};
    
    op = [rm GET:urlString parameters:parameters
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
/////////

+ (AFHTTPRequestOperation *)reportPhoto:(MediaItemObject *)mio success:(void (^)(void))success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if  (!mio) {
        failure (nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)mio.mediaItemId];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm PUT:urlString parameters: @{
                                              @"is_flagged":@1
                                              }
              success:^(id responseObject) {
        NSLog(@"delete photo:%lu response: %@",(unsigned long) mio.mediaItemId, responseObject);
        success();
    }
              failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)deletePhoto:(MediaItemObject *)mio success:(void (^)(void))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if  (!mio) {
        failure (nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)mio.mediaItemId];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm DELETE:urlString parameters:nil success:^(id responseObject) {
        NSLog(@"delete photo:%lu response: %@",(unsigned long)mio.mediaItemId, responseObject);
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)getMediaItem:(NSUInteger)mediaItemID
                                 success:(void (^)(MediaItemObject *mio))success
                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if  (!mediaItemID) {
        failure (nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)mediaItemID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:^(id responseObject) {
        NSLog(@"getting media item id:%lu response: %@",(unsigned long)mediaItemID, responseObject);
        MediaItemObject *mio = [MediaItemObject mediaItemFromDict:responseObject];
        success(mio);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
        failure(operation, error);
    }];
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
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    
    NSLog(@"img dims = %@", NSStringFromCGSize(image.size));
    NSLog(@"img size = %lu bytes", (unsigned long)[imageData length]);

    NSDictionary *parameters;
    
    if ([object isKindOfClass:[RestaurantObject class]]) {
        RestaurantObject *restaurant = (RestaurantObject *)object;
        parameters = @{kKeyRestaurantRestaurantID : [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.restaurantID]};
    }
    else if ([object isKindOfClass:[UserObject class]]) {
        UserObject *user = (UserObject *)object;
        parameters = @{kKeyUserID : [NSString stringWithFormat:@"%lu", (unsigned long)user.userID]};
    }
    else if ([object isKindOfClass:[ListObject class]]) {
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
// Purpose: This is the AFNetworking approach.
//------------------------------------------------------------------------------
+ (void)uploadPhoto:(UIImage *)image
          forObject:(id)object
            success:(void (^)(MediaItemObject *mio))success
            failure:(void (^)( NSError *error))failure
            progress:(void (^)(NSUInteger , long long , long long ))progress;
{
    if (!image || !object) {
        failure(nil);
        return ;
    }
    
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    
    NSDictionary *parameters;

    NSString *photoType = @"";
    
    if ([object isKindOfClass:[RestaurantObject class]]) {
        RestaurantObject *restaurant = (RestaurantObject *)object;
        parameters = @{kKeyRestaurantRestaurantID : [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.restaurantID]};
        photoType = kAppEventParameterValueItem;
    }
    else if ([object isKindOfClass:[UserObject class]]) {
        UserObject *user = (UserObject *)object;
        parameters = @{kKeyUserID : [NSString stringWithFormat:@"%lu", (unsigned long)user.userID]};
        photoType = kAppEventParameterValueUser;
    }
    else if ([object isKindOfClass:[ListObject class]]) {
        photoType = kAppEventParameterValueList;
        ListObject *list = (ListObject *)object;
        parameters = @{kKeyListID : [NSString stringWithFormat:@"%lu", (unsigned long)list.listID]};
    } else if ([object isKindOfClass:[EventObject class]]) {
        photoType = kAppEventParameterValueEvent;
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
        MediaItemObject *mio = [MediaItemObject mediaItemFromDict:responseObject];
        [FBSDKAppEvents logEvent:kAppEventPhotoUploaded parameters:@{kAppEventParameterKeyUploadType:photoType}];
        success(mio);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        failure(error);
    }];
    
    [op setUploadProgressBlock:progress];
    [op start];
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


+ (AFHTTPRequestOperation *)getUserRelevantMediaItemForRestaurant:(NSUInteger)restaurantID
                                     success:(void (^)(NSArray *mediaItems))success
                                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    if (!user || user.userID) {
        failure(nil, nil);
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/restaurants/%lu/users/%lu/mediaItem", kHTTPProtocol, [OOAPI URL], (unsigned long)restaurantID, (unsigned long)user.userID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               if ([responseObject isKindOfClass:[NSArray class]]) {
                   NSMutableArray *mediaItems = [NSMutableArray array];
                   for (id dict in responseObject) {
                       MediaItemObject *mio = [MediaItemObject mediaItemFromDict:dict];
                       //NSLog(@"Event name: %@", [RestaurantObject restaurantFromDict:dict].name);
                       [mediaItems addObject:mio];
                   }
                   success(mediaItems);
               } else {
                   NSLog  (@"Could not get a media item for the restaurant");
                   failure(nil,nil);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
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
                if ( e.eventType==EVENT_TYPE_CURATED) {
                    NSLog  (@"CURATED EVENT  %@",dict);
                    //NSLog(@"Event name: %@", [RestaurantObject restaurantFromDict:dict].name);
                    [events addObject:e];
                }
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
// Name:    addRestaurants toEvent
// Purpose: Add a restaurant to an event.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)addRestaurants:(NSArray *)restaurants
                                  toEvent:(EventObject *)event
                                  success:(void (^)(id response))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!event || !restaurants) {
        failure(nil,nil);
        return nil;
    }
    
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userid = userInfo.userID;
    if (!userid) {
        failure(nil,nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu/restaurants", kHTTPProtocol, [OOAPI URL],
                           (unsigned long)event.eventID];
    
    NSMutableArray*restaurantArray= [NSMutableArray new];
    for (RestaurantObject* r   in  restaurants) {
        NSUInteger identifier= r.restaurantID;
        [restaurantArray addObject: @( identifier)];
    }
    AFHTTPRequestOperation *op = [rm POST:urlString
                               parameters:@{
                                            kKeyRestaurantIDs: restaurantArray
                                            }
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
//    NSString *identifier = [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.restaurantID];
//    NSString *googleIdentifier = restaurant.googleID;
//    NSMutableDictionary* parameters = @{}.mutableCopy;
//    if (identifier.length) {
//        [parameters setObject: @(restaurant.restaurantID) forKey: kKeyRestaurantIDs];
//    }
//    else if (googleIdentifier.length) {
//        [parameters setObject:googleIdentifier forKey:kKeyRestaurantGoogleID];
//    }
//    else {
//        NSLog (@"MISSING VENUE IDENTIFIER");
//        failure(nil,nil);
//        return nil;
//    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%lu/restaurants/%lu", kHTTPProtocol, [OOAPI URL],
                           (unsigned long)event.eventID,
                           (unsigned long)restaurant.restaurantID];
    
    AFHTTPRequestOperation *op = [rm DELETE: urlString parameters:nil
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
                                          NSNumber *eventID= ((NSDictionary *)responseObject)[kKeyEventEventID];
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
    NSLog (@"EVENT BEFORE REVISION  %@",parameters);
    
    AFHTTPRequestOperation *op = [rm PUT:urlString parameters:parameters
                                 success:^(id responseObject) {
                                     NSLog (@"REVISED EVENT: %@", responseObject);
                                     success(responseObject);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                     failure(operation, error);
                                 }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    getFollowersForUser
// Purpose: Fetch an array of users that are following the current user.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFollowersForUser: (NSUInteger)userid
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
// Name:    getUserSpecialties
// Purpose: Fetch an array of specialties of a user.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUserSpecialties: (NSUInteger)userid
                                   success:(void (^)(NSArray *specialties))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!userid) {
        failure(nil,nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/specialties",
                           kHTTPProtocol,
                           [OOAPI URL],
                           (unsigned long)userid];
    
//    https://stage.oomamiapp.com/api/v1/users/118/specialties
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *specialties = [NSMutableArray array];
               for (id dict in responseObject) {
                   SpecialtyObject*object=[SpecialtyObject specialtyFromDictionary:dict];
                    if( object) [specialties addObject: object];
               }
               success(specialties);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    getFollowingOf
// Purpose: Fetch an array of users that a user is following.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getFollowingForUser:(NSUInteger)userid
                                   success:(void (^)(NSArray *users))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/groups/%lu/users", kHTTPProtocol, [OOAPI URL], (unsigned long)groupID];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *users = [NSMutableArray array];
               for (id object in responseObject) {
                   
                   if ([object isKindOfClass:[NSDictionary class]]) {
                       [users addObject:[UserObject userFromDict:object]];
                   }
               }
               
               NSLog(@"TOTAL USERS FOUND: %ld", (unsigned long)users.count);
               success(users);
               
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    determineIfCurrentUserCanEditEvent
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)determineIfCurrentUserCanEditEvent:(EventObject *)event
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
                           ( unsigned long)userID];
    
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
+ (AFHTTPRequestOperation *)getVotesForEvent:(EventObject *)event
                                    success:(void (^)(NSArray *votes))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/events/%ld/votes", kHTTPProtocol, [OOAPI URL], (unsigned long)event.eventID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:urlString parameters: nil
           success:^(id responseObject) {
               NSMutableArray *votes = [NSMutableArray array];
               for (id dict in responseObject) {
                   VoteObject *object=[VoteObject voteFromDictionary:dict];
                   if (object) {
                       [votes addObject:object];
                   }
               }
               success(votes);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    
    return [rm GET:urlString parameters:nil
           success:^(id responseObject) {
               NSMutableArray *venues = [NSMutableArray array];
               for (NSDictionary *d in responseObject) {
                   RestaurantObject *object=[RestaurantObject restaurantFromDict:d];
                   if (object) {
                       [venues addObject:object];
                   }
               }
               success(venues);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

//------------------------------------------------------------------------------
// Name:    setVoteTo forEvent andRestaurant
// Purpose:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)setVoteTo:(NSInteger)vote
                             forEvent:(NSUInteger)eventID
                        andRestaurant:(NSUInteger)venueID
                              success:(void (^)(NSInteger eventID))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!eventID || !venueID ) {
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
                                          kKeyEventEventID: @(eventID),
                                          @"vote": @(vote)
                                          }
          success:^(id responseObject) {
              NSInteger identifier= 0;
              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                  NSNumber *eventID= ((NSDictionary *)responseObject)[kKeyEventEventID];
                  identifier= parseIntegerOrNullFromServer(eventID);
              }
              success(identifier);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
              failure(operation, error);
          }];
    
    return op;
}

+ (AFHTTPRequestOperation *)uploadAPNSDeviceToken:(NSString *)token
                              success:(void (^)(id response))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!token) {
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
    AFHTTPRequestOperation *op;
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users/%lu/APNSDeviceToken", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];
    
    op = [rm POST:urlString parameters: @{
                                          kKeyDeviceToken: token
                                          }
          success:^(id responseObject) {
              success(responseObject);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
              failure(operation, error);
          }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    flagMediaItem
// Purpose: to flag a media item
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)flagMediaItem:(NSUInteger)mediaItemID
                                  success:(void (^)(NSArray *names))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *requestString = [NSString stringWithFormat:@"%@://%@/mediaItems/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)mediaItemID];
    
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    return [[OONetworkManager sharedRequestManager] PUT:requestString
                                             parameters:@{@"is_flagged":@1}
                                                success:success
                                                failure:failure];
}

+ (AFHTTPRequestOperation *)setAboutInfoFor:(NSUInteger)userID
                                         to:(NSString*)text
                                    success:(void (^)( void))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *requestString = [NSString stringWithFormat:@"%@://%@/users/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)userID];

    return [[OONetworkManager sharedRequestManager] PUT:requestString
                                             parameters: @{
                                                           kKeyUserAbout: text ?:  @""
                                                          }
                                                success:^(id  response)  {
                                                    success ();
                                                }
                                                failure:failure];
}

+ (AFHTTPRequestOperation *)updateUser:(UserObject *)user
                               success:(void (^)(void))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    UserObject *currentUser = [Settings sharedInstance].userObject;
    NSString *requestString = [NSString stringWithFormat:@"%@://%@/users/%lu", kHTTPProtocol, [OOAPI URL], (unsigned long)currentUser.userID];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (user.lastName && [trimString(user.lastName) length]) {
        [parameters setObject:user.lastName forKey:kKeyUserLastName];
    }
    if (user.firstName && [trimString(user.firstName) length]) {
        [parameters setObject:user.firstName forKey:kKeyUserFirstName];
    }
    if (user.username && [trimString(user.username) length]) {
        [parameters setObject:user.username forKey:kKeyUserUsername];
    }
    if (user.about && [trimString(user.about) length]) {
        [parameters setObject:user.about forKey:kKeyUserAbout];
    }
    
    return [[OONetworkManager sharedRequestManager] PUT:requestString
                                             parameters:parameters
                                                success:^(id response)  {
                                                    success ();
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    failure(operation, error);
                                                }];
}

//------------------------------------------------------------------------------
// Name:    getUserStatsFor
// Purpose: Fetches basic stats about a user.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)getUserStatsFor:(NSUInteger)userID
                                    success:(void (^)(UserStatsObject *))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    return [OOAPI getStatsForUser:userID
                          success:^(NSDictionary *dictionary) {
                              UserStatsObject *stats= [UserStatsObject statsFromDictionary:dictionary];
                              success(stats);
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              NSLog (@"UNABLE TO GET STATS %@",error);
                              failure( operation, error);
                          }
            ];
}

//------------------------------------------------------------------------------
// Name:    authWithFacebookToken
// Purpose: use the facebook token from FB to authorize the user and get user information OOToken
// Note:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)authWithFacebookToken:(NSString *)facebookToken
                             success:(void (^)(UserObject *user, NSString *token))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!facebookToken) {
        failure(nil,nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/auth/facebook", kHTTPProtocol, [OOAPI URL]];
    
    NSDictionary *parameters = @{kKeyFacebookAccessToken:facebookToken};
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                          NSDictionary *u = [responseObject objectForKey:@"user"];
                                          UserObject *uo = nil;
                                          if (u && [u isKindOfClass:[NSDictionary class]]) {
                                              uo = [UserObject userFromDict:u];
                                          }
                                          NSString *t = [responseObject objectForKey:@"token"];
                                          success(uo, t);
                                          return;
                                      } else {
                                          failure(nil,nil);
                                          return;
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    authWithEmail
// Purpose: use email to authorize the user and get user information OOToken
// Note:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)authWithEmail:(NSString *)email
                                 password:(NSString *)password
                                  success:(void (^)(UserObject *user, NSString *token))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!email || !password || ![email length] || ![password length]) {
        failure(nil,nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/auth/local", kHTTPProtocol, [OOAPI URL]];
    
    NSDictionary *parameters = @{kKeyUserEmail:email,
                                 kKeyUserPassword:password};
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                          NSDictionary *u = [responseObject objectForKey:@"user"];
                                          UserObject *uo = nil;
                                          if (u && [u isKindOfClass:[NSDictionary class]]) {
                                              uo = [UserObject userFromDict:u];
                                          }
                                          NSString *t = [responseObject objectForKey:@"token"];
                                          success(uo, t);
                                          return;
                                      } else {
                                          failure(nil,nil);
                                          return;
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    createUserWithEmail
// Purpose: create a user with an email address
// Note:
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)createUserWithEmail:(NSString *)email
                                    andPassword:(NSString *)password
                                   andFirstName:(NSString *)firstName
                                    andLastName:(NSString *)lastName
                                    success:(void (^)(UserObject *user, NSString *token))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *requestString = [NSString stringWithFormat:@"%@://%@/users", kHTTPProtocol, [OOAPI URL]];
    
    NSDictionary *parameters = @{kKeyUserEmail:email,
                                 kKeyUserPassword:password,
                                 kKeyUserFirstName:firstName,
                                 kKeyUserLastName:lastName};
    
    return [[OONetworkManager sharedRequestManager] POST:requestString
                                              parameters:parameters
                                                 success:^(id responseObject)  {
                                                     NSDictionary *u = [responseObject objectForKey:@"user"];
                                                     UserObject *uo = nil;
                                                     if (u && [u isKindOfClass:[NSDictionary class]]) {
                                                         uo = [UserObject userFromDict:u];
                                                     }
                                                     NSString *t = [responseObject objectForKey:@"token"];
                                                     success(uo, t);

                                                }
                                                failure:failure];
}

+ (AFHTTPRequestOperation *)resetPasswordWithEmail:(NSString *)email
                                           success:(void (^)())success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    if (!email || ![email length]) {
        failure(nil, nil);
        return nil;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSDictionary *parameters = @{kKeyUserEmail:email};
    
    NSString *requestString = [NSString stringWithFormat:@"%@://%@/users/verify/reset", kHTTPProtocol, [OOAPI URL]];
    
    return [rm GET:requestString parameters:parameters
           success:^(id responseObject) {
               success();
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

+ (AFHTTPRequestOperation *)isCurrentUserVerifiedSuccess:(void (^)(BOOL result))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    if (!user) { //should not happen
        success(NO);
        return nil;
    }
    
    if (user.isVerified) { //check if the user is verified locally first
        success(YES);
        return nil;
    }
    
    return [OOAPI getUserWithID:user.userID success:^(UserObject *user) {
        if (user.isVerified) {
            //update the user
            [Settings sharedInstance].userObject.isVerified = YES;
            [[Settings sharedInstance] save];
            success(YES);
        } else {
            success(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSInteger statusCode = operation.response.statusCode;
        NSLog(@"Error: %@, status code %ld", error, (long)statusCode);
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)resendVerificationForCurrentUserSuccess:(void (^)(BOOL))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    if (!user) { //should not happen
        success(NO);
        return nil;
    }
    
    NSString *requestString = [NSString stringWithFormat:@"%@://%@/users/%lu/verify/resend", kHTTPProtocol, [OOAPI URL],(unsigned long)user.userID];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    return [rm GET:requestString parameters:nil
           success:^(id responseObject) {
               success(YES);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"Error: %@", error);
               failure(operation, error);
           }];
}

+ (AFHTTPRequestOperation *)sendAppLog:(AppLogObject *)appLog
                               success:(void (^)())success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    if  (!appLog || !appLog.userID) {
        failure (nil,nil);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/appLogs",
                           kHTTPProtocol, [OOAPI URL]];
    
    NSDictionary *parameters = @{
                        kKeyAppLogUserID : [NSString stringWithFormat:@"%lu", (unsigned long)appLog.userID],
                        kKeyAppLogDeviceType : appLog.deviceType,
                        kKeyAppLogOS: appLog.OS,
                        kKeyAppLogBuildNumber: appLog.buildNumber,
                        kKeyAppLogAppVersion: appLog.appVersion,
                        kKeyAppLogLatitude : [NSString stringWithFormat:@"%.6f", appLog.location.latitude],
                        kKeyAppLogLongitude : [NSString stringWithFormat:@"%.6f", appLog.location.longitude],
                        kKeyAppLogOriginScreen : appLog.originScreen,
                        kKeyAppLogEventType : appLog.eventType,
                        kKeyAppLogP1 : appLog.p1,
                        kKeyAppLogP2 : appLog.p2,
                        kKeyAppLogP3 : appLog.p3,
                        kKeyAppLogP4 : appLog.p4,
                        kKeyAppLogP5 : appLog.p5
          };
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    AFHTTPRequestOperation *op = [rm POST:urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                                      failure(operation, error);
                                  }];
    return op;
}

+ (NSString *)URL
{
// To alleviate the need for commenting this out
// create a new build target which is a duplicate of Release
// and call it Adhoc. In the build settings for Adhoc
// add the compiler flag -DADHOC
 
//#ifdef ADHOC
//    APP.usingStagingServer = YES;
//    if (APP.usingStagingServer) {
     return kOOURLStage;
//    } else {
 //      return kOOURLProduction;
//    }
//#else
  //return kOOURLProduction;
//#endif
}

@end

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

//NSString *const kKeyName = @"name";

@interface OOAPI()
- (NSString *)ooURL;
@end

@implementation OOAPI

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
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
        maxWidth = (isRetinaDisplay()) ? 2*maxWidth: maxWidth;
        [parameters setObject:[NSString stringWithFormat:@"%tu", maxWidth] forKey:@"maxwidth"];
    } else if (maxHeight) {
        maxHeight = (isRetinaDisplay()) ? 2*maxHeight: maxHeight;
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
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(NSError *))failure
{
    if (!keyword ) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/search", kOOURL];
    NSDictionary *parameters = @{@"keyword":keyword,
                                 kKeyRestaurantLatitude:[NSNumber numberWithFloat:location.latitude],
                                 kKeyRestaurantLongitude:[NSNumber numberWithFloat:location.longitude],
                                 kKeyRestaurantOpenNow:[NSNumber numberWithBool:openOnly]};
    
//    NSLog (@" URL=  %@",urlString);
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET: urlString parameters:parameters success:^(id responseObject) {
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
                                            andFilter: (NSString*)filterName
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
                                 @"latitude": @(location.latitude),
                                 @"longitude":@(location.longitude),
                                 @"filter": filterName ?:  @"",
                                 @"radius": @(radius)
                                 };
    
//    NSLog (@" URL=  %@",urlString);
    NSLog  (@" radius=   %f", radius);
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET: urlString parameters:parameters success:^(id responseObject) {
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
                                        success:(void (^)(NSArray *restaurants))success
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
    
    //    NSLog (@" URL=  %@",urlString);
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET: urlString parameters:parameters success:^(id responseObject) {
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
        UserObject* userInfo= [Settings sharedInstance].userObject;
        userID= [userInfo.userID unsignedIntegerValue];
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

//    UserObject* userInfo= [Settings sharedInstance].userObject;
//    NSUInteger userID = [userInfo.userID unsignedIntegerValue];

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
// Name:    lookupUsername
// Purpose: Ascertain whether a username is already in use.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)lookupUsername:(NSString *)string
                                  success:(void (^)(NSArray *users))success
                                  failure:(void (^)(NSError *))failure;
{
    if  (!string || !string.length) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/usernames/%@",
                           kOOURL, string];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:success failure: failure];
}

//------------------------------------------------------------------------------
// Name:    clearUsernameOf
// Purpose: For testing.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)clearUsernameWithSuccess:(void (^)(NSArray *names))success
                                   failure:(void (^)(NSError *))failure;
{
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSNumber* userid= userInfo.userID;
    
    NSString *requestString=[NSString stringWithFormat: @"https://%@/users/%@",
                   kOOURL, userid];
    
    requestString= [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    return [[OONetworkManager sharedRequestManager] PUT: requestString
                                      parameters: @{
                                                     @"username": @""
                                                    }
                                                success: success  failure: failure];
}

//------------------------------------------------------------------------------
// Name:    fetchSampleUsernames
// Purpose: Ascertain whether a username is already in use.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation *)fetchSampleUsernamesFor:(NSString *)emailAddressString
                                  success:(void (^)(NSArray *names))success
                                  failure:(void (^)(NSError *))failure;
{
    if  (!emailAddressString || !emailAddressString.length) {
        failure (nil);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/usernames?email=%@",
                           kOOURL, emailAddressString];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:success failure: failure];
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

    
    //return [rm GET:urlString parameters:nil success:success failure: failure];
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
    if  (!listName) {
        failure (nil);
        return nil;
    }
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSNumber*userid= userInfo.userID;
    if  (! userid) {
        failure (nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/lists", kOOURL, userid];
    NSDictionary*parameters=  @{
                                 @"name": listName,
                                  @"type":  @2,
                                  @"user": userid
                                };
    AFHTTPRequestOperation *op = [rm POST: urlString parameters:parameters
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
    if  (!restaurants) {
        failure (nil);
        return nil;
    } else {
        restaurantIDs = [NSMutableArray array];
        [restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RestaurantObject *ro = (RestaurantObject *)obj;
            [restaurantIDs addObject:ro.restaurantID];
        }];
    }
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSNumber*userid= userInfo.userID;
    if  (! userid) {
        failure (nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%@/favorites/restaurants", kOOURL, userid];
    
    NSString *IDs = [restaurantIDs componentsJoinedByString:@","];
    NSDictionary *parameters=  @{
                                @"restaurant_ids": IDs
                                };
    AFHTTPRequestOperation *op = [rm POST: urlString parameters:parameters
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
    if  (!listId) {
        failure(nil);
        return nil;
    }
    
    NSMutableArray *restaurantIDs;
    if  (!restaurants) {
        failure (nil);
        return nil;
    } else {
        restaurantIDs = [NSMutableArray array];
        [restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RestaurantObject *ro = (RestaurantObject *)obj;
            [restaurantIDs addObject:ro.restaurantID];
        }];
    }
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSNumber*userid= userInfo.userID;
    if  (! userid) {
        failure (nil);
        return nil;
    }
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists/%tu/restaurants", kOOURL, listId];
    
    NSString *IDs = [restaurantIDs componentsJoinedByString:@","];
    NSDictionary *parameters=  @{
                                 @"restaurant_ids": IDs
                                 };
    AFHTTPRequestOperation *op = [rm POST: urlString parameters:parameters
                                  success:^(id responseObject) {
                                      success(responseObject);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
    
    return op;
}

//------------------------------------------------------------------------------
// Name:    getRestaurantImageWithImageRef
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
    [parameters setObject: identifier forKey:@"identifier"];
    
    if (maxWidth) {
        maxWidth = (isRetinaDisplay()) ? 2*maxWidth: maxWidth;
        [parameters setObject:[NSString stringWithFormat:@"%tu", maxWidth] forKey:@"maxwidth"];
    } else if (maxHeight) {
        maxHeight = (isRetinaDisplay()) ? 2*maxHeight: maxHeight;
        [parameters setObject:[NSString stringWithFormat:@"%tu", maxWidth] forKey:@"maxHeight"];
    }
    
    return [rm GET:urlString parameters:parameters success:^(id responseObject) {
        success([responseObject objectForKey:@"link"]);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//------------------------------------------------------------------------------
// Name:    uploadUserPhoto
// Purpose:
//------------------------------------------------------------------------------
+ (void)uploadUserPhoto:(UIImage *)image
                                    success:(void (^)(void))success
                                    failure:(void (^)(NSError *))failure;
{
    if  (!image) {
        failure (nil);
        return ;
    }
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/photo", kOOURL];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[ NSURL  URLWithString: urlString]];
    if  (!request) {
        failure (nil);
        return ;
    }
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request
                                                         fromData:imageData
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        if (failure) failure(error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                        if  (httpResp.statusCode == 200 ) {
                                                            if (success) success();
                                                        }else {
                                                            NSLog (@"IMAGE UPLOAD FAILURE:  %ld", (long)httpResp.statusCode);
                                                            if (failure) failure(error);
                                                        }
                                                        
                                                    }
                                                }];
    [task resume];
}

- (NSString *)ooURL {
    return kOOURL;
}

@end

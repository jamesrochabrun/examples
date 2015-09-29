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
// Name:    getRestaurantImageWithImageRef
// Purpose:
//------------------------------------------------------------------------------
//
// Only one of max width or max height is heeded. Preference is given to max width
//
- (AFHTTPRequestOperation *)getRestaurantImageWithImageRef:(ImageRefObject *)imageRef
                                                  maxWidth:(NSUInteger)maxWidth
                                                 maxHeight:(NSUInteger)maxHeight
                                                   success:(void (^)(NSString *link))success
                                                   failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/restaurants/photos", [self ooURL]];
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:imageRef.reference forKey:@"reference"];
    
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
// Name:    getRestaurantsWithKeyword
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation *)getRestaurantsWithKeyword:(NSString *)keyword
                                          andLocation:(CLLocationCoordinate2D)location
                                              success:(void (^)(NSArray *restaurants))success
                                              failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/search", kOOURL];
    NSDictionary *parameters = @{@"keyword":keyword,@"latitude":[NSNumber numberWithFloat:location.latitude],@"longitude":[NSNumber numberWithFloat:location.longitude]};
    
    NSLog (@" URL=  %@",urlString);
    
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
// Name:    getListsOfUser
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation*)getListsOfUser:(NSInteger)userid
                                  success:(void (^)(NSArray *lists))success
                                  failure:(void (^)(NSError *))failure
{
    if  (userid<0 ) {
        UserObject* userInfo= [Settings sharedInstance].userObject;
        userid= [userInfo.userID integerValue ];
    }
    NSString *urlString = [NSString stringWithFormat:@"https://%@/users/%ld/lists",
                           kOOURL, ( long)userid];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:success failure: failure];
}

//------------------------------------------------------------------------------
// Name:    lookupUsername
// Purpose: Ascertain whether a username is already in use.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation*)lookupUsername:(NSString *)string
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
// Name:    fetchSampleUsernames
// Purpose: Ascertain whether a username is already in use.
//------------------------------------------------------------------------------
+ (AFHTTPRequestOperation*)fetchSampleUsernamesFor:(NSString *)emailAddressString
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
- (AFHTTPRequestOperation*)getRestaurantsWithListID:(long)identifier
                                            success:(void (^)(NSArray *lists))success
                                            failure:(void (^)(NSError *))failure
{
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists/%ld/restaurants",
                           kOOURL,
                           identifier];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:urlString parameters:nil success:success failure: failure];
}

//------------------------------------------------------------------------------
// Name:    addRestaurant
// Purpose:
//------------------------------------------------------------------------------
- (AFHTTPRequestOperation*)addRestaurant:(RestaurantObject *)restaurant
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
    NSString *urlString = [NSString stringWithFormat:@"https://%@/lists", kOOURL];
    NSDictionary*parameters=  @{
                                 @"name": listName,
                                  @"type":  @"2",
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

- (NSString *)ooURL {
    return kOOURL;
}

@end

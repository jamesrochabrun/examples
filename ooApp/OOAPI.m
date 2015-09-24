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

- (AFHTTPRequestOperation*) getRestaurantsWithIDs:(NSArray *)restaurantIds success:(void(^)(NSArray *restaurants))success failure:(void (^)(NSError *))failure
{
    NSString *URL = [NSString stringWithFormat:@"https://%@/restaurants", [self ooURL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init];

    
    return [rm GET:URL parameters:nil success:^(id responseObject) {
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

//
// Only one of max width or max height is heeded. Preference is given to max width
//
- (AFHTTPRequestOperation *)getRestaurantImageWithImageRef:(ImageRefObject *)imageRef maxWidth:(NSUInteger)maxWidth maxHeight:(NSUInteger)maxHeight success:(void(^)(NSString *link))success failure:(void (^)(NSError *))failure
{
    NSString *URL = [NSString stringWithFormat:@"https://%@/restaurants/photos", [self ooURL]];
    
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
    
    return [rm GET:URL parameters:parameters success:^(id responseObject) {
        success([responseObject objectForKey:@"link"]);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



- (AFHTTPRequestOperation*) getRestaurantsWithKeyword:(NSString *)keyword andLocation:(CLLocationCoordinate2D)location success:(void(^)(NSArray *restaurants))success failure:(void (^)(NSError *))failure
{
    
    NSString *URL = [NSString stringWithFormat:@"https://%@/search", [self ooURL]];
    NSDictionary *parameters = @{@"keyword":keyword,@"latitude":[NSNumber numberWithFloat:location.latitude],@"longitude":[NSNumber numberWithFloat:location.longitude]};
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:URL parameters:parameters success:^(id responseObject) {
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

- (AFHTTPRequestOperation*)getUsersWithIDs:(NSArray *)userIDs success:(void(^)(NSArray *users))success failure:(void (^)(NSError *))failure
{
    NSString *URL = [NSString stringWithFormat:@"https://%@/users", [self ooURL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    return [rm GET:URL parameters:nil success:^(id responseObject) {
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

- (AFHTTPRequestOperation*)getDishesWithIDs:(NSArray *)dishIDs success:(void (^)(NSArray *dishes))success failure:(void (^)(NSError *))failure
{
    NSString *URL = [NSString stringWithFormat:@"https://%@/dishes", [self ooURL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    return [rm GET:URL parameters:nil success:^(id responseObject) {
        for (id dict in responseObject) {
            NSLog(@"dish: %@", dict);
        }
    } failure:^(NSError *error) {
        failure(error);
        NSLog(@"Error: %@", error);
    }];
}

- (AFHTTPRequestOperation*)addRestaurant:(RestaurantObject *)restaurant success:(void (^)(NSArray *dishes))success failure:(void (^)(NSError *))failure
{
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *URL = [NSString stringWithFormat:@"https://%@/restaurants", [self ooURL]];
    
    AFHTTPRequestOperation *op = [rm POST:URL parameters:[RestaurantObject dictFromRestaurant:restaurant] success:^(id responseObject) {
        ;
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return op;
}

- (AFHTTPRequestOperation*)addList:(ListObject *)list success:(void (^)(NSArray *dishes))success failure:(void (^)(NSError *))failure
{
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *URL = [NSString stringWithFormat:@"https://%@/lists", [self ooURL]];
    
    AFHTTPRequestOperation *op = [rm POST:URL parameters:[ListObject dictFromList:list] success:^(id responseObject) {
        ;
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return op;
}

- (NSString *)ooURL {
    return kOOURL;
}

@end

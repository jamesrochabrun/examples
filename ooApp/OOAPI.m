//
//  OOAPI.m
//  ooApp
//
//  Created by Anuj Gujar on 8/6/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "OOAPI.h"
#import "RestaurantObject.h"
#import "UserObject.h"

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

- (void)getRestaurantsWithIDs:(NSArray *)restaurantIds success:(void(^)(NSArray *restaurants))success failure:(void (^)(NSError *))failure {
    NSString *URL = [NSString stringWithFormat:@"http://%@/restaurants", [self ooURL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init];

    
    [rm GET:URL parameters:nil success:^(id responseObject) {
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

- (void)getUsersWithIDs:(NSArray *)userIDs success:(void(^)(NSArray *users))success failure:(void (^)(NSError *))failure {
    NSString *URL = [NSString stringWithFormat:@"http://%@/users", [self ooURL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    
    [rm GET:URL parameters:nil success:^(id responseObject) {
        NSMutableArray *users = [NSMutableArray array];
        for (id dict in responseObject) {
//            NSLog(@"user: %@", dict);
            [users addObject:[UserObject userFromDict:dict]];
        }
        success(users);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)getDishesWithIDs:(NSArray *)dishIDs success:(void (^)(NSArray *dishes))success failure:(void (^)(NSError *))failure {
    NSString *URL = [NSString stringWithFormat:@"http://%@/dishes", [self ooURL]];
    OONetworkManager *rm = [[OONetworkManager alloc] init] ;
    
    [rm GET:URL parameters:nil success:^(id responseObject) {
//        NSMutableArray *restaurants = [NSMutableArray array];
        for (id dict in responseObject) {
            NSLog(@"dish: %@", dict);
//            [restaurants addObject:[self restaurantFromDict:dict]];
        }
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)addRestaurant:(RestaurantObject *)restaurant success:(void (^)(NSArray *dishes))success failure:(void (^)(NSError *))failure {
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    NSString *URL = [NSString stringWithFormat:@"http://%@/restaurants", [self ooURL]];
    [rm POST:URL parameters:[RestaurantObject dictFromRestaurant:restaurant] success:^(id responseObject) {
        ;
    } failure:^(NSError *error) {
        ;
    }];
}



- (NSString *)ooURL {
    return @"www.oomamiapp.com";
}

@end

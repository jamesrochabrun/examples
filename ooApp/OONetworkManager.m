//
//  OONetworkManager.m
//  ooApp
//
//  Created by Anuj Gujar on 7/29/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "OONetworkManager.h"


@implementation OONetworkManager

@synthesize requestManager;

+ (id)sharedRequestManager {
    static OONetworkManager *sharedRequestManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRequestManager = [[self alloc] init];
        sharedRequestManager.requestManager = [AFHTTPRequestOperationManager manager];
    });
    return sharedRequestManager;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure {
    
    OONetworkManager *nm = [OONetworkManager sharedRequestManager];
    nm.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    nm.requestManager.responseSerializer.acceptableContentTypes = [NSMutableSet setWithObjects:@"application/json", @"text/html", nil];
    
    [nm.requestManager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure {

    OONetworkManager *nm = [OONetworkManager sharedRequestManager];
    nm.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    nm.requestManager.responseSerializer.acceptableContentTypes = [NSMutableSet setWithObjects:@"application/json", @"text/html", nil];
    [nm.requestManager.requestSerializer setValue:@"9b9e2d8b047f63b7b5684c42388fd5ac" forHTTPHeaderField:@"authorization"];
    
    [nm.requestManager POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



@end

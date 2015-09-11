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

- (AFHTTPRequestOperation*) GET:(NSString *)path parameters:(NSDictionary *)parameters
                        success:(void (^)(id responseObject))success
                        failure:(void (^)(NSError *error))failure
{
    NSLog  (@"GET:  %@", path);
    OONetworkManager *nm = [OONetworkManager sharedRequestManager];
    nm.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    nm.requestManager.responseSerializer.acceptableContentTypes = [NSMutableSet setWithObjects:@"application/json", @"text/html", nil];
    
    return [nm.requestManager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (AFHTTPRequestOperation*) POST:(NSString *)path parameters:(NSDictionary *)parameters
                         success:(void (^)(id responseObject))success
                         failure:(void (^)(NSError *error))failure
{
    NSLog  (@"POST:  %@", path);
    OONetworkManager *nm = [OONetworkManager sharedRequestManager];
    nm.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    nm.requestManager.responseSerializer.acceptableContentTypes = [NSMutableSet setWithObjects:@"application/json", @"text/html", nil];
    [nm.requestManager.requestSerializer setValue:@"9b9e2d8b047f63b7b5684c42388fd5ac" forHTTPHeaderField:@"authorization"];
    
    return [nm.requestManager POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (AFHTTPRequestOperation*) PUT:(NSString *)path parameters:(NSDictionary *)parameters
                         success:(void (^)(id responseObject))success
                         failure:(void (^)(NSError *error))failure
{
    NSLog  (@"PUT:  %@", path);
    OONetworkManager *nm = [OONetworkManager sharedRequestManager];
    nm.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    nm.requestManager.responseSerializer.acceptableContentTypes = [NSMutableSet setWithObjects:@"application/json", @"text/html", nil];
    [nm.requestManager.requestSerializer setValue:@"9b9e2d8b047f63b7b5684c42388fd5ac" forHTTPHeaderField:@"authorization"];
    
    return [nm.requestManager PUT:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (AFHTTPRequestOperation*) DELETE:(NSString *)path parameters:(NSDictionary *)parameters
                        success:(void (^)(id responseObject))success
                        failure:(void (^)(NSError *error))failure
{
    NSLog  (@"DELETE:  %@", path);

    OONetworkManager *nm = [OONetworkManager sharedRequestManager];
    nm.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    nm.requestManager.responseSerializer.acceptableContentTypes = [NSMutableSet setWithObjects:@"application/json", @"text/html", nil];
    [nm.requestManager.requestSerializer setValue:@"9b9e2d8b047f63b7b5684c42388fd5ac" forHTTPHeaderField:@"authorization"];
    
    return [nm.requestManager DELETE:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}


@end

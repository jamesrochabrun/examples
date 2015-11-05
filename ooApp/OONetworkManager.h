//
//  OONetworkManager.h
//  ooApp
//
//  Created by Anuj Gujar on 7/29/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface OONetworkManager : NSObject {
    AFHTTPRequestOperationManager *_requestManager;
}

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

+ (id)sharedRequestManager;

//-(void)getResource:(NSString *)url;
- (AFHTTPRequestOperation *)GET:(NSString *)path parameters:(NSDictionary *)parameters
                        success:(void (^)(id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation*operation,NSError *error))failure;

- (AFHTTPRequestOperation*) POST:(NSString *)path parameters:(NSDictionary *)parameters
                         success:(void (^)(id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation*operation,NSError *error))failure;

- (AFHTTPRequestOperation*) PUT:(NSString *)path parameters:(NSDictionary *)parameters
                        success:(void (^)(id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation*operation,NSError *error))failure;

- (AFHTTPRequestOperation*) DELETE:(NSString *)path parameters:(NSDictionary *)parameters
                           success:(void (^)(id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation*operation,NSError *error))failure;

- (AFHTTPRequestOperation*) PATCH:(NSString *)path parameters:(NSDictionary *)parameters
                          success:(void (^)(id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation*operation,NSError *error))failure;

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

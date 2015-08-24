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
- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure;

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;
@end

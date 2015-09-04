//
//  CacheManager.m
//  Oomami
//
//  Created by Zack on 9/1/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+AFNetworking.h"
#import "CacheManager.h"
#import "UserObject.h"

@interface CacheManager ()

@end

@implementation CacheManager

//------------------------------------------------------------------------------
// Name:    +sharedInstance
// Purpose: Provides the singleton instance.
//------------------------------------------------------------------------------
+ (instancetype) sharedInstance;
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)  init
{
    self= [super init];
    if  (self) {
    }
    return self;
}

- (void) dealloc
{
}

- (void) fetchImageAsynchronously:(NSString*) urlString into:(UIImageView*) imageView;
{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: urlString]
                                                  cachePolicy: NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval: 60];
    
    [imageView setImageWithURLRequest:imageRequest
                     placeholderImage:[UIImage imageNamed:@"placeholder"]
                              success:nil
                              failure:nil];
}

- (void) cancelDownloadsForImageView:(UIImageView*) imageView;
{
    [imageView cancelImageRequestOperation];
}

@end








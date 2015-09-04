//
//  CacheManager.h
//  Oomami
//
//  Created by Zack on 9/1/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Settings.h"

@interface CacheManager : NSObject

+ (instancetype) sharedInstance;

- (void) fetchImageAsynchronously:(NSString*) urlString into:(UIImageView*) imageView;
- (void) cancelDownloadsForImageView:(UIImageView*) imageView;

@end


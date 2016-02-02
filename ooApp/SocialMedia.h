//
//  SocialMedia.h: helper routines e.g. facebook.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface SocialMedia : NSObject

+ (void)fetchProfilePhotoWithCompletionBlock:(void (^)(NSString*))completionBlock;
+ (void) fetchUserFriendListFromFacebook:(void (^)(NSArray *friends))completionBlock;

@end

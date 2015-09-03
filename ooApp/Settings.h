//
//  Settings.h
//  Oomami
//
//  Created by Zack on 9/1/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserObject.h"

extern NSString *const kDefaultsCurrentUserInfo;

@interface Settings : NSObject

+ (instancetype) sharedInstance;

- (UserObject*) currentUser;
- (void) setCurrentUser: (UserObject*) user;

- (NSArray*) mostRecentChoice: (NSString *) key;
- (void) setMostRecentChoice: (NSString *) key to:(NSArray*) ary;

@end


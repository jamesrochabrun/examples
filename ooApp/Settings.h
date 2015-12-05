//
//  Settings.h
//  Oomami
//
//  Created by Zack on 9/1/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "UserObject.h"

extern NSString *const kDefaultsCurrentUserInfo;
extern NSString *const kDefaultsUniqueDeviceKey;

@interface Settings : NSObject

@property (strong, nonatomic) UserObject *userObject;

+ (instancetype)sharedInstance;

- (void)save;
- (void)clearUser;

- (void)setCurrentUser:(UserObject *)user;

- (NSArray *)mostRecentChoice:(NSString *)key;
- (void)setMostRecentChoice:(NSString *)key to:(NSArray *)ary;

- (CLLocationCoordinate2D)mostRecentLocation;
- (void)setMostRecentLocation:(CLLocationCoordinate2D)coord;
- (void)removeMostRecentLocation;
- (void)removeUser;

- (NSString *)lastKnownDateString;
- (void)saveDateString:(NSString *)string;
- (void)removeDateString;

- (double)searchRadius;
- (void)setSearchRadius:(double)r;
- (void)removeSearchRadius;

- (NSString *)uniqueDeviceKey;

@end


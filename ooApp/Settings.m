//
//  Settings.m
//  Oomami
//
//  Created by Zack on 9/1/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManager.h"
#import "Settings.h"
#import "UserObject.h"

NSString *const kDefaultsCurrentUserInfo = @"currentUser";
NSString *const kDefaultsLastKnownDate = @"lastKnownDate";

@implementation Settings

//------------------------------------------------------------------------------
// Name:    +sharedInstance
// Purpose: Provides the singleton instance.
//------------------------------------------------------------------------------
+ (instancetype)sharedInstance;
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self readUser];
        if (!_userObject) {
            _userObject= [[UserObject alloc] init];
        }
        
    }
    return self;
}

//------------------------------------------------------------------------------
// Name:    save
// Purpose: Make sure all of user defaults is on disk.
//------------------------------------------------------------------------------
- (void)save;
{
    [self storeUser];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud  synchronize];
}

//------------------------------------------------------------------------------
// Name:    readUser
// Purpose: Loads the user dict.
//------------------------------------------------------------------------------
- (void)readUser
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *d= [ud dictionaryForKey: kDefaultsCurrentUserInfo];
    if (!d) {
        NSLog (@"NO USER INFO FOUND.");
        return;
    }
    self.userObject = [UserObject userFromDict:d];
}

//------------------------------------------------------------------------------
// Name:    setCurrentUser
// Purpose: Saves the user dict.
//------------------------------------------------------------------------------
- (void)setCurrentUser:(UserObject *)user
{
    if (!user) {
        return;
    }
    self.userObject= user;
}

- (NSString *)lastKnownDateString;
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return  [ud stringForKey:kDefaultsLastKnownDate];
}

- (void)storeUser
{
    NSDictionary *d= [self.userObject dictionaryFromUser];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject: d forKey: kDefaultsCurrentUserInfo];
    [ud synchronize];
}

//------------------------------------------------------------------------------
// Name:    mostRecentChoice
// Purpose: Returns the date and boolean for a recent user choice.
//------------------------------------------------------------------------------
- (NSArray *)mostRecentChoice:(NSString *)key;
{
    if  (!key) {
        return nil;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *ary = [ud arrayForKey:key];
    if (!ary || ary.count != 2) {
        return nil;
    }
    NSDate *date = ary[0];
    if ([date isKindOfClass:[NSDate class]]) {
        return ary;
    }
    return nil;
}

//------------------------------------------------------------------------------
// Name:    setMostRecentChoice
// Purpose: Stores the date and boolean for a recent user choice.
//------------------------------------------------------------------------------
- (void)setMostRecentChoice:(NSString *)key to:(NSArray *)ary
{
    if  (!key || !ary || ary.count != 2) {
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *date = ary[0];
    if ([date isKindOfClass: [NSDate class]]) {
        [ud setObject: ary forKey: key];
        [ud synchronize];
    }
}

- (CLLocationCoordinate2D)mostRecentLocation
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    double lat = [ud doubleForKey:kDefaultsUserLocationLastKnownLatitude];
    double lon = [ud doubleForKey:kDefaultsUserLocationLastKnownLongitude];
    return  CLLocationCoordinate2DMake(lat,lon);
}

- (void)setMostRecentLocation:(CLLocationCoordinate2D)coord;
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setDouble:coord.latitude forKey:kDefaultsUserLocationLastKnownLatitude];
    [ud setDouble:coord.longitude  forKey:kDefaultsUserLocationLastKnownLongitude];
}

@end








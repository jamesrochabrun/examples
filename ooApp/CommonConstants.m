//
//  CommonConstants.m
//  ooApp
//
//  Created by Anuj Gujar on 7/31/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonConstants.h"

NSString *const kAPIKeyGoogleMaps = @"AIzaSyDXafe9HUhTGZ_aWBfSo340uLYlJOpA95Q";

#if 1 //beta key
NSString *const kAPIKeyInstabug = @"bea287aa56f2d9ee7b66d8899f801938";
#else
NSString *const kAPIKeyInstabug = @"b98174251aa663e9f299ea17bd8ab1b4";
#endif

NSString *const kUserDefaultsUsingStagingServer = @"usingStaging";
NSString *const kNotificationMenuWillOpen = @"notificationMenuWillOpen";

NSString *const kSearchPlaceholderPeople = @"Find friends and foodies";
NSString *const kSearchPlaceholderYou = @"Find places on your lists";
NSString *const kSearchPlaceholderPlaces = @"Find restaurants, bars, etc";
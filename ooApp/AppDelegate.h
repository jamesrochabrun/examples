//
//  AppDelegate.h
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserObject.h"
#import "TimeUtilities.h"
#import "EventObject.h"
#import "EventsListVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) BOOL usingStagingServer;
@property (nonatomic, strong) UIImage *imageForNoProfileSilhouette;
@property (nonatomic, strong) NSDate *dateLeft;
@property (nonatomic, strong) UINavigationController *nc;
@property (nonatomic, strong) EventsListVC *e1;
@property (nonatomic, strong) UITabBarController *tabBar;

- (BOOL)connected;
- (void)registerForPushNotifications;
- (void)clearCache;
- (void)processNotifications;
- (void)openLink;

@end


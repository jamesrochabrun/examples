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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableString *diagnosticLogString;
@property (nonatomic, assign) BOOL usingStagingServer;
@property (nonatomic, strong) UIImage *imageForNoProfileSilhouette;
@property (nonatomic, strong) NSDate *dateLeft;
@property (nonatomic, strong) UINavigationController *nc;

- (BOOL)connected;
- (void)registerForPushNotifications;
- (void)clearCache;
- (void)processNotifications;

// Later, remove from production
#define ENTRY { [APP.diagnosticLogString appendFormat:  @"Entered %s\r",__FUNCTION__]; }
#define LOGS(STRING) { [APP.diagnosticLogString appendFormat: @"%@\r",STRING]; }
#define LOGS2(STRING1,STRING2) { [APP.diagnosticLogString appendFormat: @"%@: %@\r",STRING1,STRING2]; }
#define LOGSN(STRING,NUMBER) { [APP.diagnosticLogString appendFormat: @"%@: %lu\r",STRING,(unsigned long)NUMBER]; }

@end


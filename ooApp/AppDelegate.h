//
//  AppDelegate.h
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RestaurantObject.h"
#import "UserObject.h"
#import "TimeUtilities.h"
#import "EventObject.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) NSMutableString *diagnosticLogString;
@property (nonatomic,strong) EventObject *eventBeingEdited;
@property (nonatomic,assign) BOOL usingStagingServer;

- (BOOL)connected;

@end


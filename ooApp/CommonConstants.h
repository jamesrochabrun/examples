//
//  CommonConstants.h
//  ooApp
//
//  Created by Anuj Gujar on 7/31/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef ooApp_Common_h
#define ooApp_Common_h

static inline CGFloat width(UIView *view) { return view.bounds.size.width; }
static inline CGFloat height(UIView *view) { return view.bounds.size.height; }
static inline CGFloat metersToMiles(CGFloat meters) { return meters/1000/1.6; }

static inline BOOL isRetinaDisplay() {return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0)) ;}

extern NSString *const kAPIKeyGoogleMaps;

#define SECRET_BACKEND_SALT @"48723492NaCl"
#define GOOGLE_ANALYTICS_ID  @"UA-70502958-1"

extern NSString *const kUserDefaultsUsingStagingServer;
extern NSString *const kNotificationMenuWillOpen;

#endif

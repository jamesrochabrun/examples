//
//  Common.h
//  ooApp
//
//  Created by Anuj Gujar on 7/31/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef ooApp_Common_h
#define ooApp_Common_h

static inline CGFloat width(UIView *view) { return view.frame.size.width; }
static inline CGFloat height(UIView *view) { return view.frame.size.height; }
static inline CGFloat metersToMiles(CGFloat meters) { return meters/1000/1.6; }

static inline BOOL isRetinaDisplay() {return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0)) ;}

#define SECRET_BACKEND_SALT @"48723492NaCl"

#endif

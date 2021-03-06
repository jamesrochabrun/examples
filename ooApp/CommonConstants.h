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
static inline CGFloat metersToFeet(CGFloat meters) { return meters*3.28084;}
static inline CGFloat distanceBetweenPoints(CGPoint p1, CGPoint p2) { return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2)); }
static inline CGFloat windowWidth(){return ([[UIApplication sharedApplication] keyWindow].frame.size.width);}
static inline CGFloat windowHeight(){return ([[UIApplication sharedApplication] keyWindow].frame.size.height);}

static inline BOOL isRetinaDisplay() {return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0)) ;}

extern NSString *const kAPIKeyGoogleMaps;
extern NSString *const kAPIKeyInstabug;

extern NSString *const kSupportEmail;
extern NSString *const kWebAppHost;

//#define SECRET_BACKEND_SALT @"48723492NaCl"
#define GOOGLE_ANALYTICS_ID  @"UA-70502958-1"

extern NSString *const kUserDefaultsUsingStagingServer;
extern NSString *const kNotificationMenuWillOpen;

extern NSString *const kSearchPlaceholderPeople;
extern NSString *const kSearchPlaceholderYou;
extern NSString *const kSearchPlaceholderPlaces;

extern NSString *const kLoggingYouIn;

static NSUInteger kFoodFeedPageSize = 100;

static NSUInteger kMaximumRestaurantsPerEvent = 5;
static NSUInteger kMetersMovedBeforeForcedUpdate = 50;

static NSUInteger kMaxSearchRadius = 50000;

static NSInteger kHashRestaurant= 0x20000000;
static NSInteger kHashUser= 0x40000000;
static NSInteger kHashGroup= 0x30000000;

enum {
    kTabIndexNone = -1,
    kTabIndexFoodFeed = 0,
    kTabIndexSearch = 1,
    kTabIndexConnect = 2,
    kTabIndexProfile = 4,
};

#endif

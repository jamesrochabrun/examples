//
//  Common.h: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#ifndef _COMMON_H
#define _COMMON_H

#import "Reachability.h"

@class AppDelegate;
#define APP ((AppDelegate* )[UIApplication sharedApplication].delegate)

#define LOCAL(STR) NSLocalizedString(STR, nil)
#define ON_MAIN_THREAD(BLK) dispatch_async(dispatch_get_main_queue(),BLK)
#define RUN_AFTER(MS,BLK) {dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW,MS * 1000000);dispatch_after(delayTime, dispatch_get_main_queue(), BLK); }
#define IS_IPAD ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )

extern NSString *const kNotificationLocationBecameAvailable;
extern NSString *const kNotificationLocationBecameUnavailable;

extern void message (NSString *str);
extern void message2 (NSString *str, NSString*string);

extern NSString*const kOOURL;
extern NSString *getDateString();
extern NSString* trimString(NSString* s);
extern NSString *platformString();
extern unsigned long msTime (void);

extern NSAttributedString* attributedStringOf(NSString*,double fontSize);
extern NSAttributedString* underlinedAttributedStringOf(NSString* ,double fontSize);
extern NSMutableAttributedString *createPeopleIconString (NSInteger count);

extern UIButton* makeRoundIconButtonForAutolayout(UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth, float radius);
extern UIImageView* makeImageViewFromURL (UIView *parent,NSString* urlString, NSString* placeholderImageName);
extern UIImageView* makeImageView (UIView *parent, id image);
extern UIButton* makeButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth);
extern UIButton* makeRoundIconButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth, float radius);
extern UIButton* makeRoundButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth, float radius);
extern UIButton* makeButtonForAutolayout (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth);
extern UIButton* makeIconButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth);
extern UILabel* makeLabel (UIView *parent, NSString*  text, float fontSize);
extern UILabel* makeAttributedLabel (UIView *parent, NSString*  text, float fontSize);
extern UILabel* makeLabelLeft (UIView *parent, NSString*  text, float fontSize);
extern UITextView* makeTextView (UIView*parent, UIColor *bg, BOOL editable);
extern UILabel* makeIconLabel (UIView *parent, NSString*  text, float fontSize);
extern UIWebView* makeWebView (UIView*parent, id  delegate);
extern UITableView* makeTable (UIView *parent,id  delegate);
extern UIButton* makeAttributedButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth);
extern UIView* makeView (UIView *parent, UIColor* backgroundColor);
extern UIScrollView* makeScrollView (UIView*parent, id  delegate);
extern void addShadowTo (UIView*v);
extern NSMutableArray* makeImageViewsForUsers (UIView *parent, NSMutableOrderedSet*users,  NSUInteger  maximum);

extern NSDate* parseUTCDateFromServer(NSString *string);
extern NSString* parseStringOrNullFromServer (id object);
extern double parseNumberOrNullFromServer (id object);
extern NSInteger parseIntegerOrNullFromServer (id object);
extern NSUInteger parseUnsignedIntegerOrNullFromServer (id object);

extern BOOL isValidEmailAddress (NSString *string);

extern NSString* expressLocalDateTime(NSDate* date);
extern NSString* expressLocalTime(NSDate* date);
extern NSString* expressLocalMonth(NSDate* date);
extern NSInteger getLocalDayNumber (NSDate*);
extern NSInteger getLocalDayOfMonth (NSDate* date);
extern NSInteger getLocalHour (NSDate* date);

static inline BOOL is_reachable(void) {
	NetworkStatus status = [Reachability reachabilityForInternetConnection].currentReachabilityStatus;
	return status ==ReachableViaWiFi || status==ReachableViaWWAN;
}

#endif

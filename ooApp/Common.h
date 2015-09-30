//
//  Common.h: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#ifndef _COMMON_H
#define _COMMON_H

@class AppDelegate;
#define APP ((AppDelegate* )[UIApplication sharedApplication].delegate)

extern void message (NSString *str);

extern NSString*const kOOURL;
extern NSString *getDateString();
extern NSString* trimString(NSString* s);
extern NSString *platformString();

extern NSAttributedString* attributedStringOf(NSString*,double fontSize);
extern NSAttributedString* underlinedAttributedStringOf(NSString* ,double fontSize);

extern UIImageView* makeImageView (UIView *parent, NSString* imageName);
extern UIButton* makeButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth);
extern UILabel* makeLabel (UIView *parent, NSString*  text, float fontSize);
extern UILabel* makeLabelLeft (UIView *parent, NSString*  text, float fontSize);
extern UITextView* makeTextView (UIView*parent, UIColor *bg, BOOL editable);
extern UILabel* makeIconLabel (UIView *parent, NSString*  text, float fontSize);
extern UIWebView* makeWebView (UIView*parent, id  delegate);
extern UITableView* makeTable (UIView *parent,id  delegate);
extern UIButton* makeAttributedButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth);

#endif

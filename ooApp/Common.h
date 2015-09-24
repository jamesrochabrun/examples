//
//  Common.h: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

extern void message (NSString *str);

extern NSString* kOOURL;
extern NSString *getDateString();

extern UIImageView* makeImageView (UIView *parent, NSString* imageName);
extern UIButton* makeButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth);
extern UILabel* makeLabel (UIView *parent, NSString*  text, float fontSize);
extern UILabel* makeLabelLeft (UIView *parent, NSString*  text, float fontSize);
extern UITextView* makeTextView (UIView*parent, UIColor *bg, BOOL editable);
extern UILabel* makeIconLabel (UIView *parent, NSString*  text, float fontSize);


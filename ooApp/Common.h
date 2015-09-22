//
//  Common.h: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

void message (NSString *str);

extern NSString* kOOURL;
extern NSString *getDateString();

extern UIImageView* makeImageView (UIView *parent, NSString* imageName);
extern UIButton* makeButton (UIView *parent, NSString*  title,  UIColor *fg, UIColor *bg, id  target, SEL callback);
extern UILabel* makeLabel (UIView *parent, NSString*  text);
extern UILabel* makeLabelLeft (UIView *parent, NSString*  text);

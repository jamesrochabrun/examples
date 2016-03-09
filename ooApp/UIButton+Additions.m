//
//  UIButton+Additions.m
//  ooApp
//
//  Created by Anuj Gujar on 8/21/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)

- (void)withText:(NSString *)text fontSize:(NSUInteger)fontSize width:(NSUInteger)width height:(NSUInteger)height backgroundColor:(NSUInteger)backColor textColor:(NSUInteger)textColor borderColor:(NSUInteger)borderColor target:(id)target selector:(SEL)selector {
    [self withText:text fontSize:fontSize width:width height:height backgroundColor:backColor target:target selector:selector];
    [self setTitleColor:UIColorRGBA(textColor) forState:UIControlStateNormal];
    self.layer.borderColor = UIColorRGBA(borderColor).CGColor;
    self.layer.borderWidth = 1;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)withText:(NSString *)text fontSize:(NSUInteger)fontSize width:(NSUInteger)width height:(NSUInteger)height backgroundColor:(NSUInteger)backColor target:(id)target selector:(SEL)selector {
    
    if (!width) {
        width = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:kFontLatoRegular size:fontSize]}].width + 2*kGeomSpaceInter;
    }
    
    self.frame = CGRectMake(0, 0, width, height);
    [self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [self setTitle:text forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:kFontLatoRegular size:fontSize];
    [self setTitleColor:UIColorRGBA(kColorBlack) forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(backColor)] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(backColor & 0xFFEEEE)] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorGrayMiddle)] forState:UIControlStateDisabled];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = kGeomCornerRadius;
    
    //    NSArray *views = [NSArray arrayWithObjects:self.titleLabel, nil];
    //    [DebugUtilities addBorderToViews:views];
}

- (void)withIcon:(NSString *)icon fontSize:(NSUInteger)fontSize width:(NSUInteger)width height:(NSUInteger)height backgroundColor:(NSUInteger)backColor target:(id)target selector:(SEL)selector {
    
    if (!width) {
        width = [icon sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:kFontIcons size:fontSize]}].width + 2*kGeomSpaceInter;
    }
    
    self.frame = CGRectMake(0, 0, width, height);
    [self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [self setTitle:icon forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:kFontIcons size:fontSize];
    [self setTitleColor:UIColorRGBA(kColorBlack) forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(backColor)] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(backColor & 0xFFEEEEEE)] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorGrayMiddle)] forState:UIControlStateDisabled];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = kGeomCornerRadius;
    
    //    NSArray *views = [NSArray arrayWithObjects:self.titleLabel, nil];
    //    [DebugUtilities addBorderToViews:views];
}

- (void)roundButtonWithIcon:(NSString *)icon fontSize:(NSUInteger)fontSize width:(NSUInteger)width height:(NSUInteger)height backgroundColor:(NSUInteger)backColor target:(id)target selector:(SEL)selector {
    
    if (!width) {
        width = [icon sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:kFontIcons size:fontSize]}].width + 2*kGeomSpaceInter;
    }
    
    self.frame = CGRectMake(0, 0, width, height);
    [self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [self setTitle:icon forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:kFontIcons size:fontSize];
    [self setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(backColor)] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(backColor & 0xFFEEEEEE)] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorGrayMiddle)] forState:UIControlStateDisabled];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = width/2;
    self.layer.borderColor = UIColorRGBA(kColorTextActiveFaded).CGColor;
    self.layer.borderWidth = 1;
    
    //    NSArray *views = [NSArray arrayWithObjects:self.titleLabel, nil];
    //    [DebugUtilities addBorderToViews:views];
}

@end

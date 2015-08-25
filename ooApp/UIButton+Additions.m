//
//  UIButton+Additions.m
//  ooApp
//
//  Created by Anuj Gujar on 8/21/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)

- (void)withText:(NSString *)text fontSize:(NSUInteger)fontSize width:(NSUInteger)width height:(NSUInteger)height backgroundColor:(NSUInteger)backColor target:(id)target selector:(SEL)selector {
    
    if (!width) {
        width = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:kFontLatoRegular size:fontSize]}].width + 2*kGeomSpaceInter;
    }
    
    self.frame = CGRectMake(0, 0, width, height);
    [self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [self setTitle:text forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:kFontLatoRegular size:fontSize];
    [self setTitleColor:UIColorRGBA(kColorWhite) forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(backColor)] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(backColor & 0xEEEEEEFF)] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorGrayMiddle)] forState:UIControlStateDisabled];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = kGeomCornerRadius;
    
    //    NSArray *views = [NSArray arrayWithObjects:self.titleLabel, nil];
    //    [DebugUtilities addBorderToViews:views];
}


@end

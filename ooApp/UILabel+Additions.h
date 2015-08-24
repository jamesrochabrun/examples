//
//  UILabel+Additions.h
//  ooApp
//
//  Created by Anuj Gujar on 8/21/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UILabel (Additions)

- (void)withFont:(UIFont *)font textColor:(NSUInteger)color backgroundColor:(NSUInteger)backgroundColor;
- (void)withFont:(UIFont *)font textColor:(NSUInteger)color backgroundColor:(NSUInteger)backgroundColor numberOfLines:(NSInteger)numberOfLines lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment;

@end

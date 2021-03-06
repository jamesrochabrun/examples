//
//  UIButton+Additions.h
//  ooApp
//
//  Created by Anuj Gujar on 8/21/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIButton (Additions)

- (void)withText:(NSString *)text fontSize:(NSUInteger)fontSize width:(NSUInteger)width height:(NSUInteger)height backgroundColor:(NSUInteger)backColor target:(id)target selector:(SEL)selector;
- (void)withText:(NSString *)text fontSize:(NSUInteger)fontSize width:(NSUInteger)width height:(NSUInteger)height backgroundColor:(NSUInteger)backColor textColor:(NSUInteger)textColor borderColor:(NSUInteger)borderColor target:(id)target selector:(SEL)selector;
- (void)withIcon:(NSString *)text fontSize:(NSUInteger)fontSize width:(NSUInteger)width height:(NSUInteger)height backgroundColor:(NSUInteger)backColor target:(id)target selector:(SEL)selector;
- (void)roundButtonWithIcon:(NSString *)icon fontSize:(NSUInteger)fontSize width:(NSUInteger)width height:(NSUInteger)height backgroundColor:(NSUInteger)backColor target:(id)target selector:(SEL)selector;

@end

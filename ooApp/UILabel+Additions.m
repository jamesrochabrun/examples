//
//  UILabel+Additions.m
//  ooApp
//
//  Created by Anuj Gujar on 8/21/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "UILabel+Additions.h"

@implementation UILabel (Additions)

- (void)withFont:(UIFont *)font textColor:(NSUInteger)color backgroundColor:(NSUInteger)backgroundColor {
    self.font = font;
    self.textColor = UIColorRGBA(color);
    self.backgroundColor = UIColorRGBA(backgroundColor);
    self.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)withFont:(UIFont *)font textColor:(NSUInteger)color backgroundColor:(NSUInteger)backgroundColor numberOfLines:(NSInteger)numberOfLines lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment {
    
    [self withFont:font textColor:color backgroundColor:backgroundColor];
    
    self.numberOfLines = numberOfLines;
    self.lineBreakMode = lineBreakMode;
    self.textAlignment = textAlignment;
}

@end

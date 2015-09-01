//
//  UIImage+Additions.m
//  ooApp
//
//  Created by Anuj Gujar on 8/21/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

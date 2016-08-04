//
//  DebugUtilities.m
//  ooApp
//
//  Created by Anuj Gujar on 8/19/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "DebugUtilities.h"

@implementation DebugUtilities

+ (void)addBorderToViews:(NSArray *)views {
    for (UIView *v in views) {
        v.layer.borderColor = [UIColor yellowColor].CGColor;
        v.layer.borderWidth = 1;
    }
}

+ (void)addBorderToViews:(NSArray *)views withColors:(NSUInteger)color {
    for (UIView *v in views) {
        v.layer.borderColor =  UIColorRGBA(color).CGColor;
        v.layer.borderWidth = 1;
    }
}

+ (void)displayAllFonts {
    for (NSString* family in [UIFont familyNames]) {
        NSLog(@"%@", family);
        for (NSString* name in [UIFont fontNamesForFamilyName: family]) {
            NSLog(@"  %@", name);
        }
    }
}


@end

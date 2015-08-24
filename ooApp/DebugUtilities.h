//
//  DebugUtilities.h
//  ooApp
//
//  Created by Anuj Gujar on 8/19/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DebugUtilities : NSObject

+ (void)addBorderToViews:(NSArray *)views;
+ (void)addBorderToViews:(NSArray *)views withColors:(NSUInteger)colors;
+ (void)displayAllFonts;

@end

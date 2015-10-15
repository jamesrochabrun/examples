//
//  OOFilterView.h
//  ooApp
//
//  Created by Anuj Gujar on 10/6/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OOFilterView;

@interface OOFilterView : UIView

- (void)addFilter:(NSString *)name target:(id)target selector:(SEL)selector;
- (void)selectFilter:(NSUInteger)which;
- (void)setCurrent:(NSUInteger)current;

@end

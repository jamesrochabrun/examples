//
//  NavTitleView.h
//  ooApp
//
//  Created by Anuj Gujar on 9/15/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavTitleObject.h"

@interface NavTitleView : UIView

@property (nonatomic, strong) NavTitleObject *navTitle;

- (void)setDDLState:(BOOL)open;
- (CGFloat)width;

@end

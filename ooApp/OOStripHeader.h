//
//  OOStripHeader.h
//  ooApp
//
//  Created by Anuj Gujar on 10/15/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OOStripHeader : UIView

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;

- (void)enableAddButtonWithTarget:(id) target action: (SEL) action;
- (void) unHighlightButton;

@end

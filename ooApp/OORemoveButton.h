//
//  OORemoveButton.h
//  ooApp
//
//  Created by Anuj Gujar on 9/30/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OORemoveButton : UIControl

@property (nonatomic, strong) UILabel *name;
@property (nonatomic) NSUInteger identifier;

- (CGSize)getSuggestedSize;
@end

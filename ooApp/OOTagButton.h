//
//  OOTagButton.h
//  ooApp
//
//  Created by Anuj Gujar on 9/30/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OOTagButton : UIControl

@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSUInteger theId;

- (CGSize)getSuggestedSize;
@end

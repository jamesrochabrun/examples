//
//  OOAIV.h
//  ooApp
//
//  Created by Anuj Gujar on 1/14/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OOAIV : UIView 

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic) BOOL hideWhenStopped;
@property (nonatomic) BOOL isAnimating, endingAnimation;

- (id)initWithFrame:(CGRect)frame simple:(BOOL)simple;
- (void)startAnimating;
- (void)stopAnimating;

@end

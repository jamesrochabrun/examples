//
//  OOFeedbackView.m
//  ooApp
//
//  Created by Anuj Gujar on 4/7/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "OOFeedbackView.h"

@interface OOFeedbackView ()

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *iconLabel;

@end


@implementation OOFeedbackView


- (instancetype)initWithMessage:(NSString *)message andIcon:(NSString *)icon {
    self = [super init];
    if (self) {
        _iconLabel = [UILabel new];
        _iconLabel.text = icon;
        [self addSubview:_iconLabel];
        
        _messageLabel = [UILabel new];
        _messageLabel.text = message;
        [self addSubview:_messageLabel];
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

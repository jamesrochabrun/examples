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


- (instancetype)initWithFrame:(CGRect)frame andMessage:(NSString *)message andIcon:(NSString *)icon {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorRGBOverlay(kColorNavBar, 0.4);
        _iconLabel = [UILabel new];
        _iconLabel.text = icon;
        [_iconLabel withFont:[UIFont fontWithName:kFontIcons size:50] textColor:kColorTextReverse backgroundColor:kColorClear];
        [self addSubview:_iconLabel];
        
        _messageLabel = [UILabel new];
        [_messageLabel withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH3] textColor:kColorTextReverse backgroundColor:kColorClear numberOfLines:2 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        _messageLabel.text = message;
        [self addSubview:_messageLabel];
        
        self.layer.cornerRadius = 10;
        self.alpha = 0;
    }
    return self;
}

- (void)show {
    [UIView animateWithDuration:0.30 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.1 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            ;
        }];
    }];
}

- (void)setMessage:(NSString *)message {
    _message = message;
    _messageLabel.text = _message;
    [self setNeedsLayout];
}

- (void)setIcon:(NSString *)icon {
    _icon = icon;
    _iconLabel.text = _icon;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = width(self);
    CGFloat h = height(self);
    CGRect frame;
    
    [_iconLabel sizeToFit];
    [_messageLabel sizeToFit];
    
    frame = _iconLabel.frame;
    frame.origin = CGPointMake((w-width(_iconLabel))/2, kGeomSpaceEdge);
    _iconLabel.frame = frame;

    frame.size = [_messageLabel sizeThatFits:CGSizeMake(w-2*kGeomSpaceEdge, h)];
    frame.origin = CGPointMake((w-CGRectGetWidth(frame))/2, CGRectGetMaxY(_iconLabel.frame) + ((h-CGRectGetMaxY(_iconLabel.frame)) - CGRectGetHeight(frame))/2);
    _messageLabel.frame = frame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

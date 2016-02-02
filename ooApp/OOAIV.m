//
//  OOAIV.m
//  ooApp
//
//  Created by Anuj Gujar on 1/14/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "OOAIV.h"
#import <QuartzCore/QuartzCore.h>
#import "DebugUtilities.h"

@interface OOAIV ()
@property (nonatomic, strong) UIImageView *ooaiv;
@property (nonatomic, strong) UIView *backView;
@end

@implementation OOAIV

#define kNumberOfKeyframes 60
#define kVBuffer 15

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _backView = [[UIView alloc] initWithFrame:self.frame];
        _backView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);//(kColorLightOverlay50);
        _backView.layer.cornerRadius = kGeomCornerRadius;
        [self addSubview:_backView];
        
        _ooaiv = [[UIImageView alloc] initWithFrame:
                  CGRectIntegral(CGRectMake((frame.size.width - kGeomDimensionsIconButton)/2,
                                            kGeomSpaceEdge,
                                            kGeomDimensionsIconButton,
                                            kGeomDimensionsIconButton))];
        _ooaiv.backgroundColor = [UIColor clearColor];
        
        NSMutableArray *images;
        
        images = [NSMutableArray arrayWithCapacity:kNumberOfKeyframes];
        for (int i = 0; i<kNumberOfKeyframes; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ooLoading%02d.png",i]]];
        }
        
        [_ooaiv setAnimationImages:images];
        [_ooaiv setContentMode:UIViewContentModeScaleAspectFit];
        [_ooaiv setAnimationDuration:3];
        
        _messageLabel = [[UILabel alloc] initWithFrame:
                         CGRectMake(kGeomSpaceEdge, CGRectGetMaxY(_ooaiv.frame) + kGeomSpaceInter, width(self)-2*kGeomSpaceEdge, CGRectGetMaxY(_ooaiv.frame) + kGeomSpaceInter)];
        [_messageLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH5] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        [self addSubview:_ooaiv];
        [self addSubview:_messageLabel];
     
//        [DebugUtilities addBorderToViews:@[_ooaiv, _messageLabel]];
        self.alpha = 0;
        
        _hideWhenStopped = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame simple:(BOOL)simple {
    self = [self initWithFrame:frame];
    
    if (simple) {
        _messageLabel.hidden = YES;
        _backView.hidden = YES;
    }
    return self;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    _messageLabel.text = message;
    [_messageLabel sizeToFit];

    CGRect frame = _messageLabel.frame;
    frame.origin.x = (width(self) - frame.size.width)/2;
    frame.origin.y = (height(self) - (frame.size.height + _ooaiv.frame.size.height + kVBuffer))/2;
    _messageLabel.frame = CGRectIntegral(frame);
    
    frame = _ooaiv.frame;
    frame.origin.y = _messageLabel.frame.origin.y + _messageLabel.frame.size.height + kVBuffer;
    _ooaiv.frame = CGRectIntegral(frame);
    
    _ooaiv.frame = CGRectMake(((width(self) - kGeomDimensionsIconButton))/2,
                              kGeomSpaceEdge,
                              kGeomDimensionsIconButton,
                              kGeomDimensionsIconButton);
    _messageLabel.frame = CGRectMake(kGeomSpaceEdge,
                                     CGRectGetMaxY(_ooaiv.frame),
                                     width(self) - 2*kGeomSpaceEdge,
                                     height(self) - CGRectGetMaxY(_ooaiv.frame));
}

- (void)startAnimating
{
    self.hidden = NO;
    _isAnimating = YES;
    _messageLabel.alpha = 1.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
    }];
    
    [_ooaiv startAnimating];
}

- (void)stopAnimating
{
    if (_hideWhenStopped) {
        [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_ooaiv stopAnimating];
            _isAnimating = NO;
        }];
    } else {
        _messageLabel.alpha = 0.0;
        [_ooaiv stopAnimating];
        _isAnimating = NO;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

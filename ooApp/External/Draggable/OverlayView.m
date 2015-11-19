//
//  OverlayView.m
//  testing swiping
//
//  Created by Richard Kim on 5/22/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#import "OverlayView.h"


@interface OverlayView ()
@property (nonatomic, strong) UILabel *actionHint;
@end

@implementation OverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor purpleColor];
        _actionHint = [[UILabel alloc] init];
        [_actionHint withFont:[UIFont fontWithName:kFontIcons size:kGeomIconSize] textColor:kColorWhite backgroundColor:kColorClear];
        [self addSubview:_actionHint];
        _actionHint.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

-(void)setMode:(GGOverlayViewMode)mode
{
    if (_mode == mode) {
        return;
    }
    
    _mode = mode;
    
    if (mode == GGOverlayViewModeLeft) {
        _actionHint.text = kFontIconRemove;
    } else {
        _actionHint.text = kFontIconToTry;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _actionHint.frame = CGRectMake(50, CGRectGetHeight(self.frame) - 100, 100, 100);
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

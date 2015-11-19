//
//  OverlayView.m
//  testing swiping
//
//  Created by Richard Kim on 5/22/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#import "OverlayView.h"
#import "DebugUtilities.h"

@interface OverlayView ()
@property (nonatomic, strong) UILabel *actionHint;
@end

@implementation OverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorRGBA(kColorClear);
        _actionHint = [[UILabel alloc] init];
        [_actionHint withFont:[UIFont fontWithName:kFontIcons size:kGeomPlayIconSize] textColor:kColorWhite backgroundColor:kColorClear];
        _actionHint.text = kFontIconRemove;
        [_actionHint setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_actionHint];
        CGRect frame = _actionHint.frame;
        frame.size = CGSizeMake(kGeomPlayButtonSize, kGeomPlayButtonSize);
        _actionHint.frame = frame;

        //_actionHint.translatesAutoresizingMaskIntoConstraints = NO;
        //[DebugUtilities addBorderToViews:@[_actionHint]];
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

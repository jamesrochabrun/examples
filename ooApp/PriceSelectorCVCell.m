//
//  PriceSelectorCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 12/10/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "PriceSelectorCVCell.h"
#import "TTRangeSlider.h"

@interface PriceSelectorCVCell ()
@property (nonatomic, strong) TTRangeSlider *priceSlider;
@end

@implementation PriceSelectorCVCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _priceSlider = [[TTRangeSlider alloc] init];
        [self addSubview:_priceSlider];
        _priceSlider.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_priceSlider setTintColor:UIColorRGBA(kColorYellow)];
        _priceSlider.minLabelColour = _priceSlider.maxLabelColour = UIColorRGBA(kColorWhite);
        [_priceSlider setMinValue:0];
        [_priceSlider setMaxValue:4];
        [_priceSlider setEnableStep:YES];
        [_priceSlider setStep:1];
        [_priceSlider setSelectedMaximum:4];
        [_priceSlider setSelectedMinimum:0];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_priceSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_priceSlider attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_priceSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:200]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_priceSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:height(self)]];

}

@end

//
//  PriceSelectorCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 12/10/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "PriceSelectorCVCell.h"
#import "DebugUtilities.h"

@interface PriceSelectorCVCell ()
@property (nonatomic, strong) TTRangeSlider *priceSlider;
@property (nonatomic, strong) UIView *controlsContainer;
@property (nonatomic) NSUInteger minPrice;
@property (nonatomic) NSUInteger maxPrice;
//@property (nonatomic, strong) UIButton *anyPriceButton;
@end

@implementation PriceSelectorCVCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _controlsContainer = [[UIView alloc] init];
        [self addSubview:_controlsContainer];
        _controlsContainer.translatesAutoresizingMaskIntoConstraints = NO;
//        [DebugUtilities addBorderToViews:@[_controlsContainer]];

        _priceSlider = [[TTRangeSlider alloc] init];
        [_controlsContainer addSubview:_priceSlider];
        _priceSlider.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_priceSlider setTintColor:UIColorRGBA(kColorYellow)];
        [_priceSlider setMinValue:0];
        [_priceSlider setMaxValue:3];
        [_priceSlider setSelectedMinimum:0];
        [_priceSlider setSelectedMaximum:3];
        _priceSlider.delegate = self;
    }
    return self;
}

- (void)setMinPrice:(NSUInteger)minPrice maxPrice:(NSUInteger)maxPrice {
    _priceSlider.selectedMinimum = minPrice;
    _priceSlider.selectedMaximum = maxPrice;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonDimensions":@(kGeomDimensionsIconButton)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _priceSlider, _controlsContainer);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_priceSlider(200)]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_controlsContainer(220)]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_priceSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_controlsContainer attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_controlsContainer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_priceSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_controlsContainer attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_controlsContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_controlsContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

- (void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum {

    _minPrice = (unsigned long)selectedMinimum;
    _maxPrice = (unsigned long)selectedMaximum;
    [_delegate priceSelector:self minPriceSelected:_minPrice maxPriceSelected:_maxPrice];
}

@end

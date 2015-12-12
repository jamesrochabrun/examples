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
        [_priceSlider setMaxValue:4];
        [_priceSlider setEnableStep:YES];
        [_priceSlider setStep:1];
        [_priceSlider setSelectedMaximum:4];
        [_priceSlider setSelectedMinimum:0];
        _priceSlider.delegate = self;
        
        _anyPriceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _anyPriceButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_controlsContainer addSubview:_anyPriceButton];
        [_anyPriceButton withText:@"Any Price" fontSize:kGeomFontSizeDetail width:0 height:0 backgroundColor:kColorBlack target:self selector:@selector(anyPricePressed)];
        [_anyPriceButton setTitle:@"Any Price" forState:UIControlStateNormal];
        [_anyPriceButton setTitleColor:UIColorRGBA(kColorWhite) forState:UIControlStateNormal];
        [_anyPriceButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateSelected];
        [_anyPriceButton setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorBlack)] forState:UIControlStateSelected];
        [_anyPriceButton setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)] forState:UIControlStateNormal];
    }
    return self;
}

- (void)anyPricePressed {
    [self setAnyPriceButtonState:!_anyPriceButton.selected];
}

- (void)setAnyPriceButtonState:(BOOL)selected {
    if (!selected) {
        [_anyPriceButton setSelected:NO];
        [_priceSlider setTintColor:UIColorRGBA(kColorYellow)];
        _priceSlider.enabled = YES;
        [_delegate priceSelector:self minPriceSelected:_minPrice maxPriceSelected:_maxPrice];
    } else {
        [_anyPriceButton setSelected:YES];
        [_priceSlider setTintColor:UIColorRGBA(kColorGrayMiddle)];
        _priceSlider.enabled = NO;
        [_delegate priceSelector:self minPriceSelected:0 maxPriceSelected:0];
    }
}

- (void)setMinPrice:(NSUInteger)minPrice maxPrice:(NSUInteger)maxPrice {
    if (!_minPrice && !maxPrice) {
        [self setAnyPriceButtonState:YES];
    } else {
        [self setAnyPriceButtonState:NO];
        _priceSlider.selectedMinimum = minPrice;
        _priceSlider.selectedMaximum = maxPrice;
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonDimensions":@(kGeomDimensionsIconButton)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _anyPriceButton, _priceSlider, _controlsContainer);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_controlsContainer]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_anyPriceButton(30)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_anyPriceButton(70)]-[_priceSlider(200)]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_controlsContainer(300)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_anyPriceButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_controlsContainer attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_anyPriceButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_priceSlider attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_priceSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:height(self)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_controlsContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_controlsContainer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum {

    _minPrice = (unsigned long)selectedMinimum ;
    _maxPrice = (unsigned long)selectedMaximum ;
    [_delegate priceSelector:self minPriceSelected:_minPrice maxPriceSelected:_maxPrice];
}

@end

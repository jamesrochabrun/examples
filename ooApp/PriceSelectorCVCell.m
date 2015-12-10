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

- (instancetype)init {
    self = [super init];
    if (self) {
        _priceSlider = [[TTRangeSlider alloc] init];
        [self addSubview:_priceSlider];
    }
    return self;
}

@end

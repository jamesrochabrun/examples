//
//  PriceSelectorCVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 12/10/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRangeSlider.h"

@class PriceSelectorCVCell;

@protocol PriceSelectorCellDelegate
- (void)priceSelector:(PriceSelectorCVCell *)priceSelector minPriceSelected:(NSUInteger)minPrice maxPriceSelected:(NSUInteger)maxPrice;
@end

@interface PriceSelectorCVCell : UICollectionViewCell <TTRangeSliderDelegate>
@property (nonatomic, weak) id<PriceSelectorCellDelegate> delegate;


- (void)setMinPrice:(NSUInteger)minPrice maxPrice:(NSUInteger)maxPrice;

@end

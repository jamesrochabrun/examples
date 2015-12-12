//
//  OptionsVC.h
//  ooApp
//
//  Created by Anuj Gujar on 11/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "OptionsVCCVL.h"
#import "PriceSelectorCVCell.h"

@class OptionsVC;

@protocol OptionsVCDelegate

- (void)optionsVCDismiss:(OptionsVC *)optionsVC withTags:(NSMutableSet *)tags andMinPrice:(NSUInteger)minPrice andMaxPrice:(NSUInteger)maxPrice;

@end

@interface OptionsVC : BaseVC <UICollectionViewDataSource, UICollectionViewDelegate, OptionsVCCollectionViewDelegate, PriceSelectorCellDelegate>

@property (nonatomic, weak) id<OptionsVCDelegate> delegate;
@property (nonatomic, strong) NSMutableSet *userTags;

- (void)setMinPrice:(NSUInteger)minPrice maxPrice:(NSUInteger)maxPrice;

@end

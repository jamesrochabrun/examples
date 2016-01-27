//
//  FoodFeedVCCVL.h
//  ooApp
//
//  Created by Anuj Gujar on 10/12/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kFoodFeedSectionTypeMediaItems,
    kSectionTypeNumberOfSections
} kSectionType;

@class FoodFeedVCCVL;

@protocol FoodFeedVCCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(FoodFeedVCCVL *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)collectionView:(UICollectionView *)collectionView
                   layout:(FoodFeedVCCVL *)collectionViewLayout
 numberOfColumnsInSection:(NSUInteger)section ;

@end

static NSUInteger kFoodFeedNumColumnsForMediaItems = 2;

@interface FoodFeedVCCVL : UICollectionViewLayout

@property (nonatomic, weak) id<FoodFeedVCCollectionViewDelegate> delegate;

@end

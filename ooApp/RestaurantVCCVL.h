//
//  RestaurantVCCVL.h
//  ooApp
//
//  Created by Anuj Gujar on 10/12/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSectionTypeMain,
    kSectionTypeLists,
    kSectionTypeMediaItems,
    kSectionTypeNumberOfSections
} kSectionType;

@class RestaurantVCCVL;

@protocol RestaurantVCCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(RestaurantVCCVL *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

//@optional
//
//- (CGFloat) collectionView:(UICollectionView *)collectionView
//                    layout:(RestaurantVCCVL *)collectionViewLayout
//heightForHeaderAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface RestaurantVCCVL : UICollectionViewLayout

@property (nonatomic, weak) id<RestaurantVCCollectionViewDelegate> delegate;

@end

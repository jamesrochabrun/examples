//
//  RestaurantVCCVL.h
//  ooApp
//
//  Created by Anuj Gujar on 10/12/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kRestaurantSectionTypeMain,
    kRestaurantSectionTypeFollowees,
    kRestaurantSectionTypeLists,
    kRestaurantSectionTypeMediaItems,
    kRestaurantSectionTypeNumberOfSections
} kRestaurantSectionType;

@class RestaurantVCCVL;

@protocol RestaurantVCCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(RestaurantVCCVL *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

static NSUInteger kRestaurantNumColumnsForMediaItems = 2;

@interface RestaurantVCCVL : UICollectionViewLayout

@property (nonatomic, weak) id<RestaurantVCCollectionViewDelegate> delegate;

@end

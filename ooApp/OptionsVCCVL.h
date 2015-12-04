//
//  OptionsVCCVL.h
//  ooApp
//
//  Created by Anuj Gujar on 12/3/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OptionsVCCVL;

typedef enum {
    kOptionsSectionTypeLocation,
    kOptionsSectionTypePrice,
    kOptionsSectionTypeTags,
    kOptionsSectionTypeNumberOfSections
} kOptionsSectionType;

static NSUInteger kNumColumnsForTags = 4;

@protocol OptionsVCCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(OptionsVCCVL *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface OptionsVCCVL : UICollectionViewLayout

@property (nonatomic, weak) id<OptionsVCCollectionViewDelegate> delegate;

@end

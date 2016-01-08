//
//  ProfileVCCVLayout.h
//  ooApp
//
//  Created by Anuj Gujar on 10/12/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileVCCVLayout;

// NOTE: ∃ only one section that is always used for displaying lists and photos.

@protocol ProfileVCCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(ProfileVCCVLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ProfileVCCVLayout : UICollectionViewLayout

@property (nonatomic, weak) id<ProfileVCCollectionViewDelegate> delegate;
- (void) setShowingLists: (BOOL) showing;
@end

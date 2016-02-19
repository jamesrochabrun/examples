//
//  ProfileVCCVLayout.h
//  ooApp
//
//  Created by Anuj Gujar on 10/12/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileVCCVLayout;

@protocol ProfileVCCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(ProfileVCCVLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(ProfileVCCVLayout *)collectionViewLayout
          heightForheader:(NSUInteger)section;
@end

@interface ProfileVCCVLayout : UICollectionViewLayout
@property (nonatomic, assign) BOOL userIsSelf;
//@property (nonatomic, assign) BOOL userIsFoodie;
//@property (nonatomic, assign) BOOL foodieHasURL, userHasSpecialties;
@property (nonatomic, assign) BOOL thereAreNoItems;
@property (nonatomic, weak) id<ProfileVCCollectionViewDelegate> delegate;
- (void) setShowingLists:(BOOL)showing;
@end

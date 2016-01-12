//
//  ProfileVC.h
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "BaseVC.h"
#import "UserObject.h"
#import "OOTextEntryVC.h"
#import "ProfileVCCVLayout.h"
#import "MWPhotoBrowser.h"
#import "PhotoCVCell.h"

@protocol ProfileHeaderViewDelegate
- (void) userTappedOnLists;
- (void) userTappedOnPhotos;
@end

@interface ProfileVC : BaseVC <UICollectionViewDataSource, UICollectionViewDelegate,ProfileVCCollectionViewDelegate, MWPhotoBrowserDelegate,
                                ProfileHeaderViewDelegate, UIImagePickerControllerDelegate,  UINavigationControllerDelegate, PhotoCVCellDelegate,
                                OOTextEntryVCDelegate
>
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UserObject *userInfo;

- (void)goToEmptyListScreen:(NSString *)string;
@end

@interface ProfileHeaderView : UICollectionReusableView  <OOTextEntryVCDelegate>
- (void)setUserInfo:(UserObject*)userInfo;
@property (nonatomic,weak) ProfileVC* vc;
@property (nonatomic,weak) NSObject<ProfileHeaderViewDelegate>* delegate;
@end

@interface ProfileCVPhotoCell : UICollectionViewCell
- (void)setMediaObject:(MediaItemObject *)mediaObject;
@end

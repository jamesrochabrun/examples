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
#import "OOTextEntryModalVC.h"
#import "ProfileVCCVLayout.h"
#import "PhotoCVCell.h"
#import "RestaurantPickerVC.h"
#import "ViewPhotoVC.h"
#import "AddCaptionToMIOVC.h"
#import "UnverifiedUserVC.h"
#import "ConfirmPhotoVC.h"

@protocol ProfileEmptyCellDelegate
- (void) userPressedEmptyCell;
@end

@protocol ProfileHeaderViewDelegate
- (void)userTappedOnLists;
- (void)userTappedOnPhotos;
- (void)userPressedSettings:(id)sender;
@end

@interface ProfileVC : BaseVC <UICollectionViewDataSource,
                                UICollectionViewDelegate,
                                ProfileVCCollectionViewDelegate,
                                ProfileHeaderViewDelegate,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate,
                                PhotoCVCellDelegate,
                                OOTextEntryModalVCDelegate,
                                RestaurantPickerVCDelegate,
                                ProfileEmptyCellDelegate,
                                ViewPhotoVCDelegate,
                                UIViewControllerTransitioningDelegate,
                                OOTextEntryVCDelegate,
                                UnverifiedUserVCDelegate,
                                UISearchBarDelegate,
                                UITableViewDelegate,
                                UITableViewDataSource,
                                ConfirmPhotoVCDelegate>
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UserObject *userInfo;

@end

@interface ProfileHeaderView : UICollectionReusableView  <OOTextEntryModalVCDelegate, OOUserViewDelegate, UnverifiedUserVCDelegate>
- (void)setUserInfo:(UserObject*)userInfo;
@property (nonatomic,weak) ProfileVC* vc;
- (void)refreshUserImage;
- (void)enableURLButton;
- (void)updateSpecialtiesLabel;
@property (nonatomic,weak) NSObject<ProfileHeaderViewDelegate>* delegate;
@end

@interface ProfileEmptyCell: UICollectionViewCell
@property (nonatomic,weak) NSObject<ProfileEmptyCellDelegate>* delegate;
- (void)setListMode;
- (void)setMessageMode;
- (void)setPhotoMode;
- (void)setMessage:(NSString *)message;

@end


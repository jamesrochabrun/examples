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

@protocol ProfileTableFirstRowDelegate
- (void) userTappedOnLists;
- (void) userTappedOnPhotos;
@end

@interface ProfileVC : BaseVC <UITableViewDataSource, UITableViewDelegate, ProfileTableFirstRowDelegate>
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UserObject *userInfo;

- (void)goToEmptyListScreen:(NSString *)string;
@end

@interface ProfileTableFirstRow : UITableViewCell 
- (void)setUserInfo:(UserObject*)userInfo;
@property (nonatomic,weak) ProfileVC* vc;
@property (nonatomic,weak) id<ProfileTableFirstRowDelegate> delegate;
@end

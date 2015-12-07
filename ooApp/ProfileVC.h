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

@interface ProfileVC : BaseVC <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UserObject *userInfo;

- (void)goToEmptyListScreen:(NSString *)string;
@end

@interface ProfileTableFirstRow : UITableViewCell <UIAlertViewDelegate>
- (void)setUserInfo:(UserObject*)userInfo;
@end

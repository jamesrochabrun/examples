//
//  ProfileVC.h
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SubBaseVC.h"
#import "UserObject.h"

@interface ProfileVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,assign) NSInteger  userID;
@property (nonatomic,strong) UserObject* userInfo;

- (void) goToEmptyListScreen:(NSString*)string;

@end

@interface ProfileTableFirstRow : UITableViewCell <UIAlertViewDelegate>

@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UIButton *buttonFollow;
@property (nonatomic, strong) UIButton *buttonNewList;
@property (nonatomic, strong) UILabel *labelUsername;
@property (nonatomic, strong) UILabel *labelDescription;
@property (nonatomic, strong) UILabel *labelRestaurants;
@property (nonatomic, strong) UIButton *buttonNewListIcon;
@property (nonatomic, assign) float spaceNeededForFirstCell;
@property (nonatomic, assign) UINavigationController *navigationController;
@end

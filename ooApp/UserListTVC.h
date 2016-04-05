//
//  UserListTVC.h
//  ooApp
//
//  Created by Anuj Gujar on 2/9/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OOUserView.h"
#import "UnverifiedUserVC.h"


@protocol UserListTVCDelegate <NSObject>
- (void)userTappedImageOfUser:(UserObject *)user;
- (void)userTappedFollowButtonForUser:(UserObject *)user following:(BOOL)following;
@end

@interface UserListTVC : UITableViewCell <OOUserViewDelegate, UnverifiedUserVCDelegate>
- (void)provideUser:(UserObject *)user;
- (void)fetchStats;
- (void)showFollowButton:(BOOL)following;
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, weak) id<UserListTVCDelegate>delegate;
@property (nonatomic, strong) UIButton *buttonFollow;
@end

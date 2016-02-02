//
//  UserListVC.h
//  ooApp
//
//  Created by Zack Smith on 12/7/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "EventObject.h"
#import "UserTVCell.h"
#import "OOUserView.h"
#import "UserObject.h"

@protocol UserListTableSectionHeaderDelegate
- (void) userTappedSectionHeader:(int)which;
@end

@interface UserListTableSectionHeader : UIView
@property (nonatomic,weak) id<UserListTableSectionHeaderDelegate> delegate;
@property (nonatomic,strong) UILabel *labelTitle;
@property (nonatomic,assign) BOOL isExpanded;
@end

@protocol UserListTableCellDelegate
- (void) userTappedImageOfUser:(UserObject*)user;
- (void) userTappedFollowButtonForUser:(UserObject*)user;
@end

@interface UserListTableCell : UITableViewCell <OOUserViewDelegate>
- (void) provideUser: (UserObject*) user;
- (void)commenceFetchingStats;
- (void) showFollowButton: (BOOL)following;

@property (nonatomic,weak) id<UserListTableCellDelegate>delegate;
@end

@interface UserListVC : BaseVC <UserListTableSectionHeaderDelegate,UserListTableCellDelegate>
@property (nonatomic, strong) NSMutableArray *usersArray;
@property (nonatomic, strong) NSString* desiredTitle;
@property (nonatomic,strong) UserObject* user;
@end

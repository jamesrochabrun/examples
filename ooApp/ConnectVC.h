//
//  ConnectVC.h
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

enum : int {
    kConnectSectionFriends = 0,
    kConnectSectionFoodies = 1,
//    kConnectSectionFollowers = 2,
//    kConnectSectionFollowees = 3,
};

@protocol ConnectTableSectionHeaderDelegate
- (void) userTappedSectionHeader:(int)which;
@end

@interface ConnectTableSectionHeader : UIView
@property (nonatomic,weak) id<ConnectTableSectionHeaderDelegate> delegate;
@property (nonatomic,strong) UILabel *labelTitle;
@property (nonatomic,assign) BOOL isExpanded;
@end

@protocol ConnectTableCellDelegate
- (void) userTappedImageOfUser:(UserObject*)user;
- (void) userTappedFollowButtonForUser:(UserObject*)user;
@end

@interface ConnectTableCell : UITableViewCell <OOUserViewDelegate>
- (void)provideUser:(UserObject *)user;
- (void)commenceFetchingStats;
- (void)showFollowButton:(BOOL)following;
@property (nonatomic,weak) id<ConnectTableCellDelegate>delegate;
@end

@interface ConnectVC : BaseVC <ConnectTableSectionHeaderDelegate,ConnectTableCellDelegate>
@property (nonatomic,assign) NSInteger defaultSection;
@end







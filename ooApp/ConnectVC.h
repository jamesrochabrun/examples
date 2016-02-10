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
#import "UserListTVC.h"

enum : int {
    kConnectSectionFriends = 0,
    kConnectSectionFoodies = 1,
};

@protocol ConnectTableSectionHeaderDelegate
- (void) userTappedSectionHeader:(int)which;
@end

@interface ConnectTableSectionHeader : UIView
@property (nonatomic, weak) id<ConnectTableSectionHeaderDelegate> delegate;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, assign) BOOL isExpanded;
@end

@interface ConnectVC : BaseVC <ConnectTableSectionHeaderDelegate, UserListTVCDelegate>
@property (nonatomic, assign) NSInteger defaultSection;
@end







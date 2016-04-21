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

typedef enum {
    kConnectSectionFriends = 0,
    kConnectSectionFoodies = 1,
    kConnectSectionInTheKnow = 2,
    kConnectSectionRecentUsers = 3,
} kConnectSection;

@protocol ConnectTableSectionHeaderDelegate
- (void) userTappedSectionHeader:(int)which;
@end

@interface ConnectTableSectionHeader : UIView
@property (nonatomic, weak) id<ConnectTableSectionHeaderDelegate> delegate;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) NSString *noUsersMessage;
@property (nonatomic, assign) BOOL isExpanded;
@end

@interface ConnectVC : BaseVC <ConnectTableSectionHeaderDelegate,
                                UserListTVCDelegate,
                                UISearchBarDelegate>
@property (nonatomic, assign) NSInteger defaultSection;
@end







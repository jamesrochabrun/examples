//
//  CommentListTVCell.h
//  ooApp
//
//  Created by James Rochabrun on 20-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OOUserView.h"
#import "UnverifiedUserVC.h"


@protocol CommentListTVCDelegate <NSObject>
- (void)userTappedImageOfUser:(UserObject *)user;
- (void)userTappedFollowButtonForUser:(UserObject *)user following:(BOOL)following;
@end


@interface CommentListTVCell : UITableViewCell <OOUserViewDelegate, UnverifiedUserVCDelegate>
- (void)provideUser:(UserObject *)user;
- (void)fetchStats;
- (void)showFollowButton:(BOOL)following;
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, weak) id<CommentListTVCDelegate>delegate;
@property (nonatomic, strong) UIButton *buttonFollow;


@end

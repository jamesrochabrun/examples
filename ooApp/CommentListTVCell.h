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
@class CommentObject;


@protocol CommentListTVCDelegate <NSObject>
- (void)userTappedImageOfUser:(UserObject *)user;
@end


@interface CommentListTVCell : UITableViewCell <OOUserViewDelegate, UnverifiedUserVCDelegate>

- (void)provideUser:(UserObject *)user;
+ (CGFloat)heightForComment:(CommentObject *)comment;
@property (nonatomic, strong) CommentObject *comment;
@property (nonatomic, strong) UserObject *user;
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, weak) id<CommentListTVCDelegate>delegate;


@end

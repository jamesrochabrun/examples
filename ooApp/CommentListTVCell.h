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

+ (CGFloat)heightForComment:(CommentObject *)comment;
@property (nonatomic, strong) CommentObject *comment;
@property (nonatomic, strong) UserObject *user;
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, weak) id <CommentListTVCDelegate> delegate;
//make this properties public if we want to add the logic of the height of the cell in the commentListVC
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *labelName;




@end

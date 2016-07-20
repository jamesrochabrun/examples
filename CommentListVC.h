//
//  CommentListVC.h
//  
//
//  Created by James Rochabrun on 20-07-16.
//
//

#import "SubBaseVC.h"
#import "BaseVC.h"
#import "EventObject.h"
#import "UserTVCell.h"
#import "OOUserView.h"
#import "UserObject.h"
#import "UserListTVC.h"

@protocol ComentListTableSectionHeaderDelegate
- (void) userTappedSectionHeader:(int)which;
@end

@interface CommentListTableSectionHeader : UIView
@property (nonatomic,weak) id<ComentListTableSectionHeaderDelegate> delegate;
@property (nonatomic,strong) UILabel *labelTitle;
@property (nonatomic,assign) BOOL isExpanded;
@end

@interface CommentListVC : SubBaseVC  <ComentListTableSectionHeaderDelegate, UserListTVCDelegate>
@property (nonatomic, strong) NSMutableArray *usersArray;
@property (nonatomic, strong) NSString* desiredTitle;
@property (nonatomic, strong) UserObject* user;

@end

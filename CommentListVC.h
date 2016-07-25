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
#import "CommentListTVCell.h"


@protocol ComentListTableSectionHeaderDelegate
- (void) userTappedSectionHeader:(int)which;
@end

//SubBase is a subclass of UIViewController
@interface CommentListVC : SubBaseVC  <ComentListTableSectionHeaderDelegate, CommentListTVCDelegate, UITextViewDelegate>
@property (nonatomic, strong) NSMutableArray *usersArray;
@property (nonatomic, strong) NSMutableArray *commentsArray;
@property (nonatomic, strong) NSString* desiredTitle;
@property (nonatomic, strong) UserObject* user;
@property (nonatomic, strong) MediaItemObject *mio;


@end

@interface CommentListTableSectionHeader : UIView
@property (nonatomic,weak) id<ComentListTableSectionHeaderDelegate> delegate;
@property (nonatomic,strong) UILabel *labelTitle;
@property (nonatomic,assign) BOOL isExpanded;
@end



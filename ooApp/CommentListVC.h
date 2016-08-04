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



//SubBase is a subclass of UIViewController
@interface CommentListVC : SubBaseVC  <CommentListTVCDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *commentsArray;
@property (nonatomic, strong) NSString *desiredTitle;
@property (nonatomic, strong) UserObject *user;
@property (nonatomic, strong) MediaItemObject *mio;
@property (nonatomic, strong) NSMutableArray *usersArray;
@property (nonatomic, strong) NavTitleObject *nto;


@end





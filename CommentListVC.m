//
//  CommentListVC.m
//  
//
//  Created by James Rochabrun on 20-07-16.
//
//

#import "CommentListVC.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "Common.h"
#import "AppDelegate.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "ListObject.h"
#import "Settings.h"
#import "ProfileVC.h"
#import "TextFieldView.h"
#import "CommentObject.h"


#define COMMENT_LIST_TABLE_REUSE_IDENTIFIER  @"commentListTVC"
#define COMMENT_LIST_TABLE_REUSE_IDENTIFIER_EMPTY  @"commentListTableCellEmpty"

//==============================================================================
@interface CommentListVC ()<UITextFieldDelegate>
@property (nonatomic,strong) UITableView *tableUsers;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic, strong) TextFieldView *textFieldView;
@property CGFloat keyBoardHeight;
@property (nonatomic, strong) NSMutableArray *dummyCommentsArray;

@end

@implementation CommentListVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _needRefresh = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);

    NavTitleObject *nto;
    nto = [[NavTitleObject alloc]
           initWithHeader: _desiredTitle ?: LOCAL(@"Users")
           subHeader: nil];
    
    self.navTitle = nto;
    
    //here is what creates a new instance of a tableView
    self.tableUsers = makeTable(self.view,self);
    _tableUsers.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_tableUsers registerClass:[CommentListTVCell class] forCellReuseIdentifier:COMMENT_LIST_TABLE_REUSE_IDENTIFIER];
    [_tableUsers registerClass:[UITableViewCell class] forCellReuseIdentifier:COMMENT_LIST_TABLE_REUSE_IDENTIFIER_EMPTY];
    [_tableUsers setLayoutMargins:UIEdgeInsetsZero];
    _tableUsers.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableUsers.separatorColor= UIColorRGBA(kColorBordersAndLines);
    _tableUsers.separatorInset = UIEdgeInsetsZero;
    _tableUsers.showsVerticalScrollIndicator= NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNeedsRefresh)
                                                 name:kNotificationUserFollowingChanged object:nil];
    
    [self removeNavButtonForSide:kNavBarSideTypeRight];
    [self addNavButtonWithIcon:@"" target:nil action:nil forSide:kNavBarSideTypeRight isCTA:NO];
    
    [self removeNavButtonForSide:kNavBarSideTypeLeft];
    [self addNavButtonWithIcon:kFontIconBack target:self action:@selector(done:) forSide:kNavBarSideTypeLeft isCTA:NO];
    
    //creating the instance of the subclass of UIView that contains the textfield that takes the input(user comment);
    _textFieldView = [TextFieldView new];
    [_textFieldView.postTextButton addTarget:self action:@selector(postComment:) forControlEvents:UIControlEventTouchUpInside];
    _textFieldView.textField.delegate = self;
    [self.view addSubview:_textFieldView];

    
    [self initializingDummyComments];
}

//------------------------------------------------------------------------------
// Name:    textFieldDelegate Methods
// Purpose:
//------------------------------------------------------------------------------

- (void)postComment:(UIButton*)sender {
    [self dismissKeyboard:sender];
    _textFieldView.textField.text = @"";
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CommentObject *comment = [CommentObject new];
    comment.content = textField.text;
    NSLog(@"this is the content on begin editing %@", comment.content);
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    CommentObject *comment = [CommentObject new];
    comment.content = textField.text;
    NSLog(@"this is the content on end editing %@", comment.content);
    //[self.tableUsers setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [_dummyCommentsArray addObject:comment];
    
    [OOAPI uploadComment:comment success:^{
        NSLog(@"success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error from the commentlistVC : %@", error);
    }];
    
}

- (void) dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
    [_textFieldView.textField resignFirstResponder];
}


- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat deltaHeight = kbSize.height - _keyBoardHeight;
    // Write code to adjust views accordingly using deltaHeight
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - deltaHeight, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    
    _keyBoardHeight = kbSize.height;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + _keyBoardHeight, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    _keyBoardHeight = 0.0f;
}


//----------------------------------------------------------------------

- (void)setNeedsRefresh {
    _needRefresh = YES;
}

- (void)setUsersArray:(NSMutableArray *)usersArray {
    if (_usersArray == usersArray) return;
    _usersArray = usersArray;
    [_tableUsers reloadData];
    [self refreshIfNeeded];
}

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self doLayout];
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN(@(object_getClassName(self)));

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)refreshIfNeeded {
    if (_needRefresh) {
        _needRefresh = NO;
    }
}

//------------------------------------------------------------------------------
// Name:    viewWillDisappear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//------------------------------------------------------------------------------
// Name:    viewDidAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout {
    
    _textFieldView.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds) - 50, self.view.bounds.size.width, 50);
    _textFieldView.backgroundColor = [UIColor grayColor];
    CGRect frame = _tableUsers.frame;
    frame.origin.x = self.view.bounds.origin.x;
    frame.origin.y = self.view.bounds.origin.y;
    frame.size.height = self.view.bounds.size.height - _textFieldView.frame.size.height;
    frame.size.width = self.view.bounds.size.width;
    _tableUsers.frame = frame;
    
}

#pragma TableView methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    UserObject *u = nil;
    
    @synchronized(self.usersArray)  {
        if (row < _usersArray.count) {
            u = _usersArray[row];
        }
    }
    NSLog(@"the count of users is %lu" , self.usersArray.count);

    if (!u) {
        UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_LIST_TABLE_REUSE_IDENTIFIER_EMPTY forIndexPath:indexPath];
        cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.text =  @"Alas there are none.";
        cell.textLabel.textColor = UIColorRGBA(kColorWhite);
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    CommentListTVCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_LIST_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.delegate = self;
    cell.vc = self;
    [cell provideUser:u];
    
    
    CommentObject *comment = [_dummyCommentsArray objectAtIndex:indexPath.row];
    [cell provideComment:comment];

    [cell fetchStats];
    
    return cell;
}

//------------------------------------------------------------------------------
// Name:    editingStyleForRowAtIndexPath
// Purpose: Delete cells
//------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *updateButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:kFontIconCirclePlus handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                    //update comment?
                                    }];
    updateButton.backgroundColor = UIColorRGBA(kColorGrayMiddle);
    UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                   //delete comment
                                     }];
    deleteButton.backgroundColor =  UIColorRGBA(kColorTextActive);  //arbitrary color
    
    return @[updateButton, deleteButton];
}



//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return kGeomHeightHorizontalListRow;
    CommentObject *comment = [_dummyCommentsArray objectAtIndex:indexPath.row];
    return [CommentListTVCell heightForComment:comment];
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    UserObject *u = nil;
    
    @synchronized(self.usersArray)  {
        if (row < _usersArray.count) {
            u = _usersArray[row];
        }
    }
    
    if (u) {
        [self goToProfile:u];
    }
}

- (void)goToProfile: (UserObject*)u {
    ProfileVC *vc= [[ProfileVC alloc] init];
    vc.userInfo = u;
    vc.userID = u.userID;
    [self.navigationController  pushViewController:vc animated:YES];
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    @synchronized(self.usersArray)  {
//        return _usersArray.count;
//    }
    
    @synchronized(self.dummyCommentsArray)  {
        return _dummyCommentsArray.count;
    }
}

- (void)userTappedSectionHeader:(int)which {
}


- (void) userTappedImageOfUser:(UserObject*)user; {
    [self goToProfile:user];
}


#pragma dummy data
- (void)initializingDummyComments {
    
    
    NSDictionary *dummyComments = @{kKeyCommentContent : @"comment # 1 Debbie Wasserman Schultz announced Sunday she will soon step down as Democratic National Committee chairwoman, amid the fallout over leaked emails indicating an anti-Bernie Sanders bias in her operation -- a stunning development just in .",
                                    kKeyCommentMediaItemID : @"carlos",
                                    kKeyCommentMediaItemCommentID : @"mediaItemId",
                                    kKeyCommentUserID : @"user Id1"
                                    };
    
    NSDictionary *dummyComments1 = @{kKeyCommentContent : @"comment # 2 Debbie Wasserman Schultz announced Sunday she will soon step down as Democratic National Committee chairwoman, amid the fallout over leaked emails indicating an anti-Bernie Sanders bias in her operation -- a stunning development just in .",
                                     kKeyCommentMediaItemID : @"foodiealloli",
                                     kKeyCommentMediaItemCommentID : @"mediaItemId",
                                     kKeyCommentUserID : @"user Id2"
                                     };
    NSDictionary *dummyComments2 = @{kKeyCommentContent : @"comment # 3 ... file inspector; Under Interface Builder Document uncheck",
                                     kKeyCommentMediaItemID : @"waltrerosenkranz",
                                     kKeyCommentMediaItemCommentID : @"mediaItemId",
                                     kKeyCommentUserID : @"user Id3"
                                     };
    NSDictionary *dummyComments3 = @{kKeyCommentContent : @"comment # 4 ilder Document uncheck kjhjkh kjhfjkh kjshjkhjkh kjhkjh ;kjhfkjhhjkh khyh khfphdf 1234567890 1234567890",
                                     kKeyCommentMediaItemID : @"waltrerosenkranz",
                                     kKeyCommentMediaItemID : @"rociocarrasco",
                                     kKeyCommentMediaItemCommentID : @"mediaItemId",
                                     kKeyCommentUserID : @"user Id4"
                                     };
    NSDictionary *dummyComments4 = @{kKeyCommentContent : @"comment # 5",
                                     kKeyCommentMediaItemID : @"ellazomatina",
                                     kKeyCommentMediaItemCommentID : @"mediaItemId",
                                     kKeyCommentUserID : @"user Id5"
                                     };
    
    NSArray *arrayOfDummyCommentDicts = @[dummyComments, dummyComments1, dummyComments2, dummyComments3, dummyComments4];
    _dummyCommentsArray = [NSMutableArray new];
    
    for (NSDictionary *dummyCommentDict in arrayOfDummyCommentDicts) {
        CommentObject *comment = [CommentObject commentFromDict:dummyCommentDict];
        [_dummyCommentsArray addObject:comment];
    }
    
}



@end

//==============================================================================

@interface CommentListTableSectionHeader ()
@property (nonatomic,strong) UILabel *labelExpander;
@end

@implementation CommentListTableSectionHeader

- (instancetype)initWithExpandedFlag:(BOOL)expanded {
    self = [super init];
    if (self) {
        _labelTitle = makeLabelLeft (self, nil, kGeomFontSizeH3);
        _labelTitle.textColor = UIColorRGBA(kColorWhite);
        _labelExpander = makeIconLabel(self, kFontIconBack, kGeomIconSize);
        _labelExpander.textColor = UIColorRGBA(kColorTextActive);
        self.backgroundColor = UIColorRGBA(kColorOffWhite);
        _isExpanded = expanded;
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat w = width(self);
    CGFloat h = height(self);
    const float kGeomUserListVCHeaderLeftMargin = 29;
    const float kGeomUserListVCHeaderRightMargin = 24;
    self.labelTitle.frame = CGRectMake(kGeomUserListVCHeaderLeftMargin, 0, w/2, h);
    [self.labelExpander sizeToFit];
    CGFloat labelWidth = h;
    self.labelExpander.frame = CGRectMake(w-kGeomUserListVCHeaderRightMargin-labelWidth, 0, labelWidth, h);
    double angle = _isExpanded ? 3*M_PI/2 : M_PI/2;
    _labelExpander.layer.transform=CATransform3DMakeRotation(angle, 0, 0, 1);
}











@end




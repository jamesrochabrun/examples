//
//  CommentListVC.m
//
//
//  Created by James Rochabrun on 20-07-16.
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

//==============================================================================
@interface CommentListVC () 
@property (nonatomic,strong) UITableView *tableUsers;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic, strong) TextFieldView *textFieldView;
@property CGFloat keyBoardHeight;
@property CGFloat h;

@end

@implementation CommentListVC

NSString *const kCommentsTableReuseIdentifier = @"commentListTVC";
NSString *const kCommentsTableReuseIdentifierEmpty = @"commentListTableCellEmpty";

//- (void)dealloc {
//    [_commentsArray removeAllObjects];
//    _commentsArray = nil;
//}

//----------------------------------------------------------------------
//
//- (void)setNeedsRefresh {
//    _needRefresh = YES;
//}
- (void)setCommentsArray:(NSMutableArray *)commentsArray {
    
    if (_commentsArray == commentsArray) return;
    _commentsArray = commentsArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableUsers reloadData];
    });
}

//- (void)refreshIfNeeded {
//    if (_needRefresh) {
//        _needRefresh = NO;
//    }
//}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    //_needRefresh = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorGrayMiddle);
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    NavTitleObject *nto;
    nto = [[NavTitleObject alloc]
           initWithHeader: _desiredTitle ?: LOCAL(@"Users")
           subHeader: nil];
    
    self.navTitle = nto;
    
    //here is what creates a new instance of a tableView
    self.tableUsers = makeTable(self.view,self);
    _tableUsers.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_tableUsers registerClass:[CommentListTVCell class] forCellReuseIdentifier:kCommentsTableReuseIdentifier];
    [_tableUsers registerClass:[UITableViewCell class] forCellReuseIdentifier:kCommentsTableReuseIdentifierEmpty];
    [_tableUsers setLayoutMargins:UIEdgeInsetsZero];
    _tableUsers.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableUsers.separatorColor= UIColorRGBA(kColorBordersAndLines);
    _tableUsers.separatorInset = UIEdgeInsetsZero;
    _tableUsers.showsVerticalScrollIndicator= NO;
 
    [self removeNavButtonForSide:kNavBarSideTypeRight];
    [self addNavButtonWithIcon:@"" target:nil action:nil forSide:kNavBarSideTypeRight isCTA:NO];
    
    [self removeNavButtonForSide:kNavBarSideTypeLeft];
    [self addNavButtonWithIcon:kFontIconBack target:self action:@selector(done:) forSide:kNavBarSideTypeLeft isCTA:NO];
    
    _textFieldView = [TextFieldView new];
    _textFieldView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_textFieldView.postTextButton addTarget:self action:@selector(postComment:) forControlEvents:UIControlEventTouchUpInside];
    [_textFieldView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _textFieldView.textField.delegate = self;
    [self.view addSubview:_textFieldView];
    _textFieldView.textField.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3];
    _textFieldView.postTextButton.userInteractionEnabled = NO;
    _textFieldView.postTextButton.alpha = 0.7f;
    _user = [Settings sharedInstance].userObject;
    _textFieldView.textField.placeholder = [NSString stringWithFormat:@"  add a comment as %@", _user.username];
}

//------------------------------------------------------------------------------
// Name:    textFieldDelegate Methods
// Purpose:
//------------------------------------------------------------------------------
- (void)textFieldDidChange:(UITextField *)textField {
    
    NSString *rawString = [textField text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    
    if ([trimmed length] == 0) {
        _textFieldView.postTextButton.userInteractionEnabled = NO;
        _textFieldView.postTextButton.alpha = 0.7f;
    } else {
        _textFieldView.postTextButton.userInteractionEnabled = YES;
        _textFieldView.postTextButton.alpha = 1.0f;
    }
    if (textField.text.length >= kGeomMaxCommentLimit) {
    }
}

- (void)postComment:(UIButton *)sender {
    
    CommentObject *comment = [CommentObject new];
    comment.content = _textFieldView.textField.text;
    
    [OOAPI uploadComment:comment forObject:_mio success:^(CommentObject *comment) {
        if (comment) {
            __weak CommentListVC *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.commentsArray addObject:comment];
                [weakSelf.tableUsers reloadData];
                [weakSelf tableviewScrollToTheBottom:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationViewPhotoVCNeedsUpdate
                                                                    object:self];
            });
        } else {
            NSLog(@"operation in CommentlistVC failed");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"the error is %@", error);
    }];
    [self dismissKeyboard:sender];
}

- (void) dismissKeyboard:(id)sender {
    
    [self.view endEditing:YES];
    [_textFieldView.textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    _textFieldView.textField.text = @"";
    __weak CommentListVC *weakSeelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSeelf.tableUsers reloadData];
    });
    _textFieldView.postTextButton.userInteractionEnabled = NO;
    _textFieldView.postTextButton.alpha = 0.7f;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= kGeomMaxCommentLimit;
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    CGRect frame = _tableUsers.frame;
    frame.origin.x = self.view.bounds.origin.x;
    frame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    frame.size.height = self.view.bounds.size.height - kGeomHeightTabBar * 2 - _keyBoardHeight - 15;
    frame.size.width = self.view.bounds.size.width;
    _tableUsers.frame = frame;
    
    frame = _textFieldView.frame;
    frame.origin.x = self.view.bounds.origin.x;
    frame.origin.y = CGRectGetMaxY(self.view.bounds) - kGeomHeightTabBar - _keyBoardHeight;
    frame.size.height = kGeomHeightTabBar;
    frame.size.width = width(self.view);
    _textFieldView.frame = frame;
    
    
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _keyBoardHeight = kbSize.height;
    
    [self.view setNeedsLayout];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    __weak CommentListVC *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf tableviewScrollToTheBottom:YES];
    });
}

- (void)keyboardWillHide:(NSNotification*)notification {
    
    [self.view setNeedsLayout];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    [UIView commitAnimations];
    _keyBoardHeight = 0.0f;
    [self.view layoutIfNeeded];
}

- (void)done:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN(@(object_getClassName(self)));
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.tabBarController.tabBar.hidden = YES;
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
    if (_commentsArray.count <= 0) {
        [_textFieldView.textField becomeFirstResponder];
    } else {
        [self tableviewScrollToTheBottom:YES];
    }
}

- (void)tableviewScrollToTheBottom:(BOOL)scroll {
    
    __weak CommentListVC *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableUsers scrollRectToVisible:CGRectMake(0, weakSelf.tableUsers.contentSize.height - weakSelf.tableUsers.bounds.size.height, weakSelf.tableUsers.bounds.size.width, weakSelf.tableUsers.bounds.size.height) animated:YES];
    });
}

#pragma TableView methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    CommentObject *comment = nil;
    
    @synchronized(self.commentsArray)  {
        if (row < _commentsArray.count) {
            comment = [_commentsArray objectAtIndex:indexPath.row];
        }
    }
    CommentListTVCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kCommentsTableReuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.delegate = self;
    cell.vc = self;
    
    [OOAPI getUserWithID:comment.userID success:^(UserObject *user) {
        cell.user = user;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    cell.comment = comment;
    return cell;
}
//------------------------------------------------------------------------------
// Name:    editingStyleForRowAtIndexPath
// Purpose: Delete cells
//------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentObject *comment = [self.commentsArray objectAtIndex:indexPath.row];
    if (_user.userID == comment.userID || _user.userID == _mio.sourceUserID) {
        return YES;
    }
    return NO;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              __weak CommentListVC *weakSelf = self;
                                              CommentObject *comment = [weakSelf.commentsArray objectAtIndex:indexPath.row];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf.commentsArray removeObject:comment];
                                                  [weakSelf.tableUsers reloadData];
                                              });
                                              
                                              [OOAPI deleteCommentFromMediaItem:comment success:^(CommentObject *comment) {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationViewPhotoVCNeedsUpdate
                                                                                                      object:self];
                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  NSLog(@"the error is %@", error);
                                              }];
                                          }];
    return @[deleteButton];
}



//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentObject *comment = [_commentsArray objectAtIndex:indexPath.row];
    return [CommentListTVCell heightForComment:comment];
    
    //other way to avoid a class method :
    //    CGFloat minHeight = kGeomDimensionsIconButton + kGeomSpaceEdge * 2;
    //    UIFont *font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4];// [UIFont systemFontOfSize:[UIFont systemFontSize]];
    //    CGRect commentBoundingBox = [comment.content boundingRectWithSize:CGSizeMake(width(self.view) - (2 * kGeomSpaceEdge) -kGeomDimensionsIconButton - 20, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName : font} context:nil];
    //    font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3];
    //    CGRect nameBoundingBox = [@"FFF" boundingRectWithSize:CGSizeMake(width(self.view) - (2 * kGeomSpaceEdge) - kGeomDimensionsIconButton, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName : font} context:nil];
    //
    //    NSString *str = NSStringFromCGRect(commentBoundingBox);
    //    NSLog(@"the boundingbox is %@", str);
    //
    //    return MAX(minHeight, CGRectGetHeight(commentBoundingBox) + CGRectGetHeight(nameBoundingBox) + 2 * kGeomSpaceEdge );
    
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    UserObject *user = nil;
    
    @synchronized(self.usersArray)  {
        if (row < _usersArray.count) {
            user = _usersArray[row];
        }
    }
    if (user) {
        [self goToProfile:user];
    }
}

- (void)goToProfile:(UserObject *)user {
    
    ProfileVC *vc= [[ProfileVC alloc] init];
    vc.userInfo = user;
    vc.userID = user.userID;
    [self.navigationController  pushViewController:vc animated:YES];
}
//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    @synchronized(self.commentsArray)  {
        return _commentsArray.count;
    }
}

- (void) userTappedImageOfUser:(UserObject*)user; {
    
    [self goToProfile:user];
}

@end





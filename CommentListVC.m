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

//==============================================================================
@interface CommentListVC ()<UITextFieldDelegate>
@property (nonatomic,strong) UITableView *tableUsers;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic, strong) TextFieldView *textFieldView;
@property CGFloat keyBoardHeight;

@end

@implementation CommentListVC

NSString *const kCommentsTableReuseIdentifier = @"commentListTVC";
NSString *const kCommentsTableReuseIdentifierEmpty = @"commentListTableCellEmpty";

- (void)dealloc {
    [_commentsArray removeAllObjects];
    _commentsArray = nil;
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _commentsArray = [NSMutableArray new];
    
    _needRefresh = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorGrayMiddle);
    
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNeedsRefresh)
                                                 name:kNotificationUserFollowingChanged object:nil];
    
    [self removeNavButtonForSide:kNavBarSideTypeRight];
    [self addNavButtonWithIcon:@"" target:nil action:nil forSide:kNavBarSideTypeRight isCTA:NO];
    
    [self removeNavButtonForSide:kNavBarSideTypeLeft];
    [self addNavButtonWithIcon:kFontIconBack target:self action:@selector(done:) forSide:kNavBarSideTypeLeft isCTA:NO];
    
    //creating the instance of the subclass of UIView that contains the textfield that takes the input(user comment);
    _textFieldView = [TextFieldView new];
    _textFieldView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_textFieldView.postTextButton addTarget:self action:@selector(postComment:) forControlEvents:UIControlEventTouchUpInside];
    _textFieldView.textField.delegate = self;
    [self.view addSubview:_textFieldView];
    _textFieldView.textField.keyboardAppearance = UIKeyboardTypeAlphabet;
    _textFieldView.textField.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3];
    UserObject *user = [Settings sharedInstance].userObject;
    _textFieldView.textField.placeholder = [NSString stringWithFormat:@"add a comment as %@", user.username];
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
    [_commentsArray addObject:comment];
    
    [OOAPI uploadComment:comment forObject:_mio success:^(CommentObject *comment) {
        if (comment) {
            NSLog(@"success from commentlistvc");
        } else {
            NSLog(@"failed");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"the error is %@", error);
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 250;
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
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - deltaHeight , self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    
    _keyBoardHeight = kbSize.height;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + _keyBoardHeight , self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    _keyBoardHeight = 0.0f;
}

//----------------------------------------------------------------------

- (void)setNeedsRefresh {
    _needRefresh = YES;
}

- (void)setCommentsArray:(NSMutableArray *)commentsArray {
    if (_commentsArray == commentsArray) return;
    _commentsArray = commentsArray;
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
    
    _textFieldView.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds) - kGeomHeightTabBar, self.view.bounds.size.width, kGeomHeightTabBar);
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
    CommentObject *comment = nil;

    @synchronized(self.commentsArray)  {
        if (row < _commentsArray.count) {
      comment = [_commentsArray objectAtIndex:indexPath.row];
        }
    }

    if (!comment) {
        UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:kCommentsTableReuseIdentifierEmpty forIndexPath:indexPath];
        cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.text =  @"Alas there are none.";
        cell.textLabel.textColor = UIColorRGBA(kColorWhite);
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    CommentListTVCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kCommentsTableReuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.delegate = self;
    cell.vc = self;
    
    [OOAPI getUserWithID:comment.userID success:^(UserObject *user) {
        [cell provideUser:user];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
    [cell provideComment:comment];
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
    CommentObject *comment = [_commentsArray objectAtIndex:indexPath.row];
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

    @synchronized(self.commentsArray)  {
        return _commentsArray.count;
    }
}

- (void)userTappedSectionHeader:(int)which {
}


- (void) userTappedImageOfUser:(UserObject*)user; {
    [self goToProfile:user];
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




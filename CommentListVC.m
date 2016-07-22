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


#define COMMENT_LIST_TABLE_REUSE_IDENTIFIER  @"commentListTVC"
#define COMMENT_LIST_TABLE_REUSE_IDENTIFIER_EMPTY  @"commentListTableCellEmpty"

//==============================================================================
@interface CommentListVC ()
@property (nonatomic,strong) UITableView *tableUsers;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic, strong) TextFieldView *textFieldView;
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
    [self.view addSubview:_textFieldView];
    
}

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
    self.view.backgroundColor = [UIColor yellowColor];


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
    
    _textFieldView.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds) - 70, self.view.bounds.size.width, 70);
    _textFieldView.backgroundColor = [UIColor yellowColor];
    
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

    [cell fetchStats];
    
    return cell;
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kGeomHeightHorizontalListRow;
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
    @synchronized(self.usersArray)  {
        return _usersArray.count;
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
    self=[super init];
    if (self) {
        _labelTitle = makeLabelLeft (self, nil, kGeomFontSizeH3);
        _labelTitle.textColor = UIColorRGBA(kColorWhite);
        _labelExpander = makeIconLabel(self, kFontIconBack, kGeomIconSize);
        _labelExpander.textColor = UIColorRGBA(kColorTextActive);
        self.backgroundColor = UIColorRGBA(kColorOffWhite);
        _isExpanded=expanded;
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




//
//  UserListVC.m
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "Common.h"
#import "AppDelegate.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "ListObject.h"
#import "UserListVC.h"
#import "Settings.h"
#import "ProfileVC.h"

#define USER_LIST_TABLE_REUSE_IDENTIFIER  @"userListTVC"
#define USER_LIST_TABLE_REUSE_IDENTIFIER_EMPTY  @"userListTableCellEmpty"

//==============================================================================

@interface UserListTableSectionHeader ()
@property (nonatomic,strong) UILabel *labelExpander;
@end

@implementation UserListTableSectionHeader

- (instancetype) initWithExpandedFlag: (BOOL) expanded_
{
    self=[super init];
    if (self) {
        _labelTitle=makeLabelLeft (self, nil, kGeomFontSizeH3);
        _labelTitle.textColor=UIColorRGBA(kColorWhite);
        _labelExpander=makeIconLabel(self, kFontIconBack, kGeomIconSize);
        _labelExpander.textColor= UIColorRGBA(kColorTextActive);
        self.backgroundColor=UIColorRGBA(kColorOffWhite);
        _isExpanded=expanded_;
    }
    return self;
}

- (void)layoutSubviews
{
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

//==============================================================================
@interface UserListVC ()
@property (nonatomic,strong) UITableView *tableUsers;
@property (nonatomic,strong) NSMutableArray *followeesArray; 
@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationFollowees;
@property (nonatomic) BOOL needRefresh;
@end

@implementation UserListVC

- (void)dealloc
{
    [_usersArray removeAllObjects];
    self.usersArray = nil;
    [_followeesArray removeAllObjects];
    self.followeesArray = nil;
    [_fetchOperationFollowees cancel];
    _fetchOperationFollowees = nil;
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
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
    
    self.tableUsers = makeTable(self.view,self);
    _tableUsers.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_tableUsers registerClass:[UserListTVC class] forCellReuseIdentifier:USER_LIST_TABLE_REUSE_IDENTIFIER];
    [_tableUsers registerClass:[UITableViewCell class] forCellReuseIdentifier:USER_LIST_TABLE_REUSE_IDENTIFIER_EMPTY];
    [_tableUsers setLayoutMargins:UIEdgeInsetsZero];
    _tableUsers.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableUsers.separatorColor= UIColorRGBA(kColorBordersAndLines);
    _tableUsers.separatorInset = UIEdgeInsetsZero;
    _tableUsers.showsVerticalScrollIndicator= NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNeedsRefresh)
                                                 name:kNotificationUserFollowingChanged object:nil];

    
    
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
    [self setRightNavWithIcon:@"" target:nil action:nil];
}

- (void)setNeedsRefresh {
    _needRefresh = YES;
}

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
 
    [self refreshIfNeeded];
}

- (void)refreshIfNeeded {
    if (_needRefresh) {
        [self fetchFollowees];
        _needRefresh = NO;
    }
}

//------------------------------------------------------------------------------
// Name:    viewWillDisappear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//------------------------------------------------------------------------------
// Name:    viewDidAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    _tableUsers.frame = self.view.bounds;
}

- (BOOL)user:(UserObject *)user isFollowingUser:(NSUInteger)userID
{
    if (!_followeesArray) {
        return NO;
    }
    @synchronized(self.followeesArray) {
        for (UserObject *user in _followeesArray) {
            if (user.userID == userID) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)fetchFollowees
{
    // NOTE: Need to make the call to find out who we are following before anything else is displayed.
    
    __weak UserListVC *weakSelf = self;
    
    UserObject *currentUser = [Settings sharedInstance].userObject;
    
    [OOAPI getFollowingForUser:currentUser.userID success:^(NSArray *users) {
        @synchronized(weakSelf.followeesArray)  {
            weakSelf.followeesArray= users.mutableCopy;
            NSLog  (@"SUCCESS IN FETCHING %lu FOLLOWEES",
                    ( unsigned long)weakSelf.followeesArray.count);
        }
        ON_MAIN_THREAD(^{ [weakSelf.tableUsers  reloadData]; });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"CANNOT GET LIST OF PEOPLE WE ARE FOLLOWING");
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UserObject *u = nil;
    
    @synchronized(self.usersArray)  {
        if (row < _usersArray.count) {
            u = _usersArray[row];
        }
    }
    
    if (!u) {
        UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:USER_LIST_TABLE_REUSE_IDENTIFIER_EMPTY forIndexPath:indexPath];
        cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.text=  @"Alas there are none.";
        cell.textLabel.textColor=UIColorRGBA(kColorWhite);
        cell.selectionStyle= UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    UserListTVC *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:USER_LIST_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cell.textLabel.textAlignment=NSTextAlignmentCenter;
    cell.selectionStyle= UITableViewCellSeparatorStyleNone;
    cell.delegate= self;
    cell.vc=self;
    [cell provideUser:u];
    
    if (_followeesArray) {
        @synchronized(self.followeesArray) {
            if ([Settings sharedInstance].userObject.userID == u.userID) {
                cell.buttonFollow.hidden = YES;
            } else {
                [cell showFollowButton:[self user:self.user isFollowingUser:u.userID]];
            }
        }
    }
    
    [cell fetchStats];
    
    return cell;
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightHorizontalListRow;
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)goToProfile: (UserObject*)u
{
    ProfileVC *vc= [[ProfileVC alloc] init];
    vc.userInfo = u;
    vc.userID = u.userID;
    [self.navigationController  pushViewController:vc animated:YES];
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @synchronized(self.usersArray)  {
        return _usersArray.count;
    }
}

- (void)userTappedSectionHeader:(int)which
{
    
    
}

- (void)userTappedFollowButtonForUser:(UserObject*)user following:(BOOL)following
{
    if (following ) {
        [_followeesArray addObject: user];
    } else {
        [_followeesArray removeObject: user];
    }
}

- (void) userTappedImageOfUser:(UserObject*)user;
{
    [self goToProfile:user];
}

@end

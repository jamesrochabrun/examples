//
//  ConnectVC.m
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
#import "ConnectVC.h"
#import "Settings.h"
#import "ProfileVC.h"
#import "SocialMedia.h"

#define CONNECT_TABLE_REUSE_IDENTIFIER  @"userTableCell"
#define CONNECT_TABLE_REUSE_IDENTIFIER_EMPTY  @"connectTableCellEmpty"

//==============================================================================

@interface ConnectTableSectionHeader ()
@property (nonatomic,strong) UILabel *labelExpander;
@end

@implementation ConnectTableSectionHeader

- (instancetype) initWithExpandedFlag: (BOOL) expanded_
{
    self=[super init];
    if (self) {
        _labelTitle=makeLabelLeft (self, nil, kGeomFontSizeStripHeader);
        _labelTitle.textColor=WHITE;
        _labelExpander=makeIconLabel(self, kFontIconBack, kGeomIconSize);
        _labelExpander.textColor= UIColorRGBA(kColorYellow);
        self.backgroundColor=GRAY;
        _isExpanded=expanded_;
    }
    return self;
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.delegate userTappedSectionHeader:( int)self.tag];
    
    _isExpanded=!_isExpanded;
    
    [UIView animateWithDuration:.4
                     animations:^{
                         [self layoutSubviews];
                     }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    float w=self.frame.size.width;
    float h=self.frame.size.height;
    const float kGeomConnectHeaderLeftMargin=29;
    const float kGeomConnectHeaderRightMargin=24;
    self.labelTitle.frame = CGRectMake(kGeomConnectHeaderLeftMargin,0,w/2,h);
    [self.labelExpander sizeToFit];
    float labelWidth= h;
    self.labelExpander.frame = CGRectMake(w-kGeomConnectHeaderRightMargin-labelWidth,0
                                          ,labelWidth,h);
    double angle = _isExpanded ? 3*M_PI/2 : M_PI/2;
    _labelExpander.layer.transform=CATransform3DMakeRotation(angle, 0, 0, 1);
}

@end

//==============================================================================
@interface ConnectVC ()
@property (nonatomic,strong) UITableView *tableAccordion;

@property (nonatomic,strong) NSMutableArray *suggestedUsersArray; // section 0
@property (nonatomic,strong) NSMutableArray *foodiesArray; // section 1
@property (nonatomic,strong) NSMutableArray *followeesArray; // section 2

@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection1; // fb
@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection2; // foodies
@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection3; // users who follow you

@property (nonatomic,strong) NSArray *arraySectionHeaderViews;
@property (nonatomic,assign) BOOL canSeeSection1Items,canSeeSection2Items;

@end

@implementation ConnectVC

- (void)dealloc
{
    [_suggestedUsersArray removeAllObjects];
    [_foodiesArray removeAllObjects];
    [_followeesArray removeAllObjects];
    self.suggestedUsersArray = nil;
    self.foodiesArray = nil;
    self.followeesArray = nil;
    self.arraySectionHeaderViews = nil;
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.canSeeSection1Items = YES;
    self.canSeeSection2Items = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _suggestedUsersArray = [NSMutableArray new];
    _foodiesArray = [NSMutableArray new];
    _followeesArray = [NSMutableArray new];
    
    ConnectTableSectionHeader *headerView1 = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeSection1Items];
    ConnectTableSectionHeader *headerView2 = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeSection2Items];
    
    headerView1.backgroundColor=UIColorRGB(kColorOffBlack);
    headerView1.labelTitle.text=@"Friends you can follow";
    
    headerView2.backgroundColor=UIColorRGB(kColorOffBlack);
    headerView2.labelTitle.text=@"Foodies";
    
    _arraySectionHeaderViews= @[headerView1, headerView2];
    
    NavTitleObject *nto;
    nto = [[NavTitleObject alloc] initWithHeader:LOCAL(@"Connect")
                                       subHeader:LOCAL(@"find your foodies")];
    
    self.navTitle = nto;
    
    self.tableAccordion = makeTable(self.view,self);
    _tableAccordion.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_tableAccordion registerClass:[UserListTVC class] forCellReuseIdentifier:CONNECT_TABLE_REUSE_IDENTIFIER];
    [_tableAccordion registerClass:[UITableViewCell class] forCellReuseIdentifier:CONNECT_TABLE_REUSE_IDENTIFIER_EMPTY];
    [_tableAccordion setLayoutMargins:UIEdgeInsetsZero];
    _tableAccordion.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableAccordion.separatorColor = UIColorRGB(kColorBlack);
    _tableAccordion.showsVerticalScrollIndicator= NO;
    
    [self setLeftNavWithIcon:@"" target:nil action:nil];

}

- (void)fetchFoodies
{
    UserObject*user= [Settings sharedInstance].userObject;
    __weak ConnectVC *weakSelf = self;
    
    self.fetchOperationSection2 =
    [OOAPI getFoodieUsersForUser:user
                         success:^(NSArray *users) {
                             @synchronized(_foodiesArray)  {
                                 weakSelf.foodiesArray= users.mutableCopy;
                                 NSLog  (@"SUCCESS IN FETCHING %lu FOODIES",
                                         ( unsigned long)weakSelf.foodiesArray.count);
                             }
                             if (weakSelf.canSeeSection2Items) {
                                 // RULE: Don't reload the section unless the foodies are visible.
                                 ON_MAIN_THREAD(^() {
                                    // [weakSelf.tableAccordion reloadData];
                                    [self.tableAccordion reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
                                 });
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog  (@"UNABLE TO FETCH FOODIES");
                         }
     ];
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
    
    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [APP registerForPushNotifications];
    }
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
    [ self reload];
}

- (void)reload
{
    // NOTE: Need to make the call to find out who we are following before anything else is displayed.
    
    __weak  ConnectVC *weakSelf = self;
    
    UserObject* currentUser= [Settings sharedInstance].userObject;
    [OOAPI getFollowingOf:currentUser.userID success:^(NSArray *users) {
        @synchronized(weakSelf.followeesArray)  {
            weakSelf.followeesArray= users.mutableCopy;
            NSLog  (@"SUCCESS IN FETCHING %lu FOLLOWEES",
                    ( unsigned long)weakSelf.followeesArray.count);
        }
        [weakSelf reloadAfterDeterminingWhoWeAreFollowing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog  (@"CANNOT GET LIST OF PEOPLE WE ARE FOLLOWING");
    }];
}

- (void) reloadAfterDeterminingWhoWeAreFollowing
{
    [self.fetchOperationSection1 cancel];
    [self.fetchOperationSection2 cancel];
//    [self.fetchOperationSection3 cancel];
    self.fetchOperationSection1= nil;
    self.fetchOperationSection2= nil;
    self.fetchOperationSection3= nil;
    
    [self fetchUserFriendListFromFacebook];
    [self fetchFoodies];
//    [self fetchFollowers];
}

- (BOOL) weAreFollowingUser: (NSUInteger) identifier
{
    for (UserObject* user  in  _followeesArray) {
        if ( user.userID == identifier) {
            return YES;
        }
    }
    return NO;
}

//------------------------------------------------------------------------------
// Name:    viewWillDisappear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    _tableAccordion.frame = self.view.bounds; // Replaces 4 constraints.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    UserObject *u = nil;
    
    switch (section) {
        case 0:
            @synchronized(self.suggestedUsersArray)  {
                if ( row<_suggestedUsersArray.count) {
                    u=_suggestedUsersArray[row];
                }
            }
            break;
            
        case 1:
            @synchronized(self.foodiesArray)  {
                if ( row<_foodiesArray.count) {
                    u=_foodiesArray[row];
                }
            }
            break;

        default:
            break;
    }
    
    if (!u) {
        NSString *lamentString = !section ?
        @"Invite Facebook friends to use Oomami. When they join you'll be able to find out what the like to eat."
        :
        @"We'll keep an eye out for foodies you can follow.";
        
        UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:CONNECT_TABLE_REUSE_IDENTIFIER_EMPTY forIndexPath:indexPath];
        cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = lamentString;
        cell.textLabel.font = [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH3];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = UIColorRGBA(kColorWhite);
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    UserListTVC *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CONNECT_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cell.textLabel.textAlignment=NSTextAlignmentCenter;
    cell.selectionStyle= UITableViewCellSeparatorStyleNone;
    cell.delegate= self;
    [cell provideUser:u];
    
    if ( section != 3) {
        BOOL following= [self weAreFollowingUser:u.userID];
        [cell showFollowButton: following];
    }
    
    [cell fetchStats];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}

//------------------------------------------------------------------------------
// Name:    viewForHeaderInSection
// Purpose:
//------------------------------------------------------------------------------
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section >= _arraySectionHeaderViews.count)
        return nil;
    
    ConnectTableSectionHeader *view = _arraySectionHeaderViews[section];
    view.delegate= self;
    view.tag= section;
    return view;
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL haveData=NO;
    NSInteger section=indexPath.section;
    NSInteger row=indexPath.row;

    switch (section) {
        case 0:
            @synchronized(self.suggestedUsersArray)  {
                if ( row<_suggestedUsersArray.count) {
                    haveData=YES;
                }
            }
            break;
        case 1:
            @synchronized(self.foodiesArray)  {
                if ( row<_foodiesArray.count) {
                    haveData=YES;
                }
            }
            break;
        default:
            break;
    }
    
    if (!haveData) {
        if (!section) {
            return 130;
        } else {
            return 80;
        }
    }
    
    return kGeomHeightHorizontalListRow;
}

//------------------------------------------------------------------------------
// Name:    heightForHeaderInSection6+
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kGeomConnectScreenHeaderHeight;
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    UserObject *u = nil;
    
    switch (section) {
        case 0:
            @synchronized(self.suggestedUsersArray) {
                if (row<_suggestedUsersArray.count) {
                    u = _suggestedUsersArray[row];
                }
            }
            break;
        case 1:
            @synchronized(self.foodiesArray) {
                if (row < _foodiesArray.count) {
                    u = _foodiesArray[row];
                }
            }
            break;
        default:
            break;
    }
    
    if ( u) {
        [self goToProfile:u];
    }
}

- (void)goToProfile: (UserObject*)u
{
    ProfileVC *vc= [[ProfileVC alloc] init];
    vc.userInfo = u;
    vc.userID = u.userID;
    [self.navigationController pushViewController:vc animated:YES];
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            @synchronized(self.suggestedUsersArray)  {
                return _canSeeSection1Items? MAX(1,_suggestedUsersArray.count):0;
            }
            break;
        case 1:
            @synchronized(self.foodiesArray)  {
                return _canSeeSection2Items? MAX(1,_foodiesArray.count):0;
            }
            break;
        default:
            break;
    }
    return 0;
}

- (void)userTappedFollowButtonForUser:(UserObject *)user following:(BOOL)following
{
    [self reload];
}

- (void)userTappedSectionHeader:(int)which
{
    switch ( which) {
        case 0:
            _canSeeSection1Items = !_canSeeSection1Items;
            break;
            
        case 1:
            _canSeeSection2Items = !_canSeeSection2Items;
            break;
    }
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:which];
    [_tableAccordion reloadSections:indexSet withRowAnimation: UITableViewRowAnimationAutomatic];
}

- (void)userTappedImageOfUser:(UserObject *)user;
{
    [self goToProfile:user];
}

//------------------------------------------------------------------------------
// Name:    fetchUserFriendListFromFacebook
// Purpose:
//------------------------------------------------------------------------------
- (void)fetchUserFriendListFromFacebook
{
    ENTRY;
    
    __weak ConnectVC *weakSelf= self;
    [SocialMedia fetchUserFriendListFromFacebook:^(NSArray *friends) {
        if (!friends) {
            return;
        }
        if (!friends.count) {
            [weakSelf refreshSuggestedUsersSection];
        }
        [weakSelf determineWhichFriendsAreNotOOUsers:friends];
    }];
}

- (void)determineWhichFriendsAreNotOOUsers:(NSArray *)array
{
    if (!array || !array.count) {
        return;
    }
    
    NSString *string = [array firstObject];
    __weak ConnectVC *weakSelf= self;

    if  (![string containsString:@"@"]) {
        [OOAPI getUsersTheCurrentUserIsNotFollowingUsingFacebookIDs:array
                                                       success:^(NSArray *users) {
                                                           @synchronized(weakSelf.suggestedUsersArray)  {
                                                               weakSelf.suggestedUsersArray = users.mutableCopy;
                                                           }
                                                           ON_MAIN_THREAD(^{
                                                               [weakSelf refreshSuggestedUsersSection];
                                                           });
                                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                           NSLog (@"FETCH OF NON-FOLLOWEES USING FB IDs FAILED");
                                                       }];
    }
}

- (void)refreshSuggestedUsersSection
{
    // RULE: Don't reload the section unless the foodies are visible.
    if (self.canSeeSection1Items) {
        [self.tableAccordion reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:NO];
    }
}

@end

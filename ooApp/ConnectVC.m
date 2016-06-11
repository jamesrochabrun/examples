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
#import "OOActivityItemProvider.h"
#import "DebugUtilities.h"

static NSString *const kConnectUserCellIdentifier = @"userTableCell";
static NSString *const kConnectEmptyCellIdentifier = @"connectTableCellEmpty";

//==============================================================================

@interface ConnectTableSectionHeader ()
@property (nonatomic, strong) UILabel *labelExpander;
@property (nonatomic, strong) UILabel *noUsersMsgLabel;
@property (nonatomic) NSInteger numberUsers;
@property (nonatomic, strong) UIView *banner;
@end

@implementation ConnectTableSectionHeader

- (instancetype) initWithExpandedFlag: (BOOL) expanded_
{
    self=[super init];
    if (self) {
        _banner = [[UIView alloc] init];
        _banner.backgroundColor = UIColorRGBA(kColorConnectHeaderBackground);
        [self addSubview:_banner];
        
        _noUsersMsgLabel = [[UILabel alloc] init];
        [_noUsersMsgLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH3] textColor:kColorGrayMiddle backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        [self addSubview:_noUsersMsgLabel];
        
        _labelTitle = makeLabelLeft (self, nil, kGeomFontSizeH2);
        _labelTitle.textColor = UIColorRGBA(kColorText);
        _labelExpander = makeIconLabel(self, kFontIconBack, kGeomIconSize);
        _labelExpander.textAlignment = NSTextAlignmentCenter;
        _labelExpander.textColor = UIColorRGBA(kColorTextActive);
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        _isExpanded = expanded_;
        
        _noUsersMsgLabel.hidden = YES;
//        [DebugUtilities addBorderToViews:@[_labelTitle, _labelExpander, _noUsersMsgLabel]];
    }
    return self;
}

- (void)setNoUsersMessage:(NSString *)noUsersMessage {
    _noUsersMessage = noUsersMessage;
    _noUsersMsgLabel.text = _noUsersMessage;
    [_noUsersMsgLabel setNeedsLayout];
}

- (void)setNumberUsers:(NSInteger)numberUsers {
    _numberUsers = numberUsers;
    if (!_numberUsers) {
        _labelExpander.hidden = YES;
        _noUsersMsgLabel.hidden = NO;
    } else {
        _labelExpander.hidden = NO;
        _noUsersMsgLabel.hidden = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.delegate userTappedSectionHeader:(int)self.tag];
    
    _isExpanded = !_isExpanded;
    
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat w = width(self);
    CGFloat h = height(self);
    const CGFloat kGeomConnectHeaderLeftMargin = 10;
    const CGFloat kGeomConnectHeaderRightMargin = 24;
    
    _banner.frame = CGRectMake(0, 0, w, kGeomConnectScreenHeaderHeight);
    _labelTitle.frame = CGRectMake(kGeomConnectHeaderLeftMargin, 0, w/2, kGeomConnectScreenHeaderHeight);

    [_labelExpander sizeToFit];
    _labelExpander.frame = CGRectMake(w-kGeomConnectHeaderRightMargin-CGRectGetWidth(_labelExpander.frame),
                                      (kGeomConnectScreenHeaderHeight-CGRectGetHeight(_labelExpander.frame))/2,
                                      CGRectGetWidth(_labelExpander.frame),
                                      CGRectGetHeight(_labelExpander.frame));
    CGFloat angle = _isExpanded ? 3*M_PI/2 : M_PI/2;
    _labelExpander.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
    
    CGRect frame;
    frame = _noUsersMsgLabel.frame;
    frame.size = [_noUsersMsgLabel sizeThatFits:CGSizeMake(width(self) - 2*kGeomSpaceEdge, 100)];
    frame.size.width = width(self) - 2*kGeomSpaceEdge;
    frame.origin.x = kGeomSpaceEdge;
    frame.origin.y = kGeomConnectScreenHeaderHeight + (h-kGeomConnectScreenHeaderHeight-frame.size.height)/2;
    _noUsersMsgLabel.frame = frame;
}

@end

//==============================================================================
@interface ConnectVC ()
@property (nonatomic, strong) UITableView *tableAccordion;

@property (nonatomic, strong) NSArray *friendsArray; // section 0
@property (nonatomic, strong) NSArray *foodiesArray; // section 1
@property (nonatomic, strong) NSArray *followeesArray; // section 2
@property (nonatomic, strong) NSArray *trustedUsersArray; // section 3
@property (nonatomic, strong) NSArray *inTheKnowUsersArray; // section

@property (nonatomic, strong) AFHTTPRequestOperation *roFriends; // fb
@property (nonatomic, strong) AFHTTPRequestOperation *roFoodies; // foodies
@property (nonatomic, strong) AFHTTPRequestOperation *roTrustedUsers; // users new to Oomami
@property (nonatomic, strong) AFHTTPRequestOperation *roInTheKnow; // users in the know around you
@property (nonatomic, strong) AFHTTPRequestOperation *roSearch;

@property (nonatomic, strong) NSArray *arraySectionHeaderViews;
@property (nonatomic, assign) BOOL canSeeFriends, canSeeFoodies, canSeeTrustedUsers, canSeeInTheKnow;
@property (nonatomic, assign) BOOL gotFriendsResult, gotFoodiesResult, gotTrustedUsersResult, gotInTheKnowResult;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL searchMode;
@property (nonatomic, strong) NSArray *searchResultsArray;
@property (nonatomic, strong) UIButton *inviteFriends;

@end

@implementation ConnectVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationConnectNeedsUpdate object:nil];
    self.friendsArray = nil;
    self.foodiesArray = nil;
    self.followeesArray = nil;
    self.trustedUsersArray = nil;
    self.arraySectionHeaderViews = nil;
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _canSeeFoodies = _canSeeFriends = _canSeeInTheKnow = _canSeeTrustedUsers = YES;
    
    _needRefresh = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _friendsArray = [NSArray new];
    _foodiesArray = [NSArray new];
    //_followeesArray = [NSArray new];
    _trustedUsersArray = [NSArray new];
    _inTheKnowUsersArray = [NSArray new];
    _searchResultsArray = [NSArray new];
    
    ConnectTableSectionHeader *hvTrustedUsers = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeTrustedUsers];
    hvTrustedUsers.noUsersMessage = @"Trusted sources will appear here.";
    hvTrustedUsers.labelTitle.text = @"Trusted Sources";
    
    ConnectTableSectionHeader *hvFriendsToFollow = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeFriends];
    hvFriendsToFollow.noUsersMessage = @"Invite Facebook friends to use Oomami. When they join you'll be able to find out what they like to eat.";
    hvFriendsToFollow.labelTitle.text = @"Friends you can Follow";
    
    ConnectTableSectionHeader *hvTopFoodies = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeFoodies];
    hvTopFoodies.noUsersMessage = @"We'll keep an eye out for foodies you can follow. When you upload a lot of food photos or add to lists you too will become a foodie.";
    hvTopFoodies.labelTitle.text = @"Top Foodies to Follow";
    
    ConnectTableSectionHeader *hvInTheKnow = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeInTheKnow];
    hvInTheKnow.noUsersMessage = @"User that know this area will appear here.";
    hvInTheKnow.labelTitle.text = @"In the Know Around You";
    
    _arraySectionHeaderViews= @[hvTrustedUsers, hvFriendsToFollow, hvTopFoodies, hvInTheKnow];
    
    NavTitleObject *nto;
    nto = [[NavTitleObject alloc] initWithHeader:LOCAL(@"Connect")
                                       subHeader:LOCAL(@"find your foodies")];
    
    self.navTitle = nto;
    
    self.tableAccordion = makeTable(self.view,self);
    _tableAccordion.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_tableAccordion registerClass:[UserListTVC class] forCellReuseIdentifier:kConnectUserCellIdentifier];
    [_tableAccordion registerClass:[UITableViewCell class] forCellReuseIdentifier:kConnectEmptyCellIdentifier];
    [_tableAccordion setLayoutMargins:UIEdgeInsetsZero];
    _tableAccordion.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableAccordion.separatorColor = UIColorRGBA(kColorBordersAndLines);
    _tableAccordion.showsVerticalScrollIndicator = NO;
    
    _searchBar = [UISearchBar new];
    _searchBar.placeholder = kSearchPlaceholderPeople;
    _searchBar.backgroundColor = UIColorRGBA(kColorNavBar);
    _searchBar.barTintColor = UIColorRGBA(kColorNavBar);
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    _searchBar.alpha =0;
    _searchMode = NO;
    
//    [self setRightNavWithIcon:kFontIconInvite target:self action:@selector(invitePerson:)];
//    
//    [self setLeftNavWithIcon:@"" target:nil action:nil];
    
    [self removeNavButtonForSide:kNavBarSideTypeLeft];
    [self addNavButtonWithIcon:kFontIconSearch target:self action:@selector(showSearch) forSide:kNavBarSideTypeLeft isCTA:NO];
    
    [self removeNavButtonForSide:kNavBarSideTypeRight];
    [self addNavButtonWithIcon:@"" target:nil action:nil forSide:kNavBarSideTypeRight isCTA:NO];
    
    _inviteFriends = [UIButton buttonWithType:UIButtonTypeCustom];
    UILabel *iconLabel = [UILabel new];
    [iconLabel setBackgroundColor:UIColorRGBA(kColorClear)];
    iconLabel.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
    iconLabel.text = kFontIconInvite;
    iconLabel.textColor = UIColorRGBA(kColorTextReverse);
    [iconLabel sizeToFit];
    UIImage *icon = [UIImage imageFromView:iconLabel];
    [_inviteFriends withText:@"invite friends" fontSize:kGeomFontSizeH1 width:0 height:0 backgroundColor:kColorTextActive textColor:kColorTextReverse borderColor:kColorTextActive target:self selector:@selector(invitePerson:)];
    [_inviteFriends setImage:icon forState:UIControlStateNormal];
    _inviteFriends.layer.cornerRadius = 0;
    [self.view addSubview:_inviteFriends];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNeedsRefresh)
                                                 name:kNotificationConnectNeedsUpdate object:nil];
}

- (void)showSearch {
    [self showSearch:!_searchMode];
}

- (void)showSearch:(BOOL)showIt {
    _searchMode = showIt;
    
    if (showIt) {
        [_searchBar becomeFirstResponder];
        _inviteFriends.hidden = YES;
    } else {
        _inviteFriends.hidden = NO;
        _searchBar.text = @"";
        [_tableAccordion reloadData];
        [_searchBar resignFirstResponder];
    }
    
    //_searchBar.showsCancelButton = YES;
    [UIView animateWithDuration:0.5 animations:^{
        _searchBar.alpha = (showIt)? 1:0;
        _searchBar.frame = CGRectMake(0, 0, width(self.view), 40);
        _tableAccordion.frame = CGRectMake(0, _searchMode?40:0, width(self.view), height(self.view)-(_searchMode?40:0));
    }];
    
    //[self.view setNeedsLayout];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([_searchBar.text length]) {
        [_roSearch cancel];
        [self searchForPeople];
    } else {
        [_tableAccordion reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self showSearch:NO];
    [_tableAccordion reloadData];
    _searchBar.text = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
}

- (void)searchForPeople {
    __weak ConnectVC *weakSelf = self;
    _roSearch = [OOAPI getUsersWithKeyword:_searchBar.text
                                            success:^(NSArray *users) {
                                                weakSelf.searchResultsArray = users;
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [weakSelf.tableAccordion reloadData];
                                                    [weakSelf.refreshControl endRefreshing];
                                                });
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                                                NSLog(@"ERROR FETCHING USERS BY KEYWORD: %@",e );
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [weakSelf.refreshControl endRefreshing];
                                                });
                                            }
                          ];
}

- (void)invitePerson:(id)sender {
    UIImage *img = [UIImage imageNamed:@"Oomami_AppStoreLogo(120x120).png"];
    OOActivityItemProvider *aip = [[OOActivityItemProvider alloc] initWithPlaceholderItem:@""];
    aip.restaurant = nil;
    aip.mio = nil;
    
    NSArray *items = @[aip, img];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    avc.popoverPresentationController.sourceView = sender;
    avc.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
    
    [avc setValue:[NSString stringWithFormat:@"Let's try out Oomami together!"] forKey:@"subject"];
    [avc setExcludedActivityTypes:
     @[UIActivityTypeAssignToContact,
       UIActivityTypePostToFlickr,
       UIActivityTypeCopyToPasteboard,
       UIActivityTypePrint,
       UIActivityTypeSaveToCameraRoll,
       UIActivityTypePostToWeibo]];
    
    [self.navigationController presentViewController:avc animated:YES completion:^{
        ;
    }];
    
    avc.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
    };
    
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _searchBar.frame = CGRectMake(0, 0, width(self.view), 40);
    _inviteFriends.frame = CGRectMake(0, height(self.view)-kGeomHeightButton, width(self.view), kGeomHeightButton);
    _tableAccordion.frame = CGRectMake(0, _searchMode?40:0, width(self.view), height(self.view)-(_searchMode?40:0)- (_searchMode?0:CGRectGetHeight(_inviteFriends.frame)));
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN( @( object_getClassName(self)));
    
    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [APP registerForPushNotifications];
    }
    
    [self refreshIfNeeded];
    
    [self.refreshControl addTarget:self action:@selector(forceRefresh:) forControlEvents:UIControlEventValueChanged];
    [_tableAccordion addSubview:self.refreshControl];
    _tableAccordion.alwaysBounceVertical = YES;
}

- (void)forceRefresh:(id)sender {
    _needRefresh = YES;
    [self refreshIfNeeded];
}

- (void)refreshIfNeeded {
    if (_needRefresh) {
        [self reload];
        _needRefresh = NO;
    }
}

- (void)setNeedsRefresh {
    _needRefresh = YES;
}

- (void)reload {
    if (_searchMode) {
        [_roSearch cancel];
        [self searchForPeople];
    } else {
        _gotFriendsResult =
        _gotFoodiesResult =
        _gotTrustedUsersResult =
        _gotInTheKnowResult = NO;
        
        [self reloadAfterDeterminingWhoWeAreFollowing];
        [self updateFollowing];
    }
}

- (void)updateFollowing {
    __weak  ConnectVC *weakSelf = self;
    
    UserObject *currentUser = [Settings sharedInstance].userObject;
    [OOAPI getFollowingForUser:currentUser.userID success:^(NSArray *users) {
        weakSelf.followeesArray = users;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *visibleRowIndeces = [weakSelf.tableAccordion indexPathsForVisibleRows];
            [weakSelf.tableAccordion reloadRowsAtIndexPaths:visibleRowIndeces withRowAnimation:UITableViewRowAnimationAutomatic];

            //[weakSelf reloadAfterDeterminingWhoWeAreFollowing];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"CANNOT GET LIST OF PEOPLE WE ARE FOLLOWING");
    }];
}

- (void)fetchFoodies
{
    UserObject*user= [Settings sharedInstance].userObject;
    __weak ConnectVC *weakSelf = self;
    
    self.roFoodies =
    [OOAPI getFoodieUsersForUser:user
                         success:^(NSArray *users) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 NSMutableArray *deletedPaths = [NSMutableArray array];
                                 NSUInteger d, i;
                                 for (d=0; d<[weakSelf.foodiesArray count]; d++) {
                                     [deletedPaths addObject:[NSIndexPath indexPathForRow:d inSection:kConnectSectionFoodies]];
                                 }
                                 NSMutableArray *insertedPaths = [NSMutableArray array];
                                 
                                 for (i=0; i<[users count]; i++) {
                                     [insertedPaths addObject:[NSIndexPath indexPathForRow:i inSection:kConnectSectionFoodies]];
                                 }
                                 weakSelf.foodiesArray = users;
                                 weakSelf.gotFoodiesResult = YES;
                                 
                                 NSLog(@"foodies(%lu) deleting=%lu inserting=%lu", (unsigned long)kConnectSectionFoodies, (unsigned long)[deletedPaths count], (unsigned long)[insertedPaths count]);

                                 if (_canSeeFoodies) {
                                     [weakSelf.tableAccordion beginUpdates];
                                     [weakSelf.tableAccordion deleteRowsAtIndexPaths:deletedPaths withRowAnimation:UITableViewRowAnimationNone];
                                     [weakSelf.tableAccordion insertRowsAtIndexPaths:insertedPaths withRowAnimation:UITableViewRowAnimationNone];
                                     [weakSelf.tableAccordion reloadSections:[[NSIndexSet alloc] initWithIndex:kConnectSectionFoodies] withRowAnimation:UITableViewRowAnimationNone];
                                     [weakSelf.tableAccordion endUpdates];
                                 }
                                 [weakSelf.refreshControl endRefreshing];
                             });
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             weakSelf.gotFoodiesResult = YES;
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [weakSelf.refreshControl endRefreshing];
                             });
                         }
     ];
}

- (void)fetchTrustedUsers
{
    __weak ConnectVC *weakSelf = self;
    
    self.roTrustedUsers = [OOAPI getUsersOfType:kUserTypeTrusted success:^(NSArray *users) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                                NSMutableArray *deletedPaths = [NSMutableArray array];
                                NSUInteger d, i;
                                for (d=0; d<[weakSelf.trustedUsersArray count]; d++) {
                                    [deletedPaths addObject:[NSIndexPath indexPathForRow:d inSection:kConnectSectionTrusted]];
                                }
                                NSMutableArray *insertedPaths = [NSMutableArray array];
            
                                for (i=0; i<[users count]; i++) {
                                    [insertedPaths addObject:[NSIndexPath indexPathForRow:i inSection:kConnectSectionTrusted]];
                                }
                                weakSelf.trustedUsersArray = users;
                                weakSelf.gotTrustedUsersResult = YES;
            
                                NSLog(@"trusted souces(%lu) deleting=%lu inserting=%lu", (unsigned long)kConnectSectionTrusted, (unsigned long)[deletedPaths count], (unsigned long)[insertedPaths count]);
        
                                if (_canSeeTrustedUsers) {
                                    [weakSelf.tableAccordion beginUpdates];
                                    [weakSelf.tableAccordion deleteRowsAtIndexPaths:deletedPaths withRowAnimation:UITableViewRowAnimationNone];
                                    [weakSelf.tableAccordion insertRowsAtIndexPaths:insertedPaths withRowAnimation:UITableViewRowAnimationNone];
                                    [weakSelf.tableAccordion reloadSections:[[NSIndexSet alloc] initWithIndex:kConnectSectionTrusted] withRowAnimation:UITableViewRowAnimationNone];
                                    [weakSelf.tableAccordion endUpdates];
                                }
                                [weakSelf.refreshControl endRefreshing];
                            });
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"unable to fetch trusted sources");
                            weakSelf.gotTrustedUsersResult = YES;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf.refreshControl endRefreshing];
                            });

                        }];

}

- (void)fetchInTheKnow {
    __weak ConnectVC *weakSelf = self;
    self.roInTheKnow = [OOAPI getUsersAroundLocation:[LocationManager sharedInstance].currentUserLocation
                                             forUser:[Settings sharedInstance].userObject.userID
                                             success:^(NSArray *users) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     NSMutableArray *deletedPaths = [NSMutableArray array];
                                                     NSUInteger d, i;
                                                     for (d=0; d<[weakSelf.inTheKnowUsersArray count]; d++) {
                                                         [deletedPaths addObject:[NSIndexPath indexPathForRow:d inSection:kConnectSectionInTheKnow]];
                                                     }
                                                     NSMutableArray *insertedPaths = [NSMutableArray array];
                                                     
                                                     for (i=0; i<[users count]; i++) {
                                                         [insertedPaths addObject:[NSIndexPath indexPathForRow:i inSection:kConnectSectionInTheKnow]];
                                                     }
                                                     weakSelf.inTheKnowUsersArray = users;
                                                     weakSelf.gotInTheKnowResult = YES;
                                                     
                                                     NSLog(@"in the know(%lu) deleting=%lu inserting=%lu", (unsigned long)kConnectSectionInTheKnow, (unsigned long)[deletedPaths count], (unsigned long)[insertedPaths count]);
                                                 
                                                     if (_canSeeInTheKnow) {
                                                         [weakSelf.tableAccordion beginUpdates];
                                                         [weakSelf.tableAccordion deleteRowsAtIndexPaths:deletedPaths withRowAnimation:UITableViewRowAnimationNone];
                                                         [weakSelf.tableAccordion insertRowsAtIndexPaths:insertedPaths withRowAnimation:UITableViewRowAnimationNone];
                                                         [weakSelf.tableAccordion reloadSections:[[NSIndexSet alloc] initWithIndex:kConnectSectionInTheKnow] withRowAnimation:UITableViewRowAnimationNone];
                                                         [weakSelf.tableAccordion endUpdates];
                                                     }
                                                     [weakSelf.refreshControl endRefreshing];
                                                 });
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 weakSelf.gotInTheKnowResult = YES;
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [weakSelf.refreshControl endRefreshing];
                                                 });
                                                 NSLog(@"unable to fetch in the know users");
                                             }];
}

//- (void)reloadTableData {
//    dispatch_async(dispatch_get_main_queue(), ^ {
//        [_tableAccordion reloadData];
//        [self.refreshControl endRefreshing];
//    });
//}

- (void)reloadAfterDeterminingWhoWeAreFollowing
{
    [self.roFriends cancel];
    [self.roFoodies cancel];
    [self.roTrustedUsers cancel];
    [self.roInTheKnow cancel];
    self.roFriends = nil;
    self.roFoodies = nil;
    self.roTrustedUsers = nil;
    self.roInTheKnow = nil;
    
    [self fetchUserFriendListFromFacebook];
    [self fetchFoodies];
    [self fetchInTheKnow];
    [self fetchTrustedUsers];
}

- (BOOL)weAreFollowingUser:(NSUInteger)userID
{
    for (UserObject *user in _followeesArray) {
        if (user.userID == userID) {
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    UserObject *u = nil;
    
    if (_searchMode && [_searchBar.text length]) {
        u = _searchResultsArray[row];
    } else {
        switch (section) {
            case kConnectSectionFriends:
                if (row < _friendsArray.count) {
                        u = _friendsArray[row];
                }
                break;
            case kConnectSectionFoodies:
                if (row < _foodiesArray.count) {
                    u = _foodiesArray[row];
                }
                break;
            case kConnectSectionInTheKnow:
                if (row < _inTheKnowUsersArray.count) {
                    u = _inTheKnowUsersArray[row];
                }
                break;
            case kConnectSectionTrusted:
                if (row < _trustedUsersArray.count) {
                    u = _trustedUsersArray[row];
                }
                break;
            default:
                break;
        }
    }
    
    UserListTVC *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kConnectUserCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.delegate = self;
    [cell provideUser:u];
    
    if (self.followeesArray) {
        @synchronized(self.followeesArray) {
            BOOL following = [self weAreFollowingUser:u.userID];
            if ([Settings sharedInstance].userObject.userID == u.userID) {
                cell.buttonFollow.hidden = YES;
            } else {
                [cell showFollowButton:following];
            }
        }
    }
    
    [cell fetchStats];
    cell.vc = self;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if (_searchMode && [_searchBar.text length]) {
        return 1;
    } else {
        return kConnectNumberOfSections;
    }
}

//------------------------------------------------------------------------------
// Name:    viewForHeaderInSection
// Purpose:
//------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_searchMode && [_searchBar.text length]) {
        return nil;
    }
    
    if (section >= _arraySectionHeaderViews.count) {
        return nil;
    }
    
    ConnectTableSectionHeader *view = _arraySectionHeaderViews[section];
    view.delegate = self;
    view.tag = section;
    return view;
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL haveData = NO;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (_searchMode && [_searchBar.text length]) {
        if (row < _foodiesArray.count) {
            haveData = YES;
        }
    } else {
        switch (section) {
            case kConnectSectionFoodies:
                if (row < _foodiesArray.count) {
                    haveData = YES;
                }
                //if (!_canSeeFoodies) return 0;
                break;
            case kConnectSectionFriends:
                if (row < _friendsArray.count) {
                    haveData = YES;
                }
                //if (!_canSeeFriends) return 0;
                break;
            case kConnectSectionInTheKnow:
                if (row < _inTheKnowUsersArray.count) {
                    haveData = YES;
                }
                //if (!_canSeeInTheKnow) return 0;
                break;
            case kConnectSectionTrusted:
                if (row < _trustedUsersArray.count) {
                    haveData = YES;
                }
                //if (!_canSeeTrustedUsers) return 0;
                break;
            default:
                break;
        }
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
// Name:    heightForHeaderInSection
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSInteger count;
    
    if (_searchMode && [_searchBar.text length]) return 0;
    
    ConnectTableSectionHeader *hv = [_arraySectionHeaderViews objectAtIndex:section];
    
    switch (section) {
        case kConnectSectionTrusted:
            if (!_gotTrustedUsersResult) return kGeomConnectScreenHeaderHeight;
            count = [_trustedUsersArray count];
            hv.numberUsers = count;
            if (count) return kGeomConnectScreenHeaderHeight;
            return 100;
            break;
        case kConnectSectionInTheKnow:
            if (!_gotInTheKnowResult) return kGeomConnectScreenHeaderHeight;
            count = [_inTheKnowUsersArray count];
            hv.numberUsers = count;
            if (count) return kGeomConnectScreenHeaderHeight;
            return 100;
            break;
        case kConnectSectionFoodies:
            if (!_gotFoodiesResult) return kGeomConnectScreenHeaderHeight;
            count = [_foodiesArray count];
            hv.numberUsers = count;
            if (count) return kGeomConnectScreenHeaderHeight;
            return 100;
            break;
        case kConnectSectionFriends:
            if (!_gotFriendsResult) return kGeomConnectScreenHeaderHeight;
            count = [_friendsArray count];
            hv.numberUsers = count;
            if (count) return kGeomConnectScreenHeaderHeight;
            return 100;
            break;
            
        default:
            break;
    }
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
    
    if (_searchMode && [_searchBar.text length]) {
        u = [_searchResultsArray objectAtIndex:row];
    } else {
        switch (section) {
            case kConnectSectionFriends:
                if (row<_friendsArray.count) {
                    u = _friendsArray[row];
                }
                break;
            case kConnectSectionFoodies:
                if (row < _foodiesArray.count) {
                    u = _foodiesArray[row];
                }
                break;
            case kConnectSectionInTheKnow:
                if (row < _inTheKnowUsersArray.count) {
                    u = _inTheKnowUsersArray[row];
                }
                break;
            case kConnectSectionTrusted:
                if (row < _trustedUsersArray.count) {
                    u = _trustedUsersArray[row];
                }
                break;
            default:
                break;
        }
    }
    
    if (u) {
        [self goToProfile:u];
    }
}

- (void)goToProfile:(UserObject *)u
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
    if (_searchMode && [_searchBar.text length]) {
        if (section == 0) {
            return [_searchResultsArray count];
        } else {
            return 0;
        }
    } else {
        switch (section) {
            case kConnectSectionFriends:
                //return _suggestedUsersArray.count;
                return _canSeeFriends? _friendsArray.count:0;
                break;
            case kConnectSectionFoodies:
                //return _foodiesArray.count;
                return _canSeeFoodies? _foodiesArray.count:0;
                break;
            case kConnectSectionTrusted:
                //return _trustedUsersArray.count;
                return _canSeeTrustedUsers? _trustedUsersArray.count:0;
                break;
            case kConnectSectionInTheKnow:
                //return _inTheKnowUsersArray.count;
                return _canSeeInTheKnow? _inTheKnowUsersArray.count:0;
                break;
            default:
                break;
        }
    }
    return 0;
}

- (void)userTappedFollowButtonForUser:(UserObject *)user following:(BOOL)following {
    [self updateFollowing];
}

- (void)userTappedSectionHeader:(int)which
{
    switch (which) {
        case kConnectSectionFriends:
            _canSeeFriends = !_canSeeFriends;
            break;
            
        case kConnectSectionFoodies:
            _canSeeFoodies = !_canSeeFoodies;
            break;
            
        case kConnectSectionInTheKnow:
            _canSeeInTheKnow = !_canSeeInTheKnow;
            break;
            
        case kConnectSectionTrusted:
            _canSeeTrustedUsers = !_canSeeTrustedUsers;
            break;
    }
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:which];
    [_tableAccordion reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
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
    __weak ConnectVC *weakSelf= self;
    [SocialMedia fetchUserFriendListFromFacebook:^(NSArray *friends) {
        if (!friends) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf determineWhichFriendsAreNotOOUsers:friends];
        });
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
        [OOAPI getUnfollowedFacebookUsers:array
                                  forUser:[Settings sharedInstance].userObject.userID
                                  success:^(NSArray *users) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          NSMutableArray *deletedPaths = [NSMutableArray array];
                                          NSUInteger d, i;
                                          for (d=0; d<[weakSelf.friendsArray count];d++) {
                                              [deletedPaths addObject:[NSIndexPath indexPathForRow:d inSection:kConnectSectionFriends]];
                                          }
                                          NSMutableArray *insertedPaths = [NSMutableArray array];
                                          
                                          for (i=0; i<[users count]; i++) {
                                              [insertedPaths addObject:[NSIndexPath indexPathForRow:i inSection:kConnectSectionFriends]];
                                          }
                                          weakSelf.friendsArray = users;
                                          weakSelf.gotFriendsResult = YES;
                                          
                                          NSLog(@"friends(%lu) deleting=%lu inserting=%lu", (unsigned long)kConnectSectionFriends, (unsigned long)[deletedPaths count], (unsigned long)[insertedPaths count]);

                                          if (_canSeeFriends) {
                                              [weakSelf.tableAccordion beginUpdates];
                                              [weakSelf.tableAccordion deleteRowsAtIndexPaths:deletedPaths withRowAnimation:UITableViewRowAnimationNone];
                                              [weakSelf.tableAccordion insertRowsAtIndexPaths:insertedPaths withRowAnimation:UITableViewRowAnimationNone];
                                              [weakSelf.tableAccordion reloadSections:[[NSIndexSet alloc] initWithIndex:kConnectSectionFriends] withRowAnimation:UITableViewRowAnimationNone];
                                              [_tableAccordion endUpdates];
                                          }
                                          [weakSelf.refreshControl endRefreshing];
                                      });
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      NSLog (@"FETCH OF NON-FOLLOWEES USING FB IDs FAILED");
                                      weakSelf.gotFriendsResult = YES;
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [weakSelf.refreshControl endRefreshing];
                                      });
                                  }];
    }
}

- (void)presentUnverifiedMessage:(NSString *)message {
    UnverifiedUserVC *vc = [[UnverifiedUserVC alloc] initWithSize:CGSizeMake(250, 200)];
    vc.delegate = self;
    vc.action = message;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.transitioningDelegate = vc;
    self.navigationController.delegate = vc;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:vc animated:YES completion:^{
        }];
    });
}

- (void)unverifiedUserVCDismiss:(UnverifiedUserVC *)unverifiedUserVC {
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

@end

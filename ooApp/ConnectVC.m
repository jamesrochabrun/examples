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

@property (nonatomic, strong) NSArray *suggestedUsersArray; // section 0
@property (nonatomic, strong) NSArray *foodiesArray; // section 1
@property (nonatomic, strong) NSArray *followeesArray; // section 2
@property (nonatomic, strong) NSArray *recentUsersArray; // section 3
@property (nonatomic, strong) NSArray *inTheKnowUsersArray; // section

@property (nonatomic, strong) AFHTTPRequestOperation *roSuggestedUsers; // fb
@property (nonatomic, strong) AFHTTPRequestOperation *roFoodies; // foodies
@property (nonatomic, strong) AFHTTPRequestOperation *roRecentUsers; // users new to Oomami
@property (nonatomic, strong) AFHTTPRequestOperation *roInTheKnow; // users in the know around you

@property (nonatomic, strong) NSArray *arraySectionHeaderViews;
@property (nonatomic, assign) BOOL canSeeFriends, canSeeFoodies, canSeeRecentUsers, canSeeInTheKnow;
@property (nonatomic, assign) BOOL gotFriendsResult, gotFoodiesResult, gotRecentUsersResult, gotInTheKnowResult;
@property (nonatomic) BOOL needRefresh;

@end

@implementation ConnectVC

- (void)dealloc
{
 //   [_suggestedUsersArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationConnectNeedsUpdate object:nil];
    self.suggestedUsersArray = nil;
    self.foodiesArray = nil;
    self.followeesArray = nil;
    self.recentUsersArray = nil;
    self.arraySectionHeaderViews = nil;
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _canSeeFoodies = _canSeeFriends = _canSeeInTheKnow = _canSeeRecentUsers = YES;
    
    _needRefresh = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _suggestedUsersArray = [NSArray new];
    _foodiesArray = [NSArray new];
    _followeesArray = [NSArray new];
    _recentUsersArray = [NSArray new];
    _inTheKnowUsersArray = [NSArray new];
    
    ConnectTableSectionHeader *hvNewestUsers = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeRecentUsers];
    hvNewestUsers.noUsersMessage = @"Recently added users will appear here.";
    hvNewestUsers.labelTitle.text = @"Newest Users";
    
    ConnectTableSectionHeader *hvFriendsToFollow = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeFriends];
    hvFriendsToFollow.noUsersMessage = @"Invite Facebook friends to use Oomami. When they join you'll be able to find out what they like to eat.";
    hvFriendsToFollow.labelTitle.text = @"Friends you can Follow";
    
    ConnectTableSectionHeader *hvTopFoodies = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeFoodies];
    hvTopFoodies.noUsersMessage = @"We'll keep an eye out for foodies you can follow. When you upload a lot of food photos or add to lists you too will become a foodie.";
    hvTopFoodies.labelTitle.text = @"Top Foodies to Follow";
    
    ConnectTableSectionHeader *hvInTheKnow = [[ConnectTableSectionHeader alloc] initWithExpandedFlag:_canSeeInTheKnow];
    hvInTheKnow.noUsersMessage = @"User that know this area will appear here.";
    hvInTheKnow.labelTitle.text = @"In the Know Around You";
    
    _arraySectionHeaderViews= @[hvFriendsToFollow, hvTopFoodies, hvInTheKnow, hvNewestUsers];
    
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
    _tableAccordion.showsVerticalScrollIndicator= NO;
    
    [self setRightNavWithIcon:kFontIconInvite target:self action:@selector(invitePerson:)];
    [self setLeftNavWithIcon:@"" target:nil action:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNeedsRefresh)
                                                 name:kNotificationConnectNeedsUpdate object:nil];
}

- (void)invitePerson:(id)sender {
    UIImage *img = [UIImage imageNamed:@"Oomami_AppStoreLogo(120x120).png"];
    OOActivityItemProvider *aip = [[OOActivityItemProvider alloc] initWithPlaceholderItem:@""];
    aip.restaurant = nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:aip, img, nil];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    avc.popoverPresentationController.sourceView = sender;
    avc.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
    
    [avc setValue:[NSString stringWithFormat:@"Let's try out Oomami together!"] forKey:@"subject"];
    [avc setExcludedActivityTypes:
     @[UIActivityTypeAssignToContact,
       UIActivityTypePostToTwitter,
       UIActivityTypePostToFacebook,
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

- (void)reload
{
    // NOTE: Need to make the call to find out who we are following before anything else is displayed.
    
    _gotFriendsResult =
    _gotFoodiesResult =
    _gotRecentUsersResult =
    _gotInTheKnowResult = NO;
    
    __weak  ConnectVC *weakSelf = self;
    
    UserObject *currentUser = [Settings sharedInstance].userObject;
    [OOAPI getFollowingForUser:currentUser.userID success:^(NSArray *users) {
        weakSelf.followeesArray = users;
        [weakSelf reloadAfterDeterminingWhoWeAreFollowing];
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
                             weakSelf.foodiesArray = users;
                             _gotFoodiesResult = YES;
                             [self reloadSection:kConnectSectionFoodies];
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             _gotFoodiesResult = YES;
                         }
     ];
}

- (void)fetchRecentUsers
{
    __weak ConnectVC *weakSelf = self;
    
    self.roRecentUsers = [OOAPI getRecentUsersSuccess:^(NSArray *users) {
                            weakSelf.recentUsersArray = users;
                            _gotRecentUsersResult = YES;
                            [self reloadSection:kConnectSectionRecentUsers];
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"unable to fetch recent users");
                            _gotRecentUsersResult = YES;
                        }];

}

- (void)fetchInTheKnow {
    __weak ConnectVC *weakSelf = self;
    self.roInTheKnow = [OOAPI getUsersAroundLocation:[LocationManager sharedInstance].currentUserLocation
                                             forUser:[Settings sharedInstance].userObject.userID
                                             success:^(NSArray *users) {
                                                 weakSelf.inTheKnowUsersArray = users;
                                                 _gotInTheKnowResult = YES;
                                                 [self reloadSection:kConnectSectionInTheKnow];
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 _gotInTheKnowResult = YES;
                                                 NSLog(@"unable to fetch in the know users");
                                             }];
}

- (void)reloadSection:(NSUInteger)section {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [_tableAccordion reloadData];
//        [_tableAccordion reloadSections:[[NSIndexSet alloc] initWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.refreshControl endRefreshing];
    });
}

//- (void)reloadTableData {
//    dispatch_async(dispatch_get_main_queue(), ^ {
//        [_tableAccordion reloadData];
//        [self.refreshControl endRefreshing];
//    });
//}

- (void)reloadAfterDeterminingWhoWeAreFollowing
{
    [self.roSuggestedUsers cancel];
    [self.roFoodies cancel];
    [self.roRecentUsers cancel];
    [self.roInTheKnow cancel];
    self.roSuggestedUsers = nil;
    self.roFoodies = nil;
    self.roRecentUsers = nil;
    self.roInTheKnow = nil;
    
    [self fetchUserFriendListFromFacebook];
    [self fetchFoodies];
    [self fetchInTheKnow];
    [self fetchRecentUsers];
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

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    _tableAccordion.frame = self.view.bounds;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    UserObject *u = nil;
    
    switch (section) {
        case kConnectSectionFriends:
            if (row < _suggestedUsersArray.count) {
                    u = _suggestedUsersArray[row];
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
        case kConnectSectionRecentUsers:
            if (row < _recentUsersArray.count) {
                u = _recentUsersArray[row];
            }
            break;
        default:
            break;
    }
    
    UserListTVC *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kConnectUserCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.delegate = self;
    [cell provideUser:u];
    
    BOOL following = [self weAreFollowingUser:u.userID];
    if ([Settings sharedInstance].userObject.userID == u.userID) {
        cell.buttonFollow.hidden = YES;
    } else {
        [cell showFollowButton:following];
    }
    
    [cell fetchStats];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 4;
}

//------------------------------------------------------------------------------
// Name:    viewForHeaderInSection
// Purpose:
//------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section >= _arraySectionHeaderViews.count)
        return nil;
    
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

    switch (section) {
        case kConnectSectionFoodies:
            if (row < _foodiesArray.count) {
                haveData = YES;
            }
            break;
        case kConnectSectionFriends:
            if (row < _suggestedUsersArray.count) {
                haveData = YES;
            }
            break;
        case kConnectSectionInTheKnow:
            if (row < _inTheKnowUsersArray.count) {
                haveData = YES;
            }
            break;
        case kConnectSectionRecentUsers:
            if (row < _recentUsersArray.count) {
                haveData = YES;
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
    NSInteger count;
    ConnectTableSectionHeader *hv = [_arraySectionHeaderViews objectAtIndex:section];
    
    switch (section) {
        case kConnectSectionRecentUsers:
            if (!_gotRecentUsersResult) return kGeomConnectScreenHeaderHeight;
            count = [_recentUsersArray count];
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
            count = [_suggestedUsersArray count];
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
    
    switch (section) {
        case kConnectSectionFriends:
            if (row<_suggestedUsersArray.count) {
                u = _suggestedUsersArray[row];
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
        case kConnectSectionRecentUsers:
            if (row < _recentUsersArray.count) {
                u = _recentUsersArray[row];
            }
            break;
        default:
            break;
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
    switch (section) {
        case kConnectSectionFriends:
//            return _suggestedUsersArray.count;
            return _canSeeFriends? _suggestedUsersArray.count:0;
            break;
        case kConnectSectionFoodies:
//            return _foodiesArray.count;
            return _canSeeFoodies? _foodiesArray.count:0;
            break;
        case kConnectSectionRecentUsers:
//            return _recentUsersArray.count;
            return _canSeeRecentUsers? _recentUsersArray.count:0;
            break;
        case kConnectSectionInTheKnow:
//            return _inTheKnowUsersArray.count;
            return _canSeeInTheKnow? _inTheKnowUsersArray.count:0;
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
            
        case kConnectSectionRecentUsers:
            _canSeeRecentUsers = !_canSeeRecentUsers;
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
//            [weakSelf fetchFoodies];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!friends.count) {
                [weakSelf refreshSuggestedUsersSection];
            }
            [weakSelf determineWhichFriendsAreNotOOUsers:friends];
        });
//        [weakSelf fetchFoodies];
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
                                      weakSelf.suggestedUsersArray = users;
                                      [weakSelf refreshSuggestedUsersSection];
                                      _gotFriendsResult = YES;
                                      [self reloadSection:kConnectSectionFriends];
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      NSLog (@"FETCH OF NON-FOLLOWEES USING FB IDs FAILED");
                                      _gotFriendsResult = YES;
                                      [weakSelf refreshSuggestedUsersSection];
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

- (void)refreshSuggestedUsersSection
{
    // RULE: Don't reload the section unless the foodies are visible.
    if (_canSeeFriends) {
    }
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

@end

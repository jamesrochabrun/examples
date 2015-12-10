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

#define CONNECT_TABLE_REUSE_IDENTIFIER  @"connectTableCell"
#define CONNECT_TABLE_REUSE_IDENTIFIER_EMPTY  @"connectTableCellEmpty"

//==============================================================================

@interface ConnectTableSectionHeader ()
@property (nonatomic,strong) UILabel *labelExpander;
@end

@implementation ConnectTableSectionHeader

- (instancetype) init
{
    self=[super init];
    if (self) {
        _labelTitle=makeLabelLeft (self, nil, kGeomFontSizeStripHeader);
        _labelTitle.textColor=WHITE;
        _labelExpander=makeIconLabel(self, kFontIconBack, kGeomIconSize);
        _labelExpander.textColor= UIColorRGBA(kColorYellow);
        self.backgroundColor=GRAY;
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

@interface ConnectTableCell ()
@property (nonatomic,strong) UILabel *labelFollowers;
@property (nonatomic,strong) UILabel *labelFollowing;
@property (nonatomic,strong) UILabel *labelLists;
@property (nonatomic,strong) OOUserView *userView;
@property (nonatomic,strong) UILabel *labelUserName;
@property (nonatomic,strong) UILabel *labelName;
@property (nonatomic,strong) UserObject *userInfo;
@property (nonatomic,strong) AFHTTPRequestOperation* op;
@property (nonatomic, strong) UIButton *buttonFollow;
@end

@implementation ConnectTableCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        _userView=[[OOUserView alloc]init];
        [self  addSubview: _userView];
        _userView.delegate=self;
        
        _labelFollowers= makeLabel(self, @"@", kGeomFontSizeSubheader);
        _labelFollowing= makeLabel(self, @"@", kGeomFontSizeSubheader);
        _labelLists= makeLabel(self, @"@", kGeomFontSizeSubheader);
        
        _labelUserName= makeLabelLeft (self, @"@username", kGeomFontSizeHeader);
        _labelName= makeLabelLeft (self, @"Name ", kGeomFontSizeSubheader);
        _labelFollowers.textColor=WHITE;
        _labelFollowing.textColor=WHITE;
        _labelLists.textColor=WHITE;
        _labelUserName.textColor=WHITE;
        _labelName.textColor=WHITE;
        
        _labelLists.alpha=0;
        _labelFollowers.alpha=0;
        _labelFollowing.alpha=0;
        
        _labelLists.textAlignment=NSTextAlignmentLeft;
        _labelFollowers.textAlignment=NSTextAlignmentCenter;
        _labelFollowing.textAlignment=NSTextAlignmentRight;
        
        self.buttonFollow= makeButton(self, @"FOLLOW",
                                      kGeomFontSizeSubheader, UIColorRGBA(kColorWhite), CLEAR,
                                      self,
                                      @selector (userPressedFollow:), 1);
        [_buttonFollow setTitle:@"FOLLOWING" forState:UIControlStateSelected];
        _buttonFollow.hidden= YES;
    }
    return self;
}

//------------------------------------------------------------------------------
// Name:    userPressedFollow
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedFollow:(id)sender
{
    __weak ConnectTableCell *weakSelf = self;
    [OOAPI setFollowingUser:_userInfo
                         to: !weakSelf.buttonFollow.selected
                    success:^(id responseObject) {
                        weakSelf.buttonFollow.selected= !weakSelf.buttonFollow.selected;
                        if (weakSelf.buttonFollow.selected ) {
                            NSLog (@"SUCCESSFULLY FOLLOWED USER");
                        } else {
                            NSLog (@"SUCCESSFULLY UNFOLLOWED USER");
                        }
                        [weakSelf.delegate userTappedFollowButtonForUser: weakSelf.userInfo];

                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                        NSLog (@"FAILED TO FOLLOW/UNFOLLOW USER");
                    }];
}

- (void) showFollowButton: (BOOL)following
{
    _buttonFollow.hidden= NO;
    _buttonFollow.selected=  following;
}

- (void)commenceFetchingStats
{
    __weak ConnectTableCell *weakSelf = self;
    NSUInteger userid=self.userInfo.userID;

    self.op= [OOAPI getStatsForUser: userid
                       success:^(NSDictionary *dictionary) {
                           NSUInteger  identifier=  parseUnsignedIntegerOrNullFromServer(dictionary[ @"user_id"]);
                           if  (!identifier || identifier== userid) {
                               NSUInteger restaurantCount=parseUnsignedIntegerOrNullFromServer( dictionary[ @"restaurant_count"]);
                               NSUInteger nLists=parseUnsignedIntegerOrNullFromServer([dictionary objectForKey:@"list_count"]);
                               NSUInteger nFollowers=parseUnsignedIntegerOrNullFromServer([dictionary objectForKey:@"follower_count"]);
                               NSUInteger nFollowees=parseUnsignedIntegerOrNullFromServer([dictionary objectForKey:@"followee_count"]);
                               NSArray*parameters=@[
                                                    @(nLists),@(nFollowers),@(nFollowees),@(restaurantCount)
                                                    ];
                               
                               ON_MAIN_THREAD(^{
                                   [weakSelf provideStats:  parameters
                                    ];
                               });
                           }
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog (@"UNABLE TO GET STATS %@",error);
                       }
              ];
}

- (void) oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user
{
    [self.delegate userTappedImageOfUser: user];
}

- (void) provideUser: (UserObject*) user;
{
    if(!user)
        return;
    
    self.userInfo=user;
    
    [_userView setUser: user];
    
    NSString *string= user.username ? [NSString stringWithFormat:@"@%@",user.username] : @"Unknown";
    _labelUserName.text= string;
    
    _labelName.text=[NSString stringWithFormat:@"%@ %@",
                     user.firstName ?: @"First",
                     user.lastName ?: @"Last"];
}

- (void)prepareForReuse
{
//    [_op cancel];
    _labelUserName.text=nil;
    _labelName.text=nil;
    
    _labelLists.alpha=0;
    _labelFollowers.alpha=0;
    _labelFollowing.alpha=0;
    
    [_labelLists setText:  @""];
    [_labelFollowers setText:  @""];
    [_labelFollowing setText:  @""];
   
    _buttonFollow.hidden= YES;
}

- (void) provideStats: (NSArray*) values
{
    if (values.count!=4)
        return;
    
    NSNumber* numberLists=values[0];
    NSNumber* numberFollowers=values[1];
    NSNumber* numberFollowing=values[2];
    NSNumber* numberRestaurantCount=values[3];
    NSInteger lists= numberLists.integerValue;
    NSInteger followers= numberFollowers.integerValue;
    NSInteger following= numberFollowing.integerValue;
    NSInteger restaurantCount= numberRestaurantCount.integerValue;
    if  (lists ==1 ) {
        [_labelLists setText: [NSString stringWithFormat:@"1 list"  ]];
    } else {
        [_labelLists setText: [NSString stringWithFormat:@"%lu lists",  lists ]];
    }
    
    if  (followers==1 ) {
        [_labelFollowers setText: [NSString stringWithFormat:@"1 follower"   ]];
    } else {
        [_labelFollowers setText: [NSString stringWithFormat:@"%lu followers",followers ]];
    }
    
    if  (following==1 ) {
        [_labelFollowing setText: [NSString stringWithFormat:@"1 following"   ]];
    } else {
        [_labelFollowing setText: [NSString stringWithFormat:@"%lu following",following ]];
    }
    
    //    [_labelRestaurantCount setText: [NSString stringWithFormat:@"%@ following",values[3]  ]];
    
    _labelLists.textColor=WHITE;
    _labelFollowers.textColor=WHITE;
    _labelFollowing.textColor=WHITE;
    
    NSLog  (@" following %@",NSStringFromCGSize(_labelFollowing.frame.size));
    
    __weak ConnectTableCell *weakSelf = self;
    [UIView animateWithDuration:.4 animations:^{
        weakSelf.labelLists.alpha=1;
        weakSelf.labelFollowers.alpha=1;
        weakSelf.labelFollowing.alpha=1;
    }];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    const float kGeomConnectCellMiddleGap= 7;
    
    float w=self.frame.size.width;
    float h=self.frame.size.height;
    const float margin=kGeomSpaceEdge;
    const float spacing=kGeomSpaceInter;
    float imageSize=kGeomConnectScreenUserImageHeight;
    _userView.frame=CGRectMake(margin, margin, imageSize, imageSize);
    
    _buttonFollow.frame = CGRectMake(w-margin-kGeomButtonWidth, margin,kGeomButtonWidth, kGeomHeightButton);
    
    float x=margin+imageSize+kGeomConnectCellMiddleGap;
    float y=margin;
    float remainingWidth=w-margin-x;
    float labelHeight=_labelUserName.intrinsicContentSize.height;
    if  ( labelHeight<1) {
        labelHeight= kGeomHeightButton;
    }
    _labelUserName.frame=CGRectMake(x, y, remainingWidth, labelHeight);
    y +=  labelHeight+ spacing;
    labelHeight=_labelName.intrinsicContentSize.height;
    if  ( labelHeight<1) {
        labelHeight= kGeomHeightButton;
    }
    _labelName.frame=CGRectMake(x, y, remainingWidth, labelHeight);
    
    labelHeight= 20;
    y = _userView.frame.size.height + _userView.frame.origin.y - labelHeight;
    if (remainingWidth>414)
        remainingWidth=414; // So it looks non-ridiculous on the iPad.
    
    int leftLabelWidth = (int) remainingWidth/4;
    int rightLabelWidth = (int) 3*remainingWidth/8;
    _labelLists.frame=CGRectMake(x, y, leftLabelWidth, labelHeight);
    x += leftLabelWidth;
    _labelFollowers.frame=CGRectMake(x, y, rightLabelWidth, labelHeight);
    x += rightLabelWidth;
    _labelFollowing.frame=CGRectMake(x, y, rightLabelWidth, labelHeight);
    x += rightLabelWidth;
    
    [_userView layoutIfNeeded];
}

@end

//==============================================================================
@interface ConnectVC ()
@property (nonatomic,strong) UITableView *tableAccordion;

@property (nonatomic,strong) NSMutableArray *suggestedUsersArray; // section 0
@property (nonatomic,strong) NSMutableArray *foodiesArray; // section 1
@property (nonatomic,strong) NSMutableArray *followeesArray; // section 2
@property (nonatomic,strong) NSMutableArray *followersArray; // section 3

@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection1; // fb
@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection2; // foodies
@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection3; // users who follow you
@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection4; // users you're following

@property (nonatomic,strong) NSArray *arraySectionHeaderViews;
@property (nonatomic,assign) BOOL canSeeSection1Items,
                                canSeeSection2Items,
                                canSeeSection3Items,
                                canSeeSection4Items
;

@end

@implementation ConnectVC

- (void)dealloc
{
    [_suggestedUsersArray removeAllObjects];
    [_foodiesArray removeAllObjects];
    [_followeesArray removeAllObjects];
    self.suggestedUsersArray=nil;
    self.foodiesArray=nil;
    self.followeesArray=nil;
    self.arraySectionHeaderViews=nil;
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.canSeeSection1Items=YES;
    self.canSeeSection2Items=YES;
    self.canSeeSection3Items=YES;
    self.canSeeSection4Items= YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _suggestedUsersArray = [NSMutableArray new];
    _foodiesArray = [NSMutableArray new];
    _followeesArray = [NSMutableArray new];
    _followersArray = [NSMutableArray new];
    
    ConnectTableSectionHeader *headerView1 = [[ConnectTableSectionHeader alloc] init];
    ConnectTableSectionHeader *headerView2 = [[ConnectTableSectionHeader alloc] init];
    ConnectTableSectionHeader *headerView3 = [[ConnectTableSectionHeader alloc] init];
    ConnectTableSectionHeader *headerView4 = [[ConnectTableSectionHeader alloc] init];
    
    headerView1.backgroundColor=UIColorRGB(kColorOffBlack);
    headerView1.labelTitle.text=@"Suggested Users";
    
    headerView2.backgroundColor=UIColorRGB(kColorOffBlack);
    headerView2.labelTitle.text=@"Foodies";
    
    headerView4.backgroundColor=UIColorRGB(kColorOffBlack);
    headerView4.labelTitle.text=@"Users You Follow";
    
    headerView3.backgroundColor=UIColorRGB(kColorOffBlack);
    headerView3.labelTitle.text=@"Users Who Follow You";
    
    _arraySectionHeaderViews= @[
                                headerView1, headerView2, headerView3, headerView4
                                ];
    
    NavTitleObject *nto;
    nto = [[NavTitleObject alloc]
           initWithHeader:LOCAL(@"Connect")
           subHeader: LOCAL(@"find your foodies")];
    
    self.navTitle = nto;
    
    self.tableAccordion = makeTable(self.view,self);
    _tableAccordion.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_tableAccordion registerClass:[ConnectTableCell class] forCellReuseIdentifier:CONNECT_TABLE_REUSE_IDENTIFIER];
    [_tableAccordion registerClass:[UITableViewCell class] forCellReuseIdentifier:CONNECT_TABLE_REUSE_IDENTIFIER_EMPTY];
    
    _tableAccordion.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)fetchFollowers
{
    __weak ConnectVC *weakSelf = self;
    UserObject* currentUser= [Settings sharedInstance].userObject;
    
    self.fetchOperationSection4 =
    [OOAPI getFollowersOf:currentUser.userID
                  success: ^(NSArray *users) {
                      @synchronized(weakSelf.followersArray)  {
                          weakSelf.followersArray= users.mutableCopy;
                          NSLog  (@"SUCCESS IN FETCHING %lu FOLLOWERS",
                                  ( unsigned long)weakSelf.followersArray.count);
                      }
                      if (weakSelf.canSeeSection4Items) {
                          // RULE: Don't reload the section unless the followers users are visible.
                          ON_MAIN_THREAD(^() {
                              [weakSelf.tableAccordion reloadData];
                          });
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog  (@"UNABLE TO FETCH FOLLOWERS");
                  }     ];
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
                                     [weakSelf.tableAccordion reloadData];
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
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
    [ self reload];
}

- (void)reload
{
    // NOTE: Need to make the call to find out who we are following before anything else is displayed.
    
    __weak  ConnectVC *weakSelf = self;
    [OOAPI getFollowingWithSuccess:^(NSArray *users) {
        @synchronized(weakSelf.followeesArray)  {
            weakSelf.followeesArray= users.mutableCopy;
            NSLog  (@"SUCCESS IN FETCHING %lu FOLLOWEES",
                    ( unsigned long)weakSelf.followeesArray.count);
        }
        if (weakSelf.canSeeSection4Items) {
            // RULE: Don't reload the section unless the followees users are visible.
            ON_MAIN_THREAD(^() {
                [weakSelf.tableAccordion reloadData];
            });
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
    [self.fetchOperationSection3 cancel];
    self.fetchOperationSection1= nil;
    self.fetchOperationSection2= nil;
    self.fetchOperationSection3= nil;
    
    [self fetchUserFriendListFromFacebook];
    [self fetchFoodies];
    [self fetchFollowers];
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
    NSInteger row=indexPath.row;
    NSInteger section=indexPath.section;
    UserObject*u=nil;
    
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
            
        case 2:
            @synchronized(self.followersArray)  {
                if ( row<_followersArray.count) {
                    u=_followersArray[row];
                }
            }
            break;
            
        case 3:
            @synchronized(self.followeesArray)  {
                if ( row<_followeesArray.count) {
                    u=_followeesArray[row];
                }
            }
            break;
            
        default:
            break;
    }
    
    if (!u) {
        UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:CONNECT_TABLE_REUSE_IDENTIFIER_EMPTY forIndexPath:indexPath];
        cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.text=  @"Alas there are none.";
        cell.textLabel.textColor=WHITE;
        cell.selectionStyle= UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    ConnectTableCell *cell;
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
    
    [cell commenceFetchingStats];
    
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
    NSInteger row=indexPath.row;
    NSInteger section=indexPath.section;
    UserObject*u=nil;
    
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
        case 2:
            @synchronized(self.followersArray)  {
                if ( row<_followersArray.count) {
                    u=_followersArray[row];
                }
            }
            break;
        case 3:
            @synchronized(self.followeesArray)  {
                if ( row<_followeesArray.count) {
                    u=_followeesArray[row];
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
    ProfileVC* vc= [[ProfileVC alloc] init];
    vc.userInfo= u;
    vc.userID= u.userID;
    [self.navigationController  pushViewController:vc animated:YES];
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
                return _canSeeSection1Items? MAX(1,_suggestedUsersArray.count): 0;
            }
            break;
        case 1:
            @synchronized(self.foodiesArray)  {
                return _canSeeSection2Items? MAX(1,_foodiesArray.count): 0;
            }
            break;
        case 2:
            @synchronized(self.followersArray)  {
                return _canSeeSection3Items? MAX(1,_followersArray.count): 0;
            }
            break;
        case 3:
            @synchronized(self.followeesArray)  {
                return _canSeeSection4Items? MAX(1,_followeesArray.count): 0;
            }
            break;
            
        default:
            break;
    }
    return 0;
}

- (void)userTappedFollowButtonForUser:(UserObject*)user
{
    [self reload];
}

- (void)userTappedSectionHeader:(int)which
{
    switch ( which) {
        case 0:
            _canSeeSection1Items= !_canSeeSection1Items;
            break;
            
        case 1:
            _canSeeSection2Items= !_canSeeSection2Items;
            break;
            
        case 2:
            _canSeeSection3Items= !_canSeeSection3Items;
            break;
        case 3:
            _canSeeSection4Items= !_canSeeSection4Items;
            break;
    }
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:  which];
    [_tableAccordion reloadSections:indexSet withRowAnimation: UITableViewRowAnimationAutomatic];
}

- (void) userTappedImageOfUser:(UserObject*)user;
{
    [self goToProfile:user];
}

//------------------------------------------------------------------------------
// Name:    fetchUserFriendListFromFacebook
// Purpose:
//------------------------------------------------------------------------------
- (void) fetchUserFriendListFromFacebook
{
    ENTRY;
    
    //---------------------------------------------
    //  Make a formal request for user information.
    //
    __weak ConnectVC *weakSelf= self;
    NSMutableString *facebookRequest = [NSMutableString new];
    [facebookRequest appendString:@"/me/friends?fields=id,name,email&limit=200"];
//    [facebookRequest appendString:@"?limit=200"];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:facebookRequest
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection,
                                           id result, NSError *error) {
        if (error) {
            NSLog (@"FACEBOOK ERR %@",error);
            return;
        }
        if (![result isKindOfClass: [NSDictionary class] ] ) {
            NSLog (@"FACEBOOK RESULT NOT ARY");
            return;
        }
        NSArray *arrayData= ((NSDictionary*)result) [@"data"];
        if ([arrayData isKindOfClass: [NSArray  class] ] ) {
            [weakSelf.suggestedUsersArray removeAllObjects];
            NSUInteger  total= arrayData.count;
            if  (!total) {
                NSLog  (@"SUCCESSFULLY FOUND ZERO FRIENDS; BUT THAT'S OKAY");
                ON_MAIN_THREAD(^{
                    [weakSelf refreshSuggestedUsersSection ];
                });
            } else {
                NSMutableArray* facebookIDs = [NSMutableArray new];
                for (id object in arrayData) {
                    if ([object isKindOfClass: [NSDictionary  class] ] ) {
                        
                        NSDictionary*d= (NSDictionary*)object;
                        
                        NSString *identifier= d[ @"id"];
                        NSString *name= d[ @"name"];
                        
                        NSLog (@"FOUND FRIEND %@: id=%@", name,  identifier);
                        if  (identifier ) {
                            [facebookIDs  addObject: identifier];
                        }
                    }
                }
                
                [weakSelf determineWhichFriendsAreNotOOUsers:facebookIDs];
            }
        }
        
    }
     ];
}

- (void) determineWhichFriendsAreNotOOUsers: (NSMutableArray*) array
{
    if  (!array || ! array.count) {
        return;
    }
    
    NSString*string=  [array firstObject];
    __weak ConnectVC *weakSelf= self;

    if  ([string containsString:@"@"  ]) {
//        //  old code, not used
//        [OOAPI getUsersTheCurrentUserIsNotFollowingUsingEmails:  array
//                                                       success:^(NSArray *users) {
//                                                           @synchronized(weakSelf.suggestedUsersArray)  {
//                                                               weakSelf.suggestedUsersArray=users.mutableCopy;
//                                                           }
//                                                           ON_MAIN_THREAD(^{
//                                                               [weakSelf refreshSuggestedUsersSection];
//                                                           });
//                                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                                           NSLog (@"FETCH OF NON-FOLLOWEES USING EMAILS FAILED");
//                                                       }];
    } else {
        [OOAPI getUsersTheCurrentUserIsNotFollowingUsingFacebookIDs:  array
                                                       success:^(NSArray *users) {
                                                           @synchronized(weakSelf.suggestedUsersArray)  {
                                                               weakSelf.suggestedUsersArray=users.mutableCopy;
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
    if (self.canSeeSection2Items) {
        [self.tableAccordion reloadData];
    }
}

@end

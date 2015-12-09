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
        _labelExpander.textColor=WHITE;
        self.backgroundColor=GRAY;
    }
    return self;
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.delegate userTappedSectionHeader:self.tag];
    
    _isExpanded=!_isExpanded;
    
    [UIView animateWithDuration:.4
                     animations:^{
                         [self layoutSubviews];
                     }];
}

- (void)layoutSubviews
{
    float w=self.frame.size.width;
    float h=self.frame.size.height;
    const float kGeomConnectHeaderLeftMargin=29;
    const float kGeomConnectHeaderRightMargin=24;
    self.labelTitle.frame = CGRectMake(kGeomConnectHeaderLeftMargin,0,w/2,h);
    [self.labelExpander sizeToFit];
    float labelWidth= h;
    self.labelExpander.frame = CGRectMake(w-kGeomConnectHeaderRightMargin-labelWidth,0
                                          ,labelWidth,h);
    double angle = _isExpanded ? M_PI/2 : 3*M_PI/2;
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
@property (nonatomic,strong) NSBlockOperation* op;
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
    }
    return self;
}

- (void)commenceFetchingStats
{
    __weak ConnectTableCell *weakSelf = self;
    NSUInteger userid=self.userInfo.userID;
    NSOperationQueue *q=[self.delegate requireOperationQ];
    if  (!q) {
        return;
    }
    self.op= [NSBlockOperation blockOperationWithBlock:^{
        [OOAPI getStatsForUser: userid
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
        
    }];
    [q addOperation: _op];
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
    [_op cancel];
    _labelUserName.text=nil;
    _labelName.text=nil;
    
    _labelLists.alpha=0;
    _labelFollowers.alpha=0;
    _labelFollowing.alpha=0;
    
    [_labelLists setText:  @""];
    [_labelFollowers setText:  @""];
    [_labelFollowing setText:  @""];
    
}

- (void) provideStats: (NSArray*) values
{
    if (values.count!=4)
        return;
    
    [_labelLists setText: [NSString stringWithFormat:@"%@ lists",values[0]  ]];
    [_labelFollowers setText: [NSString stringWithFormat:@"%@ followers",values[1]  ]];
    [_labelFollowing setText: [NSString stringWithFormat:@"%@ following",values[2]  ]];
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
    const float kGeomConnectCellMiddleGap= 7;
    
    float w=self.frame.size.width;
    float h=self.frame.size.height;
    const float margin=kGeomSpaceEdge;
    const float spacing=kGeomSpaceInter;
    float imageSize=h-2*margin;
    _userView.frame=CGRectMake(margin, margin, imageSize, imageSize);
    
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
    labelHeight=_labelFollowers.intrinsicContentSize.height;
    if  ( labelHeight<1) {
        labelHeight= kGeomHeightButton;
    }
    y = h-labelHeight-margin;
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
}

@end

//==============================================================================
@interface ConnectVC ()
@property (nonatomic,strong) UITableView *tableAccordion;

@property (nonatomic,strong) NSMutableArray *suggestedUsersArray; // section 0
@property (nonatomic,strong) NSMutableArray *foodiesArray; // section 1
@property (nonatomic,strong) NSMutableArray *followeesArray; // section 2

@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection1;
@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection2;
@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection3;
@property (nonatomic,strong) NSArray *arraySectionHeaderViews;
@property (nonatomic,assign) BOOL canSeeSection1Items, canSeeSection2Items, canSeeSection3Items;

@property (nonatomic,strong) NSOperationQueue *queueForStats;

@end

@implementation ConnectVC

- (void)dealloc
{
    [_queueForStats  cancelAllOperations];
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
    
    self.queueForStats=[[NSOperationQueue alloc] init];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _suggestedUsersArray = [NSMutableArray new];
    _foodiesArray = [NSMutableArray new];
    _followeesArray = [NSMutableArray new];
    
    ConnectTableSectionHeader *headerView1 = [[ConnectTableSectionHeader alloc] init];
    ConnectTableSectionHeader *headerView2 = [[ConnectTableSectionHeader alloc] init];
    ConnectTableSectionHeader *headerView3 = [[ConnectTableSectionHeader alloc] init];
    
    headerView1.backgroundColor=UIColorRGB(kColorOffBlack);
    headerView1.labelTitle.text=@"Suggested Users";
    
    headerView2.backgroundColor=UIColorRGB(kColorOffBlack);
    headerView2.labelTitle.text=@"Foodies";
    
    headerView3.backgroundColor=UIColorRGB(kColorOffBlack);
    headerView3.labelTitle.text=@"Users You Follow";
    
    _arraySectionHeaderViews= @[
                                headerView1, headerView2, headerView3
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

- (void)fetchFollowees
{
    __weak ConnectVC *weakSelf = self;
    
    self.fetchOperationSection1 =
    [OOAPI getFollowingWithSuccess:^(NSArray *users) {
        @synchronized(weakSelf.suggestedUsersArray)  {
            weakSelf.followeesArray= users.mutableCopy;
            NSLog  (@"SUCCESS IN FETCHING %lu FOLLOWEES",
                    ( unsigned long)weakSelf.followeesArray.count);
        }
        if (weakSelf.canSeeSection1Items) {
            // RULE: Don't reload the section unless the suggested users are visible.
            ON_MAIN_THREAD(^() {
                [weakSelf.tableAccordion reloadData];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog  (@"UNABLE TO FETCH FOLLOWEES");
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
    
    [self fetchUserFriendListFromFacebook];
    [self fetchFoodies];
    [self fetchFollowees];
}

//------------------------------------------------------------------------------
// Name:    viewWillDisappear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [_queueForStats  cancelAllOperations];
    
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
    
    [cell commenceFetchingStats];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 3;
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
            @synchronized(self.followeesArray)  {
                return _canSeeSection3Items? MAX(1,_followeesArray.count): 0;
            }
            break;
        default:
            break;
    }
    return 0;
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
    }
    
    [_tableAccordion beginUpdates];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:  which];
    [_tableAccordion reloadSections:indexSet withRowAnimation: UITableViewRowAnimationAutomatic];
    [_tableAccordion endUpdates];
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
    [facebookRequest appendString:@"/me/friends"];
    [facebookRequest appendString:@"?limit=200"];
    
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
        NSUInteger  total= arrayData.count;
        if  (!total) {
            NSLog  (@"SUCCESSFULLY FOUND ZERO FRIENDS; BUT THAT'S OKAY");
            [weakSelf.suggestedUsersArray removeAllObjects];
            ON_MAIN_THREAD(^{
                [weakSelf refreshSuggestedUsersSection ];
            });
        } else {
            NSMutableArray* emailAddresses= [NSMutableArray new];
            for (id object in arrayData) {
                if ([object isKindOfClass: [NSDictionary  class] ] ) {
                    
                    NSDictionary*d= (NSDictionary*)object;
                    
                    NSString *firstName= d[ @"first_name"];
                    //                    NSString *lastName= d [ @"last_name"];
                    //                    NSString *middleName= d [ @"middle_name"];
                    //                    NSString *gender= d [ @"gender"];
                    NSString *email= d [ @"email"];
                    //                    NSString *birthday= d [ @"birthday"];
                    //                    NSString *location= d [ @"location"];
                    //                    NSString *about= d [ @"about"];
                    
                    NSLog (@"FOUND FRIEND %@:  %@", firstName, email);
                    
                    [emailAddresses addObject: email];
                }
            }
            
            [self determineWhichFriendsAreNotOOUsers:emailAddresses];
        }
        
    }
     ];
}

- (void) determineWhichFriendsAreNotOOUsers: (NSMutableArray*) arrayOfEmailAddresses
{
    __weak ConnectVC *weakSelf= self;
    [OOAPI getUsersTheCurrentUserIsNotFollowingUsingEmails:arrayOfEmailAddresses
                                                   success:^(NSArray *users) {
                                                       @synchronized(weakSelf.suggestedUsersArray)  {
                                                           weakSelf.suggestedUsersArray=users.mutableCopy;
                                                       }
                                                       ON_MAIN_THREAD(^{
                                                           [weakSelf refreshSuggestedUsersSection];
                                                       });
                                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                       NSLog (@"");
                                                   }];
}

- (NSOperationQueue*) requireOperationQ;
{
    return self.queueForStats;
}

- (void)refreshSuggestedUsersSection
{
    // RULE: Don't reload the section unless the foodies are visible.
    if (self.canSeeSection2Items) {
        [self.tableAccordion reloadData];
    }
}

@end

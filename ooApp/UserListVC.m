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

#define USER_LIST_TABLE_REUSE_IDENTIFIER  @"userListTableCell"
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
    //    [self.delegate userTappedSectionHeader:( int)self.tag];
    //
    //    _isExpanded=!_isExpanded;
    //
    //    [UIView animateWithDuration:.4
    //                     animations:^{
    //                         [self layoutSubviews];
    //                     }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float w=self.frame.size.width;
    float h=self.frame.size.height;
    const float kGeomUserListVCHeaderLeftMargin=29;
    const float kGeomUserListVCHeaderRightMargin=24;
    self.labelTitle.frame = CGRectMake(kGeomUserListVCHeaderLeftMargin,0,w/2,h);
    [self.labelExpander sizeToFit];
    float labelWidth= h;
    self.labelExpander.frame = CGRectMake(w-kGeomUserListVCHeaderRightMargin-labelWidth,0
                                          ,labelWidth,h);
    double angle = _isExpanded ? 3*M_PI/2 : M_PI/2;
    _labelExpander.layer.transform=CATransform3DMakeRotation(angle, 0, 0, 1);
}

@end

//==============================================================================

@interface UserListTableCell ()

@property (nonatomic,strong) UILabel *labelFollowers;
@property (nonatomic,strong) UILabel *labelFollowing;
@property (nonatomic,strong) UILabel *labelPlaces;
@property (nonatomic,strong) UILabel *labelPhotos;

@property (nonatomic,strong) UILabel *labelFollowersNumber;
@property (nonatomic,strong) UILabel *labelFollowingNumber;
@property (nonatomic,strong) UILabel *labelPlacesNumber;
@property (nonatomic,strong) UILabel *labelPhotosNumber;

@property (nonatomic,strong) OOUserView *userView;
@property (nonatomic,strong) UILabel *labelUserName;
@property (nonatomic,strong) UILabel *labelName;
@property (nonatomic,strong) UserObject *userInfo;
@property (nonatomic,strong) AFHTTPRequestOperation* op;
@property (nonatomic, strong) UIButton *buttonFollow;
@end

@implementation UserListTableCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        _userView=[[OOUserView alloc]init];
        [self  addSubview: _userView];
        _userView.delegate=self;
        self.autoresizesSubviews= NO;
        [self setSeparatorInset:UIEdgeInsetsZero];
        
        self.backgroundColor=  UIColorRGB(kColorOffBlack);
        
        _labelFollowers= makeLabel(self,nil, kGeomFontSizeDetail);
        _labelFollowing= makeLabel(self, nil, kGeomFontSizeDetail);
        _labelPhotos=  makeIconLabel(self, kFontIconPhoto, kGeomIconSizeSmall);
        _labelPlaces=makeLabel( self, nil, kGeomFontSizeDetail);
        
        _labelFollowers.textColor= MIDDLEGRAY;
        _labelFollowing.textColor= MIDDLEGRAY;
        _labelPhotos.textColor= MIDDLEGRAY;
        _labelPlaces.textColor= MIDDLEGRAY;
        
        _labelFollowersNumber= makeLabel(self, @"", kGeomFontSizeSubheader);
        _labelFollowingNumber= makeLabel(self,  @"", kGeomFontSizeSubheader);
        _labelPhotosNumber= makeLabelLeft(self,  @"", kGeomFontSizeSubheader);
        _labelPlacesNumber=makeLabel( self,  @"", kGeomFontSizeSubheader);
        
        _labelFollowersNumber.textColor= WHITE;
        _labelFollowingNumber.textColor= WHITE;
        _labelPhotosNumber.textColor= WHITE;
        _labelPlacesNumber.textColor= WHITE;
        
        _labelUserName= makeLabelLeft (self, @"@username", kGeomFontSizeHeader);
        _labelName= makeLabelLeft (self, @"Name ", kGeomFontSizeSubheader);
        
        _labelUserName.textColor=WHITE;
        _labelName.textColor=WHITE;
        
        _labelFollowers.alpha=0;
        _labelFollowing.alpha=0;
        _labelPhotos.alpha=0;
        _labelPlaces.alpha=0;
        _labelFollowersNumber.alpha=0;
        _labelFollowingNumber.alpha=0;
        _labelPhotosNumber.alpha=0;
        _labelPlacesNumber.alpha=0;
        
        _buttonFollow = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonFollow withText:@"FOLLOW" fontSize:kGeomFontSizeSubheader width:40 height:40 backgroundColor:kColorClear textColor:kColorYellow borderColor:kColorYellow target:self
                       selector:@selector (userPressedFollow:)];
        [_buttonFollow setTitle:@"FOLLOWING" forState:UIControlStateSelected];
        _buttonFollow.hidden= YES;
        [self addSubview:_buttonFollow];
    }
    return self;
}

//------------------------------------------------------------------------------
// Name:    userPressedFollow
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedFollow:(id)sender
{
    __weak UserListTableCell *weakSelf = self;
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

- (void)showFollowButton:(BOOL)following
{
    _buttonFollow.hidden = NO;
    _buttonFollow.selected = following;
}

- (void)commenceFetchingStats
{
    __weak UserListTableCell *weakSelf = self;
    NSUInteger userid = self.userInfo.userID;
    [OOAPI getUserStatsFor:userid success:^(UserStatsObject *object) {
        ON_MAIN_THREAD(^{
            [weakSelf provideStats:object];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog  (@"STATS ERROR %@",error);
    }
     ];
    
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user
{
    [self.delegate userTappedImageOfUser:user];
}

- (void)provideUser:(UserObject *)user;
{
    if (!user) return;
    
    self.userInfo = user;
    
    [_userView setUser:user];
    
    NSString *string= user.username ? [NSString stringWithFormat:@"@%@",user.username] : @"Unknown";
    _labelUserName.text = string;
    
    _labelName.text = [NSString stringWithFormat:@"%@ %@",
                       user.firstName ? : @"First",
                       user.lastName ? : @"Last"];
}

- (void)prepareForReuse
{
    //    [_op cancel];
    _labelUserName.text=nil;
    _labelName.text=nil;
    
    [_userView clear];
    
    //    _labelLists.alpha=0;
    
    _labelFollowers.alpha = 0;
    _labelFollowing.alpha = 0;
    _labelPlaces.alpha = 0;
    _labelPhotos.alpha = 0;
    _labelFollowersNumber.alpha = 0;
    _labelFollowingNumber.alpha = 0;
    _labelPlacesNumber.alpha = 0;
    _labelPhotosNumber.alpha = 0;
    
    //    [_labelLists setText:  @""];
    [_labelPlaces setText:@""];
    [_labelFollowers setText:@""];
    [_labelFollowing setText:@""];
    [_labelPlacesNumber setText:@""];
    [_labelPhotosNumber setText:@""];
    [_labelFollowersNumber setText:@""];
    [_labelFollowingNumber setText:@""];
    
    _buttonFollow.hidden= YES;
}

- (void)provideStats:(UserStatsObject *)stats
{
    //    NSInteger lists= stats.totalLists;
    NSUInteger followers = stats.totalFollowers;
    NSUInteger following = stats.totalFollowees;
    NSUInteger restaurantCount = stats.totalVenues;
    NSUInteger photosCount = stats.totalPhotos;
    
    if (followers == 1) {
        [_labelFollowersNumber setText:@"1"];
        [_labelFollowers setText:@"follower"];
    } else {
        [_labelFollowersNumber setText:stringFromUnsigned(followers)];
        [_labelFollowers setText:@"followers"];
    }
    
    [_labelFollowingNumber setText:stringFromUnsigned(following)];
    [_labelFollowing setText:@"following"];
    
    if (restaurantCount == 1) {
        [_labelPlacesNumber setText:@"1"];
        [_labelPlaces setText:@"place"];
    } else {
        [_labelPlacesNumber setText:stringFromUnsigned(restaurantCount)];
        [_labelPlaces setText: @"places"];
    }
    
    [_labelPhotosNumber setText:stringFromUnsigned(photosCount)];
    
    self.labelFollowers.alpha = 1;
    self.labelPhotos.alpha = 1;
    self.labelFollowing.alpha = 1;
    self.labelPlaces.alpha = 1;
    self.labelFollowersNumber.alpha = 1;
    self.labelPhotosNumber.alpha = 1;
    self.labelFollowingNumber.alpha = 1;
    self.labelPlacesNumber.alpha = 1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    const float kGeomUserListVCCellMiddleGap= 7;
    
    float w = self.frame.size.width;
    const float margin = kGeomSpaceEdge;
    const float spacing = kGeomSpaceInter;
    float imageSize = kGeomUserListUserImageHeight;
    _userView.frame = CGRectMake(margin, margin, imageSize, imageSize);
    
    _buttonFollow.frame = CGRectMake(w-margin-kGeomButtonWidth, 15,kGeomButtonWidth, kGeomFollowButtonHeight);
    
    float x=margin+imageSize+kGeomUserListVCCellMiddleGap;
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
    y += labelHeight+ spacing;
    
    float iconWidth = 30;
    labelHeight = 20;
    
    x=  margin + imageSize + spacing;
    y = _userView.frame.size.height + _userView.frame.origin.y - labelHeight;
    _labelPhotos.frame=CGRectMake(x, y, iconWidth, labelHeight);
    x += iconWidth;
    _labelPhotosNumber.frame=CGRectMake(x, y, 55,  labelHeight);
    y += labelHeight+ spacing;
    
    labelHeight= 17;//  from mockup
    y = _userView.frame.size.height + _userView.frame.origin.y - 2*labelHeight;
    
    float rightAreaWidth= 150;//  from mockup
    int leftLabelWidth = (int) rightAreaWidth*4/14.;
    int rightLabelWidth = (int) rightAreaWidth*5/14.;
    x= w-rightAreaWidth;
    _labelPlacesNumber.frame=CGRectMake(x, y, leftLabelWidth, labelHeight);
    _labelPlaces.frame=CGRectMake(x, y +labelHeight, leftLabelWidth, labelHeight);
    x += leftLabelWidth;
    _labelFollowersNumber.frame=CGRectMake(x, y, rightLabelWidth, labelHeight);
    _labelFollowers.frame=CGRectMake(x, y +labelHeight, rightLabelWidth, labelHeight);
    x += rightLabelWidth;
    _labelFollowingNumber.frame=CGRectMake(x, y, rightLabelWidth, labelHeight);
    _labelFollowing.frame=CGRectMake(x, y +labelHeight, rightLabelWidth, labelHeight);
    
    [_userView layoutIfNeeded];
}

@end

//==============================================================================
@interface UserListVC ()
@property (nonatomic,strong) UITableView *tableUsers;

@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperationSection1; //
@property (nonatomic,strong) NSArray *arraySectionHeaderViews;

@end

@implementation UserListVC

- (void)dealloc
{
    [_usersArray removeAllObjects];
    self.usersArray=nil;
    self.arraySectionHeaderViews=nil;
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [_tableUsers registerClass:[UserListTableCell class] forCellReuseIdentifier:USER_LIST_TABLE_REUSE_IDENTIFIER];
    [_tableUsers registerClass:[UITableViewCell class] forCellReuseIdentifier:USER_LIST_TABLE_REUSE_IDENTIFIER_EMPTY];
    [_tableUsers setLayoutMargins:UIEdgeInsetsZero];
    _tableUsers.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableUsers.separatorColor= BLACK;
    _tableUsers.showsVerticalScrollIndicator= NO;
    
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
    [self setRightNavWithIcon:@"" target:nil action:nil];
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
    _tableUsers.frame = self.view.bounds; // Replaces 4 constraints.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row=indexPath.row;
    UserObject*u=nil;
    
    @synchronized(self.usersArray)  {
        if ( row<_usersArray.count) {
            u=_usersArray[row];
        }
    }
    
    if (!u) {
        UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:USER_LIST_TABLE_REUSE_IDENTIFIER_EMPTY forIndexPath:indexPath];
        cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.text=  @"Alas there are none.";
        cell.textLabel.textColor=WHITE;
        cell.selectionStyle= UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    UserListTableCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:USER_LIST_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cell.textLabel.textAlignment=NSTextAlignmentCenter;
    cell.selectionStyle= UITableViewCellSeparatorStyleNone;
    cell.delegate= self;
    [cell provideUser:u];
    
    [cell commenceFetchingStats];
    
    return cell;
}

//------------------------------------------------------------------------------
// Name:    viewForHeaderInSection
// Purpose:
//------------------------------------------------------------------------------
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section >= _arraySectionHeaderViews.count)
        return nil;
    
    UserListTableSectionHeader *view = _arraySectionHeaderViews[section];
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
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row=indexPath.row;
    UserObject*u=nil;
    
    @synchronized(self.usersArray)  {
        if ( row<_usersArray.count) {
            u=_usersArray[row];
        }
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
    @synchronized(self.usersArray)  {
        return _usersArray.count;
    }
}

- (void)userTappedSectionHeader:(int)which
{
    
    
}

- (void)userTappedFollowButtonForUser:(UserObject*)user
{
    //    [self reload];
}

- (void) userTappedImageOfUser:(UserObject*)user;
{
    [self goToProfile:user];
}

@end

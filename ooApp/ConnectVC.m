//
//  ConnectVC.m
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "ListObject.h"
#import "ConnectVC.h"
#import "Settings.h"
#import "ProfileVC.h"

#define CONNECT_TABLE_REUSE_IDENTIFIER  @"connectTableCell"

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
    double  angle= _isExpanded ? M_PI/2 : 3*M_PI/2;
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

        _labelLists.textAlignment=NSTextAlignmentLeft;
        _labelFollowers.textAlignment=NSTextAlignmentCenter;
        _labelFollowing.textAlignment=NSTextAlignmentRight;
    }
    return self;
}

- (void) oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user
{
    message(@"image tap");
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
    _labelUserName.text=nil;
    _labelName.text=nil;
    [self provideStats: @[ @0,@0,@0]];
}

- (void) provideStats: (NSArray*) values
{
    if (values.count!=3)
        return;

    [_labelLists setText: [NSString stringWithFormat:@"%@ lists",values[0]  ]];
    [_labelFollowers setText: [NSString stringWithFormat:@"%@ followers",values[1]  ]];
    [_labelFollowing setText: [NSString stringWithFormat:@"%@ following",values[2]  ]];
}

- (void) layoutSubviews
{
//    const float kGeomConnectCellUsernameHeight=25;
//    const float kGeomConnectCellNameHeight=20;
    //    const float kGeomConnectCellStatsHeight=15;
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
    _labelUserName.frame=CGRectMake(x, y, remainingWidth, labelHeight);
    y +=  labelHeight+ spacing;
    labelHeight=_labelName.intrinsicContentSize.height;
    _labelName.frame=CGRectMake(x, y, remainingWidth, labelHeight);
    labelHeight=_labelFollowers.intrinsicContentSize.height;
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
@property (nonatomic,strong) NSMutableArray *arraySectionHeaderViews;
@property (nonatomic,assign) BOOL canSeeSection1Items, canSeeSection2Items, canSeeSection3Items;
@end

@implementation ConnectVC

- (void)dealloc
{
    [_suggestedUsersArray removeAllObjects];
    [_foodiesArray removeAllObjects];
    [_followeesArray removeAllObjects];
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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _suggestedUsersArray = [NSMutableArray new];
    _foodiesArray = [NSMutableArray new];
    _followeesArray = [NSMutableArray new];
    
    NavTitleObject *nto;
    nto = [[NavTitleObject alloc]
           initWithHeader:LOCAL(@"Connect")
           subHeader: LOCAL(@"find your foodies")];
    
    self.navTitle = nto;
    
    self.tableAccordion = makeTable(self.view,self);
    _tableAccordion.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_tableAccordion registerClass:[ConnectTableCell class] forCellReuseIdentifier:CONNECT_TABLE_REUSE_IDENTIFIER];
    
    _tableAccordion.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)fetchFollowees
{
    UserObject*user= [Settings sharedInstance].userObject;
    __weak ConnectVC *weakSelf = self;
    
    self.fetchOperationSection1 =
    [OOAPI getFollowingWithSuccess:^(NSArray *users) {
        @synchronized(weakSelf.suggestedUsersArray)  {
            weakSelf.suggestedUsersArray= users.mutableCopy;
            NSLog  (@"SUCCESS IN FETCHING %lu FOLLOWEES",
                    ( unsigned long)weakSelf.suggestedUsersArray.count);
        }
        if (weakSelf.canSeeSection1Items) {
            // RULE: Don't reload the section unless the suggested users are visible.
            ON_MAIN_THREAD(^() {
                [weakSelf.tableAccordion reloadData];// XX: need to limit to section.
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog  (@"UNABLE TO FETCH FOLLOWEES");
    }     ];
}

- (void)fetchSuggestedUsers
{
    UserObject*user= [Settings sharedInstance].userObject;
    __weak ConnectVC *weakSelf = self;
    
    self.fetchOperationSection1 =
    [OOAPI getSuggestedUsersForUser:user
                         success:^(NSArray *users) {
                             @synchronized(weakSelf.suggestedUsersArray)  {
                                 weakSelf.suggestedUsersArray= users.mutableCopy;
                                 NSLog  (@"SUCCESS IN FETCHING %lu SUGGESTED USERS",
                                         ( unsigned long)weakSelf.foodiesArray.count);
                             }
                             if (weakSelf.canSeeSection2Items) {
                                 // RULE: Don't reload the section unless the foodies are visible.
                                 ON_MAIN_THREAD(^() {
                                     [weakSelf.tableAccordion reloadData];// XX: need to limit to section.
                                 });
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog  (@"UNABLE TO FETCH SUGGESTED USERS");
                         }
     ];
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
                                     [weakSelf.tableAccordion reloadData];// XX: need to limit to section.
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
    
    [self fetchSuggestedUsers];
    [self fetchFoodies];
    [self fetchFollowees];
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
    _tableAccordion.frame = self.view.bounds;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row=indexPath.row;
    NSInteger section=indexPath.section;
    
    ConnectTableCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CONNECT_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cell.textLabel.textAlignment=NSTextAlignmentCenter;
    UserObject*u=nil;
    
    switch (section) {
        case 0:
            @synchronized(self.suggestedUsersArray)  {
                if ( row<_suggestedUsersArray.count) {
                    u=_suggestedUsersArray[row];
                }
            }
            
        case 1:
            @synchronized(self.foodiesArray)  {
                if ( row<_foodiesArray.count) {
                    u=_foodiesArray[row];
                }
            }
            
        case 2:
            @synchronized(self.followeesArray)  {
                if ( row<_followeesArray.count) {
                    u=_followeesArray[row];
                }
            }
            
        default:
            break;
    }
    
    [cell provideUser:u];
    [cell provideStats: @[ @1, @2, @3]];
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
    ConnectTableSectionHeader *view = [[ConnectTableSectionHeader alloc] init];
    switch(section) {
        case 0:
            view.backgroundColor=UIColorRGB(0xd0d0d0);
            view.labelTitle.text=@"Suggested Users"; break;
        case 1:
            view.backgroundColor=UIColorRGB(0xc0c0c0);
            view.labelTitle.text=@"Foodies"; break;
        case 2:
            view.backgroundColor=UIColorRGB(0xb0b0b0);
            view.labelTitle.text=@"Users You Follow"; break;
    }
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
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70;
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    message(@"tapped");
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
                return _canSeeSection1Items? _suggestedUsersArray.count: 0;
            }
            
        case 1:
            @synchronized(self.foodiesArray)  {
                return _canSeeSection2Items? _foodiesArray.count: 0;
            }
            
        case 2:
            @synchronized(self.followeesArray)  {
                return _canSeeSection3Items? _followeesArray.count: 0;
            }
            
        default:
            break;
    }
    return 0;
}

- (void)userTappedSectionHeader:(int)which
{
    [_tableAccordion beginUpdates];
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
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex: which];
    [_tableAccordion reloadSections:indexSet withRowAnimation: UITableViewRowAnimationAutomatic];
    [_tableAccordion endUpdates];

}

@end

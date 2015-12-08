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
@property (nonatomic,strong)UIButton *buttonExpander;
@end

@implementation ConnectTableSectionHeader
- (instancetype) init
{
    self=[super init];
    if (self) {
        _labelTitle=makeLabel(self, nil, kGeomFontSizeStripHeader);
        _labelTitle.textColor=WHITE;
        _buttonExpander=makeIconButton(self, kFontIconMore,
                                       30, WHITE,
                                       CLEAR, self,
                                       @selector(userPressedExpand:),
                                       0);
        self.backgroundColor=GRAY;
    }
    return self;
}

- (void) userPressedExpand:(id)sender
{
    
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
    
    float w=self.frame.size.width;
    float h=self.frame.size.height;
    const float margin=kGeomSpaceEdge;
    const float spacing=kGeomSpaceInter;
    float imageSize=h-2*margin;
    _userView.frame=CGRectMake(margin, margin, imageSize, imageSize);
    float x=margin+imageSize;
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
        remainingWidth=414;
    int labelWidth = (int) remainingWidth/3;
    _labelLists.frame=CGRectMake(x, y, labelWidth, labelHeight);
    x += labelWidth;
    _labelFollowers.frame=CGRectMake(x, y, labelWidth, labelHeight);
    x += labelWidth;
    _labelFollowing.frame=CGRectMake(x, y, labelWidth, labelHeight);
    x += labelWidth;
}

@end

//==============================================================================
@interface ConnectVC ()
@property (nonatomic,strong) UITableView *tableAccordion;

@property (nonatomic,strong) NSMutableArray *suggestedUsersArray; // section 0
@property (nonatomic,strong) NSMutableArray *foodiesArray; // section 1
@property (nonatomic,strong) NSMutableArray *followeesArray; // section 2

@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperation;
@property (nonatomic,strong) NSMutableArray *arraySectionHeaderViews;
@property (nonatomic,assign) BOOL canSeeSection1Items, canSeeSection2Items, canSeeSection3Items;
@end

@implementation ConnectVC

- (void)dealloc
{
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
    
    UserObject*moi=[UserObject new];
    moi.userID=2;
    [_suggestedUsersArray addObject:moi];
    [_suggestedUsersArray addObject:[UserObject new]];
    [_suggestedUsersArray addObject:[UserObject new]];
    [_foodiesArray addObject:[UserObject new]];
    [_followeesArray addObject:[UserObject new]];
    
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
        case 0: u=_suggestedUsersArray[row]; break;
        case 1: u=_foodiesArray[row]; break;
        case 2: u=_followeesArray[row]; break;
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
    view.backgroundColor=BLUE;
    switch(section) {
        case 0:
            view.labelTitle.text=@"Suggested Users"; break;
        case 1:
            view.labelTitle.text=@"Foodies"; break;
        case 2:
            view.labelTitle.text=@"Users You Follow"; break;
    }
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
        case 0:  return _canSeeSection1Items? _suggestedUsersArray.count: 0;
        case 1:  return _canSeeSection2Items? _foodiesArray.count: 0;
        case 2:  return _canSeeSection3Items? _followeesArray.count: 0;
            
        default:
            break;
    }
    return 0;
}

@end

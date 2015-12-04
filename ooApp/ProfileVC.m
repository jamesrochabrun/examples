//
//  ProfileVC.m
//  ooApp
//
//  Created by Zack Smith & Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ProfileVC.h"
#import "UserObject.h"
#import "Settings.h"
#import "Common.h"
#import "ListStripTVCell.h"
#import "OOAPI.h"
#import "EmptyListVC.h"
#import "RestaurantListVC.h"
#import "UIImage+Additions.h"
#import "AppDelegate.h"
#import "DebugUtilities.h"
#import "OOUserView.h"

@interface ProfileTableFirstRow ()
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, assign) BOOL viewingOwnProfile;
@property (nonatomic, assign) ProfileVC *vc;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UIButton *buttonFollow;
@property (nonatomic, strong) UIButton *buttonNewList;
@property (nonatomic, strong) UILabel *labelUsername;
@property (nonatomic, strong) UILabel *labelDescription;
@property (nonatomic, strong) UILabel *labelRestaurants;
@property (nonatomic, strong) UIButton *buttonNewListIcon;
@property (nonatomic, assign) float spaceNeededForFirstCell;
@property (nonatomic, assign) UINavigationController *navigationController;

@end

static NSString * const FirstRowID = @"profileFirstRowCell";
static NSString * const ListRowID = @"ListRowCell";

@implementation ProfileTableFirstRow

- (void)setUserInfo:(UserObject *)u
{
    _userInfo= u;
    
    // Ascertain whether reviewing our own profile.
    UserObject *currentUser= [Settings sharedInstance].userObject;
    NSUInteger ownUserIdentifier= [currentUser userID];
    _viewingOwnProfile = _userInfo.userID == ownUserIdentifier;
    if ( _viewingOwnProfile) {
        _buttonFollow.hidden= YES;
        
    } else {
        self.buttonNewList.hidden= YES;
    }
    
    NSString *username= nil;
    if  (_userInfo.username.length) {
        username = _userInfo.username;
    } else {
        username = @"Missing username";
    }
    _labelUsername.text= username;
    
    [_userView setUser: _userInfo];
    
    // Find out if current user is following this user.
    if  (!_viewingOwnProfile) {
        self.buttonFollow.selected= NO;
        __weak ProfileTableFirstRow *weakSelf = self;
        
        [OOAPI  getFollowersOf: _userID
                       success:^(NSArray *users) {
                           for (UserObject* user   in  users) {
                               if ( user.userID==ownUserIdentifier) {
                                   weakSelf.buttonFollow.selected= YES;
                                   break;
                               }
                           }
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog  (@"CANNOT FETCH FOLLOWERS OF USER");
                       }];
    }
    
    [self layoutsSubviews];
}

//------------------------------------------------------------------------------
// Name:    initWithStyle:
// Purpose:
//------------------------------------------------------------------------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userView= [[OOUserView alloc] init];
        [self addSubview: self.userView];
        
        NSString *description = _userInfo.about.length? _userInfo.about: nil;
        NSString *restaurants =  nil;
        
        self.labelUsername = makeLabelLeft(self, nil,kGeomFontSizeHeader);
        self.labelDescription = makeLabelLeft(self, description,kGeomFontSizeHeader);
        self.labelRestaurants = makeLabelLeft(self, restaurants,kGeomFontSizeHeader);
        
        _labelUsername.textColor = UIColorRGBA(kColorWhite);
        _labelDescription.textColor = UIColorRGBA(kColorWhite);
        _labelRestaurants.textColor = UIColorRGBA(kColorWhite);
        
        self.backgroundColor = UIColorRGBA(kColorBlack);
        
        self.buttonFollow= makeButton(self,  @"FOLLOW",
                                      kGeomFontSizeHeader, UIColorRGBA(kColorWhite), CLEAR,
                                      self,
                                      @selector (userPressedFollow:), 1);
        [_buttonFollow setTitle:@"FOLLOWING" forState:UIControlStateSelected];
        
        self.buttonNewList= makeButton(self,  @"NEW LIST",
                                       kGeomFontSizeHeader, UIColorRGBA(kColorWhite), CLEAR,
                                       self,
                                       @selector (userPressedNewList:), 0);
        self.buttonNewListIcon= makeButton(self,kFontIconAdd,
                                           kGeomFontSizeHeader, UIColorRGBA(kColorWhite), CLEAR,
                                           self,
                                           @selector (userPressedNewList:), 0);
        [_buttonNewListIcon.titleLabel setFont:
         [UIFont fontWithName:kFontIcons size:kGeomFontSizeHeader]];
    }
    return self;
}

//------------------------------------------------------------------------------
// Name:    userPressedNewList
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedNewList:(id)sender
{
    if (!_navigationController) {
        return;
    }
    
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:LOCAL(@"New List")
                                                   message:LOCAL(@"Enter a name for the new list")
                                                  delegate:self
                                         cancelButtonTitle:LOCAL(@"Cancel")
                                         otherButtonTitles:LOCAL(@"Create"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

//------------------------------------------------------------------------------
// Name:    clickedButtonAtIndex
// Purpose:
//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if  (1 == buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *string = trimString(textField.text);
        if  (string.length ) {
            string = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] uppercaseString]];
        }
        
        OOAPI *api = [[OOAPI alloc] init];
        
        [api addList:string
             success:^(ListObject *list) {
                 ON_MAIN_THREAD(^{
                     if (list) {
                         [self.vc performSelectorOnMainThread:@selector(goToEmptyListScreen:) withObject:list waitUntilDone:NO];
                     } else {
                         message( @"That list name is already in use.");
                     }
                 });
             }
             failure:^(AFHTTPRequestOperation *operation, NSError * error) {
                 NSString *s = [NSString stringWithFormat:@"Error from cloud: %@", error.localizedDescription];
                 message(s);
             }
         ];
    }
}

//------------------------------------------------------------------------------
// Name:    userPressedFollow
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedFollow:(id)sender
{
    if (!_navigationController) {
        return;
    }
    
    __weak ProfileTableFirstRow *weakSelf = self;
    [OOAPI setFollowingUser:_userInfo
                         to: !weakSelf.buttonFollow.selected
                    success:^(id responseObject) {
                        weakSelf.buttonFollow.selected= !weakSelf.buttonFollow.selected;
                       if (weakSelf.buttonFollow.selected ) {
                           NSLog (@"SUCCESSFULLY FOLLOWED USER");
                       } else {
                           NSLog (@"SUCCESSFULLY UNFOLLOWED USER");
                       }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                        NSLog (@"FAILED TO FOLLOW/UNFOLLOW USER");
                    }];
}

//------------------------------------------------------------------------------
// Name:    layoutsSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)layoutsSubviews
{
    float w = [UIScreen mainScreen].bounds.size.width;
    
    const int spacer = kGeomSpaceInter;
    int x = kGeomSpaceEdge;
    int y = kGeomSpaceEdge;
    _userView.frame = CGRectMake(x, y, kGeomProfileImageSize, kGeomProfileImageSize);
    int bottomOfImage = y + kGeomProfileImageSize;
    
    // Place the image
    x += kGeomProfileImageSize + spacer;
    _labelUsername.frame=CGRectMake(x,y,w-x,kGeomProfileInformationHeight);
    y += kGeomProfileInformationHeight + spacer;
    
    // Place the labels
    if (_labelDescription.text.length) {
        _labelDescription.frame=CGRectMake(x,y,w-x,kGeomProfileInformationHeight);
        y += kGeomProfileInformationHeight + spacer;
    } else {
        _labelDescription.hidden = YES;
    }
    
    if (_labelRestaurants.text.length) {
        _labelRestaurants.frame = CGRectMake(x,y,w-x,kGeomProfileInformationHeight);
        y += kGeomProfileInformationHeight + spacer;
    } else {
        _labelRestaurants.hidden= YES;
    }
    
    // Place the follow button
    if (!_viewingOwnProfile) {
        _buttonFollow.frame=CGRectMake(w- kGeomSpaceEdge-kGeomButtonWidth,y,kGeomButtonWidth,  kGeomHeightButton);
        y += kGeomHeightButton + spacer;
    } else {
        _buttonFollow.hidden= YES;
    }
    
    if  (y < bottomOfImage) {
        y= bottomOfImage;
    }
    
    // Place the new list buttons
    if ( _viewingOwnProfile) {
        x = kGeomSpaceEdge;
        [_buttonNewListIcon sizeToFit];
        float iconWith= _buttonNewListIcon.frame.size.width;
        _buttonNewListIcon.frame=CGRectMake(x,y, iconWith, kGeomHeightButton);
        x += iconWith + spacer;
        [_buttonNewList sizeToFit];
        float textWidth= _buttonNewList.frame.size.width;
        _buttonNewList.frame=CGRectMake(x,y,textWidth, kGeomHeightButton);
        y +=  kGeomHeightButton + spacer;
    }
    
    self.spaceNeededForFirstCell = y;
}

//------------------------------------------------------------------------------
// Name:    neededHeight
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)neededHeight
{
    if (!_spaceNeededForFirstCell) {
        [self layoutsSubviews];
    }
    return self.spaceNeededForFirstCell;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _buttonFollow.hidden= NO;
}

@end

//==============================================================================
@interface ProfileVC ()

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSArray *lists;
@property (nonatomic, strong) UserObject *profileOwner;
@end

@implementation ProfileVC

//------------------------------------------------------------------------------
// Name:    init
// Purpose:
//------------------------------------------------------------------------------
- (instancetype) init
{
    self = [super init];
    if (self) {
        _userID = 0;
    }
    return self;
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));

    OOAPI *api = [[OOAPI alloc] init];
    [api getListsOfUser:((_userID) ? _userID : _profileOwner.userID) withRestaurant:0
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user:  %ld", (long)foundLists.count);
                    _lists = foundLists;
                    [self.table reloadData];
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                    NSLog  (@" error while getting lists for user: %@",e);
                }];
}

- (void)done:(id)sender
{
    [self.navigationController  popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    
    // Ascertain whether reviewing our own profile.
    //
    if (!_userInfo) {
        UserObject *userInfo = [Settings sharedInstance].userObject;
        self.profileOwner = userInfo;
    } else {
        self.profileOwner = _userInfo;
    }
    
//    {
//        // This attempts to reestablish the back button but it does not work.
//        self.navigationController.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(done:)] ;
//        [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
//    }
    
    _lists = [NSArray array];
    
    self.table = [UITableView new];
    self.table.delegate= self;
    self.table.dataSource= self;
    [self.view addSubview:_table];
    self.table.backgroundColor=[UIColor clearColor];
    self.table.separatorStyle= UITableViewCellSeparatorStyleNone;
    [_table registerClass:[ProfileTableFirstRow class] forCellReuseIdentifier:FirstRowID];
    [_table registerClass:[ListStripTVCell class] forCellReuseIdentifier:ListRowID];
    
    NSString *first = _profileOwner.firstName ?:  @"";
    NSString *last = _profileOwner.lastName ?:  @"";
    NSString *fullName =  [NSString stringWithFormat: @"%@ %@", first, last ];
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:fullName subHeader:nil];
    [self setNavTitle:nto];
    
    __weak  ProfileVC *weakSelf = self;
    if  (!_profileOwner.mediaItem) {
        [_profileOwner refreshWithSuccess:^{
            [weakSelf.table reloadRowsAtIndexPaths:@[ [NSIndexPath  indexPathForRow:0 inSection:0]]
                                                      withRowAnimation:UITableViewRowAnimationNone
             ];
        } failure:^{
            NSLog  (@"UNABLE TO REFRESH USER OBJECT.");
        }
         ];
    }
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    // NOTE:  this is just temporary
    [super viewWillLayoutSubviews];
    self.table.frame = self.view.bounds;
}

//------------------------------------------------------------------------------
// Name:    goToEmptyListScreen
// Purpose:
//------------------------------------------------------------------------------
- (void)goToEmptyListScreen:(ListObject *)list
{
    EmptyListVC *vc= [[EmptyListVC alloc] init];
    vc.listItem = list;
    [self.navigationController pushViewController:vc animated:YES];
}

//------------------------------------------------------------------------------
// Name:    getNumberOfLists
// Purpose:
//------------------------------------------------------------------------------
- (NSUInteger)getNumberOfLists
{
    return self.lists.count;
}

//------------------------------------------------------------------------------
// Name:    getNameOfList
// Purpose:
//------------------------------------------------------------------------------
- (NSString *)getNameOfList:(NSInteger)which
{
    NSArray *a= self.lists;
    if  (which < 0 ||  which >= a.count) {
        return  @"";
    }
    return [a objectAtIndex:which];
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;

    if (!row) {
        return 120;
    }
    return kGeomHeightStripListRow;
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- ( NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + [self getNumberOfLists];
}

//------------------------------------------------------------------------------
// Name:    cellForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if  (!row) {
        ProfileTableFirstRow* headerCell= [tableView dequeueReusableCellWithIdentifier:FirstRowID forIndexPath:indexPath];
        [ headerCell setUserInfo: _profileOwner];
        headerCell.vc = self;
        headerCell.navigationController = self.navigationController;
        return headerCell;
    }
    
    ListStripTVCell *cell = [tableView dequeueReusableCellWithIdentifier:ListRowID forIndexPath:indexPath];

    NSArray *a = self.lists;
    ListObject *listItem = a[indexPath.row-1];
    listItem.listDisplayType = KListDisplayTypeStrip;
    
    cell.listItem = listItem;
    cell.navigationController = self.navigationController;
    
//    [DebugUtilities addBorderToViews:@[cell]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (!row) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    ListObject *item = [_lists objectAtIndex:(indexPath.row - 1)];
    
    RestaurantListVC *vc = [[RestaurantListVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = item.name;
    vc.listItem = item;
}

@end

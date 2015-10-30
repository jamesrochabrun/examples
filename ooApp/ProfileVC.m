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

@interface ProfileTableFirstRow ()
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, assign) BOOL viewingOwnProfile;
@property (nonatomic, assign) ProfileVC *vc;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@end

@implementation ProfileTableFirstRow

//------------------------------------------------------------------------------
// Name:    initWithUserInfo:
// Purpose:
//------------------------------------------------------------------------------
- (instancetype)initWithUserInfo:(UserObject *)u
{
    self = [super init];
    if (self) {
        self.buttonFollow= makeButton(self,  @"FOLLOW",
                                      kGeomFontSizeHeader,BLACK, CLEAR,
                                      self,
                                      @selector (userPressedFollow:), 1);
        self.buttonNewList= makeButton(self,  @"NEW LIST",
                                       kGeomFontSizeHeader,BLACK, CLEAR,
                                       self,
                                       @selector (userPressedNewList:), 0);
        self.buttonNewListIcon= makeButton(self,kFontIconAdd,
                                           kGeomFontSizeHeader,BLACK, CLEAR,
                                           self,
                                           @selector (userPressedNewList:), 0);
        [_buttonNewListIcon.titleLabel setFont:
         [UIFont fontWithName:kFontIcons size:kGeomFontSizeHeader]];
        
        _userInfo = u;
        _userID = u.userID ;
        
        // Ascertain whether reviewing our own profile.
        UserObject *currentUser= [Settings sharedInstance].userObject;
        NSUInteger ownUserIdentifier= [currentUser userID];
        _viewingOwnProfile = _userID == ownUserIdentifier;
        
        self.iv = makeImageViewFromURL (self, u.imageURLString, kImageNoProfileImage);
        
        NSString *username= nil;
        if  (_userInfo.username.length) {
            username = _userInfo.username;
        } else {
            username = @"Missing username";
        }
        
        NSString *description = _userInfo.about.length? _userInfo.about: nil;
        NSString *restaurants =  nil;
        
        self.labelUsername = makeLabelLeft(self, username,kGeomFontSizeHeader);
        self.labelDescription = makeLabelLeft(self, description,kGeomFontSizeHeader);
        self.labelRestaurants = makeLabelLeft(self, restaurants,kGeomFontSizeHeader);
        
        self.iv.layer.borderColor = GRAY.CGColor;
        self.iv.layer.borderWidth = 1;
        self.iv.contentMode = UIViewContentModeScaleAspectFit;
        
        self.backgroundColor = WHITE;
        
        if (_userInfo.imageIdentifier && [_userInfo.imageIdentifier length]) {
            self.requestOperation = [OOAPI getUserImageWithImageID: _userInfo.imageIdentifier
                                                         maxWidth:self.frame.size.width
                                                        maxHeight:0 success:^(NSString *link) {
                ON_MAIN_THREAD( ^{
                    [_iv setImageWithURL:[NSURL URLWithString:link]];
                });
            } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                ;
            }];
        } else if (_userInfo.imageURLString) {
            ON_MAIN_THREAD( ^{
                [_iv setImageWithURL:[NSURL URLWithString:_userInfo.imageURLString]];
            });
        }
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
             success:^(id response) {
                 [self.vc performSelectorOnMainThread:@selector(goToEmptyListScreen:) withObject:string waitUntilDone:NO];
             }
             failure:^(AFHTTPRequestOperation* operation, NSError * error) {
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
    
    [OOAPI setFollowingUser:_userInfo
                         to:YES
                    success:^(id responseObject) {
                        NSLog (@"SUCCESSFULLY FOLLOWED USER");
                    } failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                        NSLog (@"FAILED TO FOLLOW USER");
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
    _iv.frame = CGRectMake(x, y, kGeomProfileImageSize, kGeomProfileImageSize);
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
    x = kGeomSpaceEdge;
    [_buttonNewListIcon sizeToFit];
    float iconWith= _buttonNewListIcon.frame.size.width;
    _buttonNewListIcon.frame=CGRectMake(x,y, iconWith, kGeomHeightButton);
    x += iconWith + spacer;
    [_buttonNewList sizeToFit];
    float textWidth= _buttonNewList.frame.size.width;
    _buttonNewList.frame=CGRectMake(x,y,textWidth, kGeomHeightButton);
    y +=  kGeomHeightButton + spacer;
    
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

@end

//==============================================================================
@interface ProfileVC ()

@property (nonatomic, strong) ProfileTableFirstRow* headerCell;
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

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];

    OOAPI *api = [[OOAPI alloc] init];
    [api getListsOfUser:((_userID) ? _userID : _profileOwner.userID) withRestaurant:0
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user:  %ld", (long)foundLists.count);
                    _lists = foundLists;
                    [self.table reloadData];
                }
                failure:^(AFHTTPRequestOperation* operation, NSError *e) {
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
    
    // Ascertain whether reviewing our own profile.
    //
    if (!_userID) {
        UserObject *userInfo = [Settings sharedInstance].userObject;
        self.profileOwner = userInfo;
    } else {
        self.profileOwner = _userInfo;
        
        // Hide the menu button.
        self.menu.title=  @"";
        self.menu.enabled=NO;
        message2 (@"profile VC descends from base VC, so there is no back button.", @"we're working on it.6");
        
        // This attempts to reestablish the back button but it does not work.
        self.navigationController.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(done:)] ;
        self.navigationController.navigationItem.backBarButtonItem= [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(done:)] ;

    }
    
    _lists = [NSArray array];
    
    // NOTE:  these will later be stored in user defaults.
    _headerCell = [[ProfileTableFirstRow alloc] initWithUserInfo:_profileOwner];
    _headerCell.vc = self;
    _headerCell.navigationController = self.navigationController;
    
    self.table = [UITableView new];
    self.table.delegate= self;
    self.table.dataSource= self;
    [self.view addSubview:_table];
    self.table.backgroundColor=[UIColor clearColor];
    self.table.separatorStyle= UITableViewCellSeparatorStyleNone;
    
    NSString *first = _profileOwner.firstName ?:  @"";
    NSString *last = _profileOwner.lastName ?:  @"";
    NSString *fullName =  [NSString stringWithFormat: @"%@ %@", first, last ];
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: fullName subHeader:nil];
    [self setNavTitle:  nto];
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
- (void)goToEmptyListScreen:(NSString *)string
{
//     [self performSegueWithIdentifier: @"gotoEmptyList" sender:self];
    
    EmptyListVC *vc= [[EmptyListVC alloc] init];
    vc.listName = string;
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

    if (! row) {
        return [_headerCell neededHeight];
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
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"pcell";
    
    NSInteger row = indexPath.row;
    
    if  (!row) {
        return _headerCell;
    }
    
    ListStripTVCell* cell = [[ListStripTVCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    NSArray* a= self.lists;
    cell.listItem = a[indexPath.row-1];
    cell.navigationController = self.navigationController;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (!row) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO ];
        return;
    }
    ListObject *item = [_lists objectAtIndex:(indexPath.row - 1)];
    
    RestaurantListVC *vc = [[RestaurantListVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = item.name;
    vc.listItem = item;
}

@end

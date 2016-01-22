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
#import "ListStripCVCell.h"
#import "OOAPI.h"
#import "EmptyListVC.h"
#import "UIImage+Additions.h"
#import "AppDelegate.h"
#import "DebugUtilities.h"
#import "OOUserView.h"
#import "ManageTagsVC.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "OOTextEntryModalVC.h"
#import "OOFilterView.h"
#import "ProfileVCCVLayout.h"
#import "RestaurantListVC.h"
#import "ConnectVC.h"
#import "RestaurantVC.h"
#import "UserListVC.h"

@interface ProfileHeaderView ()
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, strong) UIView *viewHalo;
@property (nonatomic, assign) BOOL viewingOwnProfile;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UIButton *buttonFollow;
@property (nonatomic, strong) UIButton *buttonDescription;
@property (nonatomic, strong) UIButton *buttonFollowees;
@property (nonatomic, strong) UIButton *buttonFollowers;
@property (nonatomic, strong) UIButton *buttonFolloweesCount;
@property (nonatomic, strong) UIButton *buttonFollowersCount;
@property (nonatomic,strong)  UILabel *labelVenuesCount,*labelPhotoCount,*labelLikesCount;
@property (nonatomic,strong)  UILabel *labelVenues,*labelPhoto,*labelLikes;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *backgroundImageFade;
@property (nonatomic,strong) OOFilterView *filterView;
@property (nonatomic,assign) BOOL followingThisUser;
@end

@implementation ProfileHeaderView

- (void)registerForNotification:(NSString*) name calling:(SEL)selector
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector: selector
                   name: name
                 object:nil];
}

- (void)unregisterFromNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver: self  ];
}

- (void)setUserInfo:(UserObject *)u
{
    if ( u==_userInfo) {
        return;
    }
    _userInfo= u;
    
    [self loadUserInfo];
}

- (void) loadUserInfo
{
    if (!_userInfo) {
        return;
    }
    __weak ProfileHeaderView *weakSelf = self;
    
    [_userView setUser: _userInfo];
    
    // Ascertain whether reviewing our own profile.
    
    UserObject *currentUser = [Settings sharedInstance].userObject;
    NSUInteger ownUserIdentifier = [currentUser userID];
    _viewingOwnProfile = _userInfo.userID == ownUserIdentifier;
    
    [self  indicateNotFollowing];
    
    // RULE: Only update the button when we know for sure whose profile is.
    if ( _viewingOwnProfile) {
        NSLog  (@"VIEWING OWN PROFILE.");
        // RULE: Show the user's own stats.
        [self  indicateFollowing];
    }
    else  {
        [OOAPI  getFollowersOf: _userInfo.userID
                       success:^(NSArray *users) {
                           
                           BOOL foundSelf= NO;
                           for (UserObject* user   in  users) {
                               // RULE: If we are following this user then we make the follow button disappear.
                               if ( user.userID==ownUserIdentifier) {
                                   foundSelf= YES;
                                   break;
                               }
                           }
                           
                           if  (!foundSelf) {
                               [weakSelf indicateNotFollowing];
                           } else {
                               [weakSelf indicateFollowing];
                           }
                           
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog  (@"CANNOT FETCH FOLLOWERS OF USER");
                       }];
    }
    
    if  (_userInfo.about.length) {
        [_buttonDescription setTitle:_userInfo.about forState:UIControlStateNormal];
    } else {
        if (_viewingOwnProfile) {
            [_buttonDescription setTitle: @"Tap here and tell us about yourself." forState:UIControlStateNormal ];
        } else {
            NSString *pronoun=  @"their";
            
            if ( _userInfo.gender.length) {
                unichar ch=[_userInfo.gender characterAtIndex:0];
                if ( ch == 'f' || ch=='F') {
                    pronoun=  @"her";
                } else {
                    pronoun=  @"his";
                }
            }
            NSString*expression=[NSString  stringWithFormat: @"This user probably just needs a second to finish  %@ meal, stay tuned.", pronoun ];
            [_buttonDescription setTitle: expression forState:UIControlStateNormal ];
        }
    }
    
    [self layoutSubviews];
    
    _buttonFollowees.alpha= 0;
    _buttonFollowers.alpha= 0;
    _buttonFolloweesCount.alpha= 0;
    _buttonFollowersCount.alpha= 0;
    
    [OOAPI getUserStatsFor:_userInfo.userID
                   success:^(UserStatsObject *stats) {
                       ON_MAIN_THREAD(^{
                           
                           [weakSelf.buttonFollowersCount setTitle:stringFromUnsigned(stats.totalFollowers) forState:UIControlStateNormal ] ;
                           [weakSelf.buttonFolloweesCount setTitle:stringFromUnsigned(stats.totalFollowees) forState:UIControlStateNormal ] ;
                           
                           weakSelf.buttonFollowees.alpha= 1;
                           weakSelf.buttonFollowers.alpha= 1;
                           weakSelf.buttonFolloweesCount.alpha= 1;
                           weakSelf.buttonFollowersCount.alpha= 1;
                           
                           weakSelf.labelPhotoCount.text= stringFromUnsigned(stats.totalPhotos);
                           weakSelf.labelLikesCount.text= stringFromUnsigned(stats.totalLikes);
                           weakSelf.labelVenuesCount.text= stringFromUnsigned(stats.totalVenues);
                       });
                       
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog (@"CANNOT FETCH STATS FOR PROFILE SCREEN.");
                       
                   }];
    
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self=[ super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews= NO;
        _backgroundImageView=  makeImageView(self, @"background-image.jpg");
        _backgroundImageFade= makeView( self,  UIColorRGBA(0x80000000));
        
        _filterView= [[OOFilterView alloc] init];
        [self addSubview:_filterView];
        [_filterView addFilter:LOCAL(@"LISTS") target:self selector:@selector(userTappedOnListsFilter:)];//  index 0
        [_filterView addFilter:LOCAL(@"PHOTOS") target:self selector:@selector(userTappedOnPhotosFilter:)];//  index 1
        
        _userView= [[OOUserView alloc] init];
        [self addSubview:_userView];
        
        _viewHalo= makeView(self, CLEAR);
        addBorder(_viewHalo, 2, YELLOW);
        
        _buttonFollowees= makeButton(self, @"FOLLOWING", kGeomFontSizeSubheader, YELLOW, CLEAR,  self, @selector(userPressedFollowees:), 0);
        _buttonFollowers= makeButton(self, @"FOLLOWERS", kGeomFontSizeSubheader, YELLOW, CLEAR,  self, @selector(userPressedFollowers:), 0);
        
        _buttonFolloweesCount= makeButton(self, @"", kGeomFontSizeHeader, WHITE, CLEAR,  self, @selector(userPressedFollowees:), 0);
        _buttonFollowersCount= makeButton(self, @"", kGeomFontSizeHeader, WHITE, CLEAR,  self, @selector(userPressedFollowers:), 0);
        
        _buttonFollowersCount.titleLabel.font = [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader];
        _buttonFolloweesCount.titleLabel.font = _buttonFollowersCount.titleLabel.font;
        
        _buttonDescription = makeButton(self,  @"", 1, WHITE,
                                        UIColorRGBA(0x80000000),  self,
                                        @selector(userTappedDescription:) , 0);
        _buttonDescription.contentEdgeInsets = UIEdgeInsetsMake(0, kGeomSpaceEdge, 0, kGeomSpaceEdge);
        _buttonDescription.titleLabel.numberOfLines= 0;
        _buttonDescription.titleLabel.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail];
        
        _labelVenuesCount= makeLabel(self,  @"", kGeomFontSizeHeader);
        _labelPhotoCount= makeLabel(self,  @"", kGeomFontSizeHeader);
        _labelLikesCount= makeLabel(self,  @"", kGeomFontSizeHeader);
        _labelVenues= makeIconLabel(self, kFontIconPin, kGeomFontSizeHeader);
        _labelPhoto= makeIconLabel(self, kFontIconPhoto, kGeomFontSizeHeader);
        _labelLikes= makeIconLabel(self, kFontIconYum, kGeomFontSizeHeader);
        
        _labelVenuesCount.textColor= WHITE;
        _labelPhotoCount.textColor= WHITE;
        _labelLikesCount.textColor= WHITE;
        _labelVenues.textColor= WHITE;
        _labelPhoto.textColor= WHITE;
        _labelLikes.textColor= WHITE;
        
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        
        self.buttonFollow = makeButton(self, @"FOLLOW",
                                       kGeomFontSizeSubheader, YELLOW, CLEAR,
                                       self,
                                       @selector(userPressedFollow:), 0);
        [_buttonFollow setTitle:@"" forState:UIControlStateSelected];
        _buttonFollow.layer.borderColor=YELLOW.CGColor;
        _buttonFollow.layer.cornerRadius= kGeomCornerRadius;
        
        [self registerForNotification: kNotificationOwnProfileNeedsUpdate
                              calling:@selector(updateOwnProfile:)
         ];
    }
    return self;
}

- (void)updateOwnProfile: (NSNotification*)not
{
    if ( !_viewingOwnProfile) {
        return;
    }
    
    [self loadUserInfo];
}

- (void)fetchFollowers
{
    __weak ProfileHeaderView *weakSelf = self;
    
    [OOAPI getFollowersOf: _userInfo.userID
                  success: ^(NSArray *users) {
                      ON_MAIN_THREAD(^{
                          UserListVC *vc= [[UserListVC  alloc] init];
                          vc.desiredTitle=  @"FOLLOWERS";
                          vc.usersArray= users.mutableCopy;
                          [weakSelf.vc.navigationController pushViewController: vc animated:YES];
                          
                          NSLog  (@"SUCCESS IN FETCHING %lu FOLLOWERS",
                                  ( unsigned long)users.count);
                      });
                      
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog  (@"UNABLE TO FETCH FOLLOWERS");
                  }     ];
}

- (void)userPressedFollowers: (id) sender
{
    [self fetchFollowers];
}

- (void)fetchFollowing
{
    __weak  ProfileHeaderView *weakSelf = self;
    
    [OOAPI getFollowingOf: _userInfo.userID
                  success:^(NSArray *users) {
                      ON_MAIN_THREAD(^{
                          UserListVC *vc= [[UserListVC  alloc] init];
                          vc.desiredTitle=  @"FOLLOWEES";
                          vc.usersArray= users.mutableCopy;
                          [weakSelf.vc.navigationController pushViewController: vc animated:YES];
                          
                          NSLog  (@"SUCCESS IN FETCHING %lu FOLLOWEES",
                                  ( unsigned long)users.count);
                      });
                      
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog  (@"CANNOT GET LIST OF PEOPLE WE ARE FOLLOWING");
                  }];
    
}

- (void)userPressedFollowees: (id) sender
{
    [self fetchFollowing];
}

- (void)userTappedDescription:(id)sender
{
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    OOTextEntryModalVC *vc = [[OOTextEntryModalVC alloc] init];
    vc.delegate = self;
    vc.textLengthLimit= kUserObjectMaximumAboutTextLength;
    vc.defaultText = _userInfo.about;
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    [nc addChildViewController:vc];
    
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorBlack)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setShadowImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)]];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = [UIColor clearColor];
    
    [self.vc.navigationController presentViewController:nc animated:YES completion:^{
        nc.topViewController.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }];
}

- (void)textEntryFinished:(NSString*)text;
{
    __weak ProfileHeaderView *weakSelf = self;
    [OOAPI setAboutInfoFor:_userInfo.userID
                        to:text
                   success:^{
                       self.userInfo.about = text;
                       [Settings sharedInstance].userObject.about = text;
                       [[Settings sharedInstance] save];
                       
                       [weakSelf.buttonDescription setTitle:text forState: UIControlStateNormal];
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog(@"FAILED TO SET ABOUT INFO FOR USER");
                   }
     ];
}

- (void)userTappedOnListsFilter: (id) sender
{
    [self.delegate userTappedOnLists];
}

- (void)userTappedOnPhotosFilter: (id) sender
{
    [self.delegate  performSelector:@selector(userTappedOnPhotos)
                         withObject:nil
                         afterDelay:.1
     ];
}

- (void) verifyUnfollow
{
    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"Really Un-follow?")
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style: UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes"
                                                 style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [self doUnfollow];
                                                 }];
    
    [a addAction:cancel];
    [a addAction:ok];
    
    [self.vc presentViewController:a animated:YES completion:nil];
}

- (void)doUnfollow
{
    __weak ProfileHeaderView *weakSelf = self;
    
    [OOAPI setFollowingUser:_userInfo
                         to: NO
                    success:^(id responseObject) {
                        [weakSelf indicateNotFollowing];
                        
                        NSLog (@"SUCCESSFULLY UNFOLLOWED USER");
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                        NSLog (@"FAILED TO UNFOLLOW USER");
                    }];
    
}

- (void)indicateFollowing
{
    _buttonFollow.layer.borderWidth= 0;
    _buttonFollow.selected= YES;
    _followingThisUser=YES;
    _labelPhoto.hidden= NO;
    _labelPhotoCount.hidden= NO;
    _labelLikes.hidden= NO;
    _labelLikesCount.hidden= NO;
    _labelVenues.hidden= NO;
    _labelVenuesCount.hidden= NO;
    
}

- (void)indicateNotFollowing
{
    _followingThisUser=NO;
    _buttonFollow.selected= NO;
    _buttonFollow.layer.borderWidth= 1;
    
    _labelPhoto.hidden= YES;
    _labelPhotoCount.hidden= YES;
    _labelLikes.hidden= YES;
    _labelLikesCount.hidden= YES;
    _labelVenues.hidden= YES;
    _labelVenuesCount.hidden= YES;
    
    
}

//------------------------------------------------------------------------------
// Name:    userPressedFollow
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedFollow:(id)sender
{
    if  (_viewingOwnProfile ) {
        return;
    }
    
    __weak ProfileHeaderView *weakSelf = self;
    
    if (_followingThisUser) {
        [self verifyUnfollow];
        return;
    }
    
    [OOAPI setFollowingUser:_userInfo
                         to: YES
                    success:^(id responseObject) {
                        [weakSelf indicateFollowing];
                        
                        NSLog (@"SUCCESSFULLY FOLLOWED USER");
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                        NSLog (@"FAILED TO FOLLOW/UNFOLLOW USER");
                    }];
}

//------------------------------------------------------------------------------
// Name:    layoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    
    _backgroundImageView.frame= CGRectMake(0,0,w,h-kGeomHeightFilters);
    _backgroundImageFade.frame= CGRectMake(0,0,w,h-kGeomHeightFilters);
    _backgroundImageView.backgroundColor= YELLOW;
    int y = kGeomSpaceEdge;
    _userView.frame = CGRectMake((w-kGeomProfileImageSize)/2, y, kGeomProfileImageSize, kGeomProfileImageSize);
    _viewHalo.frame = _userView.frame;
    _viewHalo.layer.cornerRadius=kGeomProfileImageSize/2;
    
    [_buttonFollowers sizeToFit];
    [_buttonFollowees sizeToFit];
    [_buttonFollowersCount sizeToFit];
    [_buttonFolloweesCount sizeToFit];
    float upperLabelHeight=  20;
    float lowerLabelHeight= 18;
    float horizontalSpaceForText=  (320-kGeomProfileImageSize)/2;
    y= (kGeomProfileImageSize +2*kGeomSpaceEdge -upperLabelHeight-lowerLabelHeight)/2;
    float leftX= w/2 - kGeomProfileImageSize/2  - horizontalSpaceForText;
    float rightX= w/2 + kGeomProfileImageSize/2;
    _buttonFollowersCount.frame = CGRectMake(leftX, y, horizontalSpaceForText, upperLabelHeight);
    _buttonFolloweesCount.frame = CGRectMake(rightX, y, horizontalSpaceForText, upperLabelHeight);
    y+=upperLabelHeight;
    _buttonFollowers.frame = CGRectMake(leftX, y, horizontalSpaceForText, lowerLabelHeight);
    _buttonFollowees.frame = CGRectMake(rightX, y, horizontalSpaceForText, lowerLabelHeight);
    
    y=kGeomSpaceEdge+kGeomProfileImageSize+kGeomSpaceInter;
    _buttonFollow.frame = CGRectMake(w/2-kGeomButtonWidth/2,y+(kGeomProfileStatsItemHeight-kGeomFollowButtonHeight)/2,
                                     kGeomButtonWidth, kGeomFollowButtonHeight );
    
    // Layout the statistics labels.
    float x= (w-3*kGeomProfileStatsItemWidth)/2;
    _labelVenuesCount.frame = CGRectMake(x,y,kGeomProfileStatsItemWidth,kGeomProfileStatsItemHeight/2);
    _labelVenues.frame = CGRectMake(x,y +kGeomProfileStatsItemHeight/2,kGeomProfileStatsItemWidth,kGeomProfileStatsItemHeight/2);
    x += kGeomProfileStatsItemWidth;
    _labelPhotoCount.frame = CGRectMake(x,y,kGeomProfileStatsItemWidth,kGeomProfileStatsItemHeight/2);
    _labelPhoto.frame = CGRectMake(x,y +kGeomProfileStatsItemHeight/2,kGeomProfileStatsItemWidth,kGeomProfileStatsItemHeight/2);
    x += kGeomProfileStatsItemWidth;
    _labelLikesCount.frame = CGRectMake(x,y,kGeomProfileStatsItemWidth,kGeomProfileStatsItemHeight/2);
    _labelLikes.frame = CGRectMake(x,y +kGeomProfileStatsItemHeight/2,kGeomProfileStatsItemWidth,kGeomProfileStatsItemHeight/2);
    
    y += kGeomProfileStatsItemHeight + kGeomSpaceInter;
    
    _buttonDescription.frame = CGRectMake(0, h-kGeomHeightFilters-kGeomProfileTextviewHeight, w,kGeomProfileTextviewHeight);
    y += kGeomProfileTextviewHeight;
    
    _filterView.frame = CGRectMake(0, h-kGeomHeightFilters, w, kGeomHeightFilters);
}

@end

//==============================================================================
@interface ProfileVC ()

@property (nonatomic, strong) UICollectionView *cv;
@property (nonatomic, strong) ProfileVCCVLayout *listsAndPhotosLayout;

@property (nonatomic,assign) BOOL viewingLists; // false => viewing photos
@property (nonatomic, strong) NSArray *arrayLists;
@property (nonatomic,strong) NSArray *arrayPhotos;

@property (nonatomic, strong) UserObject *profileOwner;
@property (nonatomic, assign) BOOL viewingOwnProfile;
@property (nonatomic, strong) UIAlertController *optionsAC;
@property (nonatomic,strong) ProfileHeaderView* topView;
@property (nonatomic,assign) BOOL didFetch;
@property (nonatomic,assign) NSUInteger lastShownUser;
@property (nonatomic,assign) MediaItemObject* mediaItemBeingEdited;
@property (nonatomic,strong) RestaurantPickerVC* restaurantPicker;
@property (nonatomic,strong) UIImage* imageToUpload;
@end

@implementation ProfileVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
    
    if (_lastShownUser && _lastShownUser != _userInfo.userID) {
        _didFetch=NO;
        _lastShownUser = _userInfo.userID;
    }
    
    if (!_didFetch) {
        _didFetch=YES;
        [self  refetch ];
    }
    
}

- (void)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];
    
    _userID = 0;
    _viewingLists= YES;
    
    _arrayLists = @[];
    _arrayPhotos= @[];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    
    [self registerForNotification: kNotificationRestaurantListsNeedsUpdate
                          calling:@selector(handleRestaurantListAltered:)
     ];
    [self registerForNotification: kNotificationPhotoDeleted
                          calling:@selector(handlePhotoDeleted:)
     ];
    // NOTE:  Unregistered in dealloc.
    
    // Ascertain whether reviewing our own profile based on passed-in UserObject pointer.
    //
    if (!_userInfo) {
        _viewingOwnProfile=YES;
        UserObject *userInfo = [Settings sharedInstance].userObject;
        self.profileOwner = userInfo;
    } else {
        self.profileOwner = _userInfo;
        
        UserObject *currentUser = [Settings sharedInstance].userObject;
        NSUInteger ownUserIdentifier = [currentUser userID];
        _viewingOwnProfile = _userInfo.userID == ownUserIdentifier;
    }
    
    if ( _viewingOwnProfile) {
        [self setRightNavWithIcon:kFontIconAdd target:self action:@selector(handleUpperRightButton)];
        
    } else {
        [self setRightNavWithIcon:@"" target:nil action:nil];
    }
    
    _lastShownUser = _userInfo.userID;
    
    NSUInteger totalControllers= self.navigationController.viewControllers.count;
    if (totalControllers  == 1) {
        [self setLeftNavWithIcon:kFontIconMenu target:self action:@selector(showOptions)];
    } else {
        [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:) ];
    }
    
    self.listsAndPhotosLayout= [[ProfileVCCVLayout alloc] init];
    _listsAndPhotosLayout.delegate= self;
    [_listsAndPhotosLayout setShowingLists: YES];
    
    _cv = makeCollectionView(self.view, self, _listsAndPhotosLayout);
#define PROFILE_CV_PHOTO_CELL  @"profilephotocell"
#define PROFILE_CV_LIST_CELL  @"profilelistCell"
#define PROFILE_CV_HEADER_CELL  @"profileHeaderCell"
    
    // NOTE: When _viewingLists==YES, use ProfileCVListRow else use PhotoCVCell.
    [_cv registerClass:[PhotoCVCell class] forCellWithReuseIdentifier: PROFILE_CV_PHOTO_CELL];
    [_cv registerClass:[ListStripCVCell class] forCellWithReuseIdentifier: PROFILE_CV_LIST_CELL];
    
    [_cv registerClass:[ProfileHeaderView class ] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
   withReuseIdentifier:PROFILE_CV_HEADER_CELL];
    
    NSString *string= _profileOwner.username.length ? concatenateStrings( @"@", _profileOwner.username) :  @"Missing username";
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: string
                                                       subHeader:nil];
    [self setNavTitle:nto];
    
    __weak ProfileVC *weakSelf = self;
    if  (!_profileOwner.mediaItem) {
        [_profileOwner refreshWithSuccess:^{
            ProfileHeaderView *view= (ProfileHeaderView*) [weakSelf collectionView: weakSelf.cv
                                                 viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                                                       atIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]
                                                           ];
            [view setUserInfo: weakSelf.profileOwner];
        } failure:^{
            NSLog  (@"UNABLE TO REFRESH USER OBJECT.");
        }
         ];
    }
}

- (void)handlePhotoDeleted: (NSNotification*)not
{
    [self refetch];
}

- (void)handleRestaurantListAltered: (NSNotification*)not
{
    [self refetch];
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.cv.frame = self.view.bounds;
    
}

- (void) refetch
{
    __weak  ProfileVC *weakSelf = self;
    OOAPI *api = [[OOAPI alloc] init];
    [api getListsOfUser:((_userID) ? _userID : _profileOwner.userID) withRestaurant:0
                success:^(NSArray *foundLists) {
                    NSLog (@"NUMBER OF LISTS FOR USER:  %ld", (long)foundLists.count);
                    weakSelf.arrayLists = foundLists;
                    ON_MAIN_THREAD(^(){
                        [weakSelf.listsAndPhotosLayout  invalidateLayout];
                        [weakSelf.cv reloadData];
                    });
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                    NSLog  (@"ERROR WHILE GETTING LISTS FOR USER: %@",e);
                }];
    
    float w=  [UIScreen mainScreen ].bounds.size.width;
    [OOAPI getPhotosOfUser:_profileOwner.userID maxWidth: w maxHeight:0
                   success:^(NSArray *mediaObjects) {
                       weakSelf.arrayPhotos= mediaObjects;
                       NSLog (@"NUMBER OF PHOTOS FOR USER:  %ld", (long)_arrayPhotos.count);
                       ON_MAIN_THREAD(^(){
                           [weakSelf.cv  reloadData];
                       });
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog  (@"FAILED TO GET PHOTOS");
                   }];
}

//------------------------------------------------------------------------------
// Name:    userPressedUpperRightButton
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedLowerRightButton:(id)sender
{
    if  (_viewingLists ) {
        [self userPressedNewList];
    } else {
        [self userPressedNewPhoto];
    }
}

- (void)userPressedNewPhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        message( @"This app doesn't have access to the camera.");
        return;
    }
    
    UIImagePickerController *ic = [[UIImagePickerController alloc] init];
    [ic setAllowsEditing:NO];
    [ic setSourceType:UIImagePickerControllerSourceTypeCamera];
    [ic setShowsCameraControls:YES];
    [ic setDelegate:self];
    [self presentViewController:ic animated:YES completion:NULL];
}

//------------------------------------------------------------------------------
// Name:    didFinishPickingMediaWithInfo
// Purpose:
//------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image=  info[@"UIImagePickerControllerEditedImage"];
    if (!image) {
        image = info[@"UIImagePickerControllerOriginalImage"];
    }
    
    if (image && [image isKindOfClass:[UIImage class]]) {
        CGSize s = image.size;
        if (s.width) {
            _imageToUpload = [UIImage imageWithImage:image scaledToSize:CGSizeMake(kGeomUploadWidth, kGeomUploadWidth*s.height/s.width)];
        }
    }
    
    __weak ProfileVC *weakSelf = self;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf showRestaurantPicker];
    }];
}

- (void)showRestaurantPicker {
    if (_restaurantPicker) return;
    _restaurantPicker = [[RestaurantPickerVC alloc] init];
    _restaurantPicker.view.backgroundColor = UIColorRGBA(kColorBlack);
    _restaurantPicker.delegate = self;
    _restaurantPicker.imageToUpload = _imageToUpload;
    [self.view addSubview:_restaurantPicker.view];
    [_restaurantPicker.view  setNeedsUpdateConstraints];
    
    [self presentViewController: _restaurantPicker animated:YES completion:^{
        
    }];
}

- (void)restaurantPickerVC:(RestaurantPickerVC *)restaurantPickerVC restaurantSelected:(RestaurantObject *)restaurant;
{
    __weak  ProfileVC *weakSelf = self;
    
    if (restaurant.restaurantID) {
        [OOAPI uploadPhoto:_imageToUpload forObject:restaurant
                   success:^{
                       [restaurantPickerVC dismissViewControllerAnimated:YES completion:^{
                           weakSelf.restaurantPicker = nil;
                           [weakSelf refetch];
                           weakSelf.imageToUpload= nil;
                           
                       }];
                   } failure:^(NSError *error) {
                       NSLog(@"Failed to upload photo");
                   }];
    } else {
        [OOAPI convertGoogleIDToRestaurant: restaurant.googleID success:^(RestaurantObject *restaurant) {
            if (restaurant && [restaurant isKindOfClass:[RestaurantObject class]]) {
                [OOAPI uploadPhoto:_imageToUpload forObject:restaurant
                           success:^{
                               [restaurantPickerVC dismissViewControllerAnimated:YES completion:^{
                                   weakSelf.restaurantPicker = nil;
                                   [weakSelf refetch];
                                   weakSelf.imageToUpload= nil;
                               }];
                           } failure:^(NSError *error) {
                               NSLog(@"Failed to upload photo");
                           }];
                
            } else {
                NSLog(@"Failed to upload photo because didn't get back a restaurant object");
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to upload photo because the google ID was not found");
        }];
    }
}

- (void)restaurantPickerVCCanceled:(RestaurantPickerVC *)restaurantPickerVC;
{
    __weak  ProfileVC *weakSelf = self;
    
    self.imageToUpload= nil;
    [restaurantPickerVC dismissViewControllerAnimated:YES completion:^{
        weakSelf.restaurantPicker = nil;
    }];
}

//------------------------------------------------------------------------------
// Name:    imagePickerControllerDidCancel
// Purpose:
//------------------------------------------------------------------------------
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    message( @"you canceled taking a photo");
    [self  dismissViewControllerAnimated:YES completion:nil];
}

- (void)userPressedNewList
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Create List" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter new list name";
    }];
    
    UIAlertAction *newList = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        OOAPI *api = [[OOAPI alloc] init];
        
        NSString *name = [alert.textFields[0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *string = trimString(name);
        if  (string.length) {
            string = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] uppercaseString]];
        }
        __weak ProfileVC *weakSelf = self;
        [api addList:string
             success:^(ListObject *list) {
                 ON_MAIN_THREAD(^{
                     if (list) {
                         [weakSelf performSelectorOnMainThread:@selector(goToEmptyListScreen:) withObject:list waitUntilDone:NO];
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
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       ;
                                                   }];
    
    [alert addAction:newList];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handleUpperRightButton
{
    if (_viewingLists ) {
        [self userPressedNewList];
    } else {
        [self userPressedNewPhoto];
    }
    
}

- (void)userTappedOnLists
{
    _viewingLists= YES;
    [_listsAndPhotosLayout setShowingLists: YES];
    [self setRightNavWithIcon: kFontIconAdd target:self action:@selector( handleUpperRightButton)];
    
    [_listsAndPhotosLayout  invalidateLayout];
    [self.cv reloadData];
    
}

- (void)userTappedOnPhotos
{
    _viewingLists= NO;
    [_listsAndPhotosLayout setShowingLists: NO];
    [self setRightNavWithIcon:kFontIconPhoto target:self action:@selector( handleUpperRightButton)];
    [_listsAndPhotosLayout  invalidateLayout];
    [self.cv reloadData];
}

#pragma mark - Collection View stuff

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:( ProfileVCCVLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if  (_viewingLists ) {
        return kGeomHeightStripListRow;
    } else {
        NSInteger row= indexPath.row;
        MediaItemObject* object=  row <_arrayPhotos.count ? _arrayPhotos[row] :nil;
        if  (object ) {
            float w=  object.width;
            float  h=  object.height;
            float  aspect= h>0? w/h: .05;
            float availableWidth= [ UIScreen mainScreen ].bounds.size.width / 2;
            float height= availableWidth/aspect;
            return height;
        } else {
            return 10;
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger total;
    if  (_viewingLists ) {
        total=  self.arrayLists.count;
    } else {
        total=  self.arrayPhotos.count;
    }
    return total;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return  CGSizeMake([UIScreen mainScreen].bounds.size.width , kGeomProfileFilterViewHeight);
}

- (UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ProfileHeaderView *view = nil;
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        view= [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                 withReuseIdentifier:PROFILE_CV_HEADER_CELL
                                                        forIndexPath:indexPath];
        
        [ view setUserInfo: _profileOwner];
        view.vc = self;
        view.delegate=self;
        return view;
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row= indexPath.row;
    
    if  (_viewingLists ) {
        NSUInteger  total= self.arrayLists.count;
        if  (row>= total ) {
            return nil;
        }
        
        ListStripCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:  PROFILE_CV_LIST_CELL
                                                                          forIndexPath:indexPath ] ;
        
        NSArray *a = self.arrayLists;
        ListObject *listItem = a[row];
        listItem.listDisplayType = KListDisplayTypeStrip;
        
        cell.navigationController = self.navigationController;
        cell.listItem = listItem;
        [cell getRestaurants];
        
        return cell;
    }
    else {
        NSUInteger  total= self.arrayPhotos.count;
        if  (row>= total ) {
            return nil;
        }
        
        PhotoCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:  PROFILE_CV_PHOTO_CELL
                                                                      forIndexPath:indexPath ] ;
        NSArray *a = self.arrayPhotos;
        MediaItemObject *object = a[row];
        cell.mediaItemObject =  object;
        cell.delegate=  self;
        return cell;
    }
}

- (void)photoCell:(PhotoCVCell *)photoCell showProfile:(UserObject *)userObject
{
    if  (_viewingOwnProfile ) {
        NSLog  (@"OWN PROFILE");
        return;
    }
    
}

- (void)photoCell:(PhotoCVCell *)photoCell showPhotoOptions:(MediaItemObject *)mio
{
    __weak  ProfileVC *weakSelf = self;
    if  (_viewingOwnProfile ) {
        
        UIAlertController *a= [UIAlertController alertControllerWithTitle: nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancel = nil;
        cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                          style: UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                              
                                          }];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete photo"
                                                               style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                   [OOAPI deletePhoto:mio
                                                                              success:^{
                                                                                  NSLog  (@"SUCCESS IN DELETING PHOTO");
                                                                                  [weakSelf refetch];
                                                                              }
                                                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                  NSLog  (@"FAILED TO DELETE PHOTO, error=%@",error);
                                                                              }];
                                                               }];
        UIAlertAction *captionAction = [UIAlertAction actionWithTitle:@"Add caption to photo"
                                                                style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                    [weakSelf userAddingCaptionTo:mio];
                                                                }];
        
        [a addAction:cancel];
        [a addAction:deleteAction];
        [a addAction:captionAction];
        
        [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:a animated:YES completion:nil];
        
    } else {
        
        UIAlertController *a= [UIAlertController alertControllerWithTitle: nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancel = nil;
        cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                          style: UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                              
                                          }];
        
        UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"Report photo"
                                                               style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                   [OOAPI deletePhoto:mio
                                                                              success:^{
                                                                                  message( @"You have reported the photo successfully.");
                                                                              }
                                                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                  NSLog  (@"FAILED TO REPORT PHOTO, error=%@",error);
                                                                              }];
                                                                   
                                                               }];
        
        [a addAction:cancel];
        [a addAction:reportAction];
        
        [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:a animated:YES completion:nil];
        
    }
}

- (void)userAddingCaptionTo: ( MediaItemObject*)mediaObject
{
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    self.mediaItemBeingEdited = mediaObject;
    
    OOTextEntryModalVC *vc = [[OOTextEntryModalVC alloc] init];
    vc.delegate = self;
    vc.textLengthLimit= kUserObjectMaximumAboutTextLength;// XX:
    vc.defaultText = mediaObject.caption;
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    [nc addChildViewController:vc];
    
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorBlack)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setShadowImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)]];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController presentViewController:nc animated:YES completion:^{
        nc.topViewController.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }];
}

- (void)textEntryFinished:(NSString*)text;
{
    __weak ProfileVC *weakSelf = self;
    [OOAPI setMediaItemCaption:_mediaItemBeingEdited.mediaItemId
                       caption:text
                       success:^{
                           weakSelf.mediaItemBeingEdited.caption= text;
                           weakSelf.mediaItemBeingEdited= nil;
                           NSLog (@"SUCCESSFULLY SET THE CAPTION OF A PHOTO");
                           
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           weakSelf.mediaItemBeingEdited= nil;
                           NSLog  (@"FAILED TO SET PHOTO CAPTION %@",error);
                       }
     ];
}

- (void)photoCell:(PhotoCVCell *)photoCell likePhoto:(MediaItemObject *)mio
{
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row= indexPath.row;
    if  (_viewingLists ) {
        ListObject*object= _arrayLists[row];
        RestaurantListVC *vc= [[RestaurantListVC  alloc] init];
        vc.listItem=  object;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        NSUInteger row = indexPath.row;
        MediaItemObject* mediaObject=_arrayPhotos[ row];
        NSUInteger restaurantID= mediaObject.restaurantID;
        if  (!restaurantID) {
            [self launchViewPhoto: mediaObject restaurant:nil];
        } else {
            __weak  ProfileVC *weakSelf = self;
            OOAPI *api=[[OOAPI alloc]init];
            [api getRestaurantWithID: stringFromUnsigned(restaurantID)
                              source: kRestaurantSourceTypeOomami
                             success:^(RestaurantObject *restaurant) {
                                 if ( restaurant) {
                                     [weakSelf launchViewPhoto: mediaObject restaurant:restaurant];
                                 } else {
                                     [weakSelf launchViewPhoto: mediaObject restaurant:nil];
                                 }
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 [weakSelf launchViewPhoto: mediaObject restaurant:nil];
                             }];
        }
    }
}

- (void) launchViewPhoto:(MediaItemObject*) mediaObject restaurant:(RestaurantObject*)restaurant
{
    ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];
    [vc setDelegate: self];
    [vc setMio: mediaObject];
    [vc setRestaurant: restaurant];
    [vc.view setNeedsUpdateConstraints];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)viewPhotoVCClosed:(ViewPhotoVC *)viewPhotoVC
{

}

- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showRestaurant:(RestaurantObject *)restaurant
{
    if (!restaurant) {
        return;
    }
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    vc.restaurant = restaurant;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showProfile:(UserObject *)user
{
    ProfileVC *vc = [[ProfileVC alloc] init];
    vc.userInfo = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _arrayPhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index  < _arrayPhotos.count) {
        MediaItemObject *mediaObject= _arrayPhotos[index];
        MWPhoto *photo;
        if (mediaObject.url) {
            photo = [[MWPhoto alloc] initWithURL:[NSURL URLWithString:mediaObject.url]];
            [photo performLoadUnderlyingImageAndNotify];
            photo.caption = mediaObject.caption;
            return photo;
        }
    }
    return nil;
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
    return self.arrayLists.count;
}

//------------------------------------------------------------------------------
// Name:    getNameOfList
// Purpose:
//------------------------------------------------------------------------------
- (NSString *)getNameOfList:(NSInteger)which
{
    NSArray *a= self.arrayLists;
    if  (which < 0 ||  which >= a.count) {
        return  @"";
    }
    return [a objectAtIndex:which];
}

- (void)showOptions {
    _optionsAC = [UIAlertController alertControllerWithTitle:@"" message:@"What would you like to do?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *logout = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
        [[Settings sharedInstance] removeUser];
        [[Settings sharedInstance] removeMostRecentLocation];
        [[Settings sharedInstance] removeDateString];
        [[Settings sharedInstance] removeSearchRadius];
        [APP clearCache];
        [APP.tabBar performSegueWithIdentifier:@"loginUISegue" sender:self];
    }];
    UIAlertAction *manageTags = [UIAlertAction actionWithTitle:@"Manage Tags" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ManageTagsVC *vc = [[ManageTagsVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [_optionsAC addAction:manageTags];
    [_optionsAC addAction:logout];
    [_optionsAC addAction:cancel];
    [self presentViewController:_optionsAC animated:YES completion:nil];
}

@end


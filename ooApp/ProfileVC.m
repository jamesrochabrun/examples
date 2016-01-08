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
#import "RestaurantListVC.h"
#import "UIImage+Additions.h"
#import "AppDelegate.h"
#import "DebugUtilities.h"
#import "OOUserView.h"
#import "ManageTagsVC.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "OOTextEntryVC.h"
#import "OOFilterView.h"
#import "ProfileVCCVLayout.h"
#import "RestaurantListVC.h"
#import "PhotoCVCell.h"

@interface ProfileHeaderView ()
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, assign) BOOL viewingOwnProfile;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UIButton *buttonFollow;
@property (nonatomic, strong) UIButton *buttonDescription;
@property (nonatomic, strong) UILabel *labelFollowees;
@property (nonatomic, strong) UILabel *labelFollowers;
@property (nonatomic, strong) UILabel *labelFolloweesCount;
@property (nonatomic, strong) UILabel *labelFollowersCount;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *backgroundImageFade;
@property (nonatomic,strong) OOFilterView *filterView;
@end

@implementation ProfileHeaderView

- (void)setUserInfo:(UserObject *)u
{
    __weak ProfileHeaderView *weakSelf = self;
    _userInfo= u;
    
    [_userView setUser: _userInfo];
    
    // Ascertain whether reviewing our own profile.
    
    UserObject *currentUser = [Settings sharedInstance].userObject;
    NSUInteger ownUserIdentifier = [currentUser userID];
    _viewingOwnProfile = _userInfo.userID == ownUserIdentifier;
    
    // RULE: Only update the button when we know for sure whose profile is.
    if ( _viewingOwnProfile) {
        [_buttonFollow setTitle: @"This is you!" forState:UIControlStateNormal];
        [_buttonFollow setTitleColor: WHITE forState:UIControlStateNormal];
        _buttonFollow.layer.borderWidth= 0;
    }
    else  {
        self.buttonFollow.selected= NO;
        
        [OOAPI  getFollowersOf: _userInfo.userID
                       success:^(NSArray *users) {
                           
                           [weakSelf.buttonFollow setTitle: @"FOLLOW" forState:UIControlStateNormal];
                           [weakSelf.buttonFollow setTitleColor: YELLOW forState:UIControlStateNormal];
                           weakSelf.buttonFollow.layer.cornerRadius= kGeomCornerRadius;
                           weakSelf.buttonFollow.layer.borderWidth= 1;
                           weakSelf.buttonFollow.layer.borderColor=YELLOW.CGColor;
                           
                           for (UserObject* user   in  users) {
                               if ( user.userID==ownUserIdentifier) {
                                   weakSelf.buttonFollow.selected= YES;
                                   break;
                               }
                           }
                           weakSelf.buttonFollow.enabled= YES;
                           
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
    
    _labelFollowees.alpha= 0;
    _labelFollowers.alpha= 0;
    _labelFolloweesCount.alpha= 0;
    _labelFollowersCount.alpha= 0;
    
    [OOAPI getUserStatsFor:_userInfo.userID
                   success:^(UserStatsObject *stats) {
                       
                       weakSelf.labelFollowersCount.text= stringFromUnsigned(stats.totalFollowers);
                       weakSelf.labelFolloweesCount.text= stringFromUnsigned(stats.totalFollowees);
                       [UIView animateWithDuration:.4
                                        animations:^{
                                            weakSelf.labelFollowees.alpha= 1;
                                            weakSelf.labelFollowers.alpha= 1;
                                            weakSelf.labelFolloweesCount.alpha= 1;
                                            weakSelf.labelFollowersCount.alpha= 1;
                                        }];
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog (@"CANNOT FETCH STATS FOR PROFILE SCREEN.");
                   }];
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self=[ super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews= NO;
        _backgroundImageView=  makeImageView(self, @"profile-background.jpg");
        _backgroundImageFade= makeView( self,  UIColorRGBA(0x80000000));
        
        _filterView= [[OOFilterView alloc] init];
        [self addSubview:_filterView];
        [_filterView addFilter:LOCAL(@"LISTS") target:self selector:@selector(userTappedOnListsFilter:)];//  index 0
        [_filterView addFilter:LOCAL(@"PHOTOS") target:self selector:@selector(userTappedOnPhotosFilter:)];//  index 1
        
        _userView= [[OOUserView alloc] init];
        [self addSubview:_userView];
        
        _labelFollowees=  makeLabel(self, @"FOLLOWING", kGeomFontSizeSubheader );
        _labelFollowers=  makeLabel(self, @"FOLLOWERS", kGeomFontSizeSubheader);
        
        _labelFolloweesCount=  makeLabel(self, @"", kGeomFontSizeHeader);
        _labelFollowersCount=  makeLabel(self, @"", kGeomFontSizeHeader);
        
        _labelFollowersCount.font = [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader];
        _labelFolloweesCount.font = _labelFollowersCount.font;
        
        _buttonDescription=  makeButton(self,  @"", 1, WHITE,
                                        UIColorRGBA(0x80000000),  self,
                                        @selector(userTappedDescription:) , 0);
        _buttonDescription.titleLabel.numberOfLines= 0;
        _buttonDescription.titleLabel.font = [ UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail];
        
        _labelFollowees.textColor = WHITE;
        _labelFollowers.textColor = WHITE;
        _labelFolloweesCount.textColor = WHITE;
        _labelFollowersCount.textColor = WHITE;
        
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        
        self.buttonFollow= makeButton(self, @"",
                                      kGeomFontSizeHeader, CLEAR, CLEAR,
                                      self,
                                      @selector (userPressedFollow:), 0);
        [_buttonFollow setTitle:@"FOLLOWING" forState:UIControlStateSelected];
        _buttonFollow.enabled=NO;
        
    }
    return self;
}

- (void)userTappedDescription:(id)sender
{
    OOTextEntryVC *vc = [[OOTextEntryVC alloc] init];
    vc.defaultText = _userInfo.about;
    vc.textLengthLimit= kUserObjectMaximumAboutTextLength;
    vc.delegate=self;
    [self.vc.navigationController pushViewController:vc animated:YES];
}

- (void)textEntryFinished:(NSString*)text;
{
    __weak ProfileHeaderView *weakSelf = self;
    [OOAPI setAboutInfoFor: _userInfo.userID
                        to:text
                   success:^{
                       [weakSelf.buttonDescription setTitle:text forState: UIControlStateNormal];
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog  (@"FAILED TO SET ABOUT INFO FOR USER");
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
                        weakSelf.buttonFollow.selected= NO;
                        NSLog (@"SUCCESSFULLY UNFOLLOWED USER");
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                        NSLog (@"FAILED TO UNFOLLOW USER");
                    }];
    
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
    
    if ( _buttonFollow.selected) {
        [self verifyUnfollow];
        return;
    }
    
    [_buttonFollow setTitle:@"..." forState:UIControlStateNormal];
    
    [OOAPI setFollowingUser:_userInfo
                         to: !weakSelf.buttonFollow.selected
                    success:^(id responseObject) {
                        weakSelf.buttonFollow.selected= !weakSelf.buttonFollow.selected;
                        
                        [weakSelf.buttonFollow setTitle:@"FOLLOW" forState:UIControlStateNormal];
                        
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
    
    [_labelFollowers sizeToFit];
    [_labelFollowees sizeToFit];
    [_labelFollowersCount sizeToFit];
    [_labelFolloweesCount sizeToFit];
    float upperLabelHeight=  20;
    float lowerLabelHeight= 18;
    float horizontalSpaceForText=  (320-kGeomProfileImageSize)/2;
    y= (kGeomProfileImageSize +2*kGeomSpaceEdge -upperLabelHeight-lowerLabelHeight)/2;
    float leftX= w/2 - kGeomProfileImageSize/2  - horizontalSpaceForText;
    float rightX= w/2 + kGeomProfileImageSize/2;
    _labelFollowersCount.frame = CGRectMake(leftX, y, horizontalSpaceForText, upperLabelHeight);
    _labelFolloweesCount.frame = CGRectMake(rightX, y, horizontalSpaceForText, upperLabelHeight);
    y+=upperLabelHeight;
    _labelFollowers.frame = CGRectMake(leftX, y, horizontalSpaceForText, lowerLabelHeight);
    _labelFollowees.frame = CGRectMake(rightX, y, horizontalSpaceForText, lowerLabelHeight);
    
    y=kGeomSpaceEdge+kGeomProfileImageSize+kGeomSpaceInter;
    _buttonFollow.frame = CGRectMake(w/2-kGeomButtonWidth/2,y,kGeomButtonWidth,  kGeomProfileFollowButtonHeight);
    y += kGeomProfileFollowButtonHeight + kGeomSpaceInter;
    
    _buttonDescription.frame = CGRectMake(kGeomSpaceEdge,h-kGeomHeightFilters-kGeomProfileTextviewHeight,w-2*kGeomSpaceEdge,kGeomProfileTextviewHeight);
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
@property (nonatomic, strong) UIButton *buttonNewList;
@property (nonatomic, strong) UIAlertController *optionsAC;
@property (nonatomic,strong) ProfileHeaderView* topView;
@property (nonatomic,assign) BOOL didFetch;
@property (nonatomic,assign) NSUInteger lastShownUser;
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
        [self  update:nil ];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{

    [super viewDidDisappear: animated];
    
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
                          calling:@selector(update:)
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
        [self setRightNavWithIcon:kFontIconMore target:self action:@selector(showOptions)];
        
        _buttonNewList = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonNewList roundButtonWithIcon:kFontIconAdd fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:0 backgroundColor:kColorBlack target:self selector:@selector(userPressedNewList:)];
        _buttonNewList.frame = CGRectMake(0, 0, kGeomDimensionsIconButton, kGeomDimensionsIconButton);
        
        [self.view addSubview:_buttonNewList];
    } else {
        [self setRightNavWithIcon:@"" target:nil action:nil];
    }
    
    _lastShownUser = _userInfo.userID;
    
    NSUInteger totalControllers= self.navigationController.viewControllers.count;
    if (totalControllers > 1) {
        [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
    }
    
    self.listsAndPhotosLayout= [[ProfileVCCVLayout alloc] init];
    _listsAndPhotosLayout.delegate= self;
    [_listsAndPhotosLayout setShowingLists: YES];
    
    _cv = makeCollectionView(self.view, self, _listsAndPhotosLayout);
#define PROFILE_CV_PHOTO_CELL  @"profilephotocell"
#define PROFILE_CV_LIST_CELL  @"profilelistCell"
#define PROFILE_CV_HEADER_CELL  @"profileHeaderCell"
    
    // NOTE: When _viewingLists==YES, use ProfileCVListRow else use ProfileCVPhotoCell.
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

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.cv.frame = self.view.bounds;
    
    CGFloat x, y, spacer;
    if (_viewingOwnProfile) {
        x = kGeomSpaceEdge;
        _buttonNewList.frame = CGRectMake(width(self.view) - (width(_buttonNewList) + 30), height(self.view) - (height(_buttonNewList) + 30), width(_buttonNewList), height(_buttonNewList));
        y += kGeomHeightButton + spacer;
        [ self.view  bringSubviewToFront:_buttonNewList];
    }
}

- (void)update: (NSNotification*)not
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
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog  (@"FAILED TO GET PHOTOS");
                   }];
}

//------------------------------------------------------------------------------
// Name:    userPressedNewList
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedNewList:(id)sender
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

- (void)userTappedOnLists
{
    _viewingLists= YES;
    [_listsAndPhotosLayout setShowingLists: YES];
    [_listsAndPhotosLayout  invalidateLayout];
    [self.cv  reloadData];
}

- (void)userTappedOnPhotos
{
    _viewingLists= NO;
    [_listsAndPhotosLayout setShowingLists: NO];
    [_listsAndPhotosLayout  invalidateLayout];
    [self.cv  reloadData];
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
    NSLog (@"row= %ld", (long)row);
    
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
        
        cell.listItem = listItem;
        cell.navigationController = self.navigationController;
        
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
        int gray=rand()&0xff;
        gray= gray + ( gray <<8)+ ( gray <<16);
        cell.backgroundColor= UIColorRGB( gray );
        return cell;
    }
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
        MediaItemObject *object= _arrayPhotos[row];
        //  need a viewer VC
    }
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
        
        [self.revealViewController performSegueWithIdentifier:@"loginUISegue" sender:self];
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

//NOTE: Re-using the existing PhotoCVCell
//
//@interface  ProfileCVPhotoCell()
//@property (nonatomic,strong)  UIImageView* imageView;
//@property (nonatomic,strong)  MediaItemObject* mediaObject;
//@end
//
//@implementation ProfileCVPhotoCell
//
//- (instancetype) initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        _imageView= makeImageView(self.contentView, nil);
//        
//    }
//    return self;
//}
//
//- (void)prepareForReuse
//{
//    _mediaObject= nil;
//    _imageView.image= nil;
//}
//
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    _imageView.frame= self.bounds;
//}
//
//- (void)setMediaObject:(MediaItemObject *) mo
//{
//    if  (!mo) {
//        return;
//    }
//    _mediaObject= mo;
//    NSString*string= _mediaObject.url;
//    if (!string) {
//        return;
//    }
//    NSURL *url= [ NSURL URLWithString: string];
//    if  (!url) {
//        return;
//    }
//    [_imageView setImageWithURL: url];
//}
//
//@end


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
#import "ExploreVC.h"
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
#import "LocationManager.h"
#import "SocialMedia.h"
#import "UIButton+AFNetworking.h"
#import "ShowMediaItemAnimator.h"
#import "SpecialtyObject.h"

@interface ProfileHeaderView ()
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, assign) BOOL viewingOwnProfile;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UIButton *buttonFollow;
@property (nonatomic, strong) UIButton *buttonDescription;
@property (nonatomic, strong) UIButton *buttonFollowees;
@property (nonatomic, strong) UIButton *buttonFollowers;
@property (nonatomic, strong) UIButton *buttonFolloweesCount;
@property (nonatomic, strong) UIButton *buttonFollowersCount;
@property (nonatomic, strong) UILabel *labelVenuesCount, *labelPhotoCount, *labelLikesCount;
@property (nonatomic, strong) UILabel *labelVenues, *labelPhoto, *labelLikes;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *backgroundImageFade;
@property (nonatomic, strong) OOFilterView *filterView;
@property (nonatomic, assign) BOOL followingThisUser;
@property (nonatomic, strong) UIButton *buttonSettings,*buttonSettingsInner;
@property (nonatomic, assign) BOOL usingURLButton;
@property (nonatomic, strong) UIButton *buttonURL;
@property (nonatomic, strong) UILabel *labelSpecialtyHeader;
@property (nonatomic, strong) UILabel *labelSpecialties;
@property (nonatomic, strong) UIView *viewSpecialties;
@end

@implementation ProfileHeaderView

- (void) enableURLButton
{
    _usingURLButton= YES;
    _buttonURL.hidden= NO;
    _buttonURL.enabled= YES;
}

- (void)registerForNotification:(NSString *)name calling:(SEL)selector
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:selector
                   name:name
                 object:nil];
}

- (void)unregisterFromNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)setUserInfo:(UserObject *)u
{
    if (u == _userInfo) return;
    _userInfo = u;
    
    [self loadUserInfo];
}

- (void)refreshUserImage
{
    [_userView clear];
    [_userView setUser:_userInfo];
}

- (void)updateUserStats:(NSNotification*)not
{
    NSNumber *userNumber = not.object;
    NSUInteger userid = [userNumber isKindOfClass:[NSNumber class]] ? userNumber.unsignedIntegerValue:0;
    UserObject *currentUser = [Settings sharedInstance].userObject;
    if (userid == currentUser.userID) {
        [self refreshUserStats];
    }
}

- (void)refreshUserStats
{
    __weak ProfileHeaderView *weakSelf = self;

    [OOAPI getUserStatsFor:_userInfo.userID
                   success:^(UserStatsObject *stats) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [weakSelf.buttonFollowersCount setTitle:stringFromUnsigned(stats.totalFollowers) forState:UIControlStateNormal] ;
                           [weakSelf.buttonFolloweesCount setTitle:stringFromUnsigned(stats.totalFollowees) forState:UIControlStateNormal] ;
                           
                           weakSelf.buttonFollowees.alpha= 1;
                           weakSelf.buttonFollowers.alpha= 1;
                           weakSelf.buttonFolloweesCount.alpha= 1;
                           weakSelf.buttonFollowersCount.alpha= 1;
                           
                           weakSelf.labelPhotoCount.text= stringFromUnsigned(stats.totalPhotos);
                           weakSelf.labelLikesCount.text= stringFromUnsigned(stats.totalLikes);
                           weakSelf.labelVenuesCount.text= stringFromUnsigned(stats.totalVenues);
                           
                           [weakSelf setNeedsLayout];
                       });
                       
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog (@"CANNOT FETCH STATS FOR PROFILE SCREEN.");
                       
                   }];
}

- (void) loadUserInfo
{
    if (!_userInfo) {
        return;
    }
    
    // Ascertain whether reviewing our own profile.
    //
    UserObject *currentUser = [Settings sharedInstance].userObject;
    NSUInteger ownUserIdentifier = [currentUser userID];
    _viewingOwnProfile = _userInfo.userID == ownUserIdentifier;

    __weak ProfileHeaderView *weakSelf = self;
    
    [_userView setUser:_userInfo];
    
    if  (_userInfo.isFoodie) {
        [self enableURLButton];
        
        if (!_userInfo.website.length) {
            if (_viewingOwnProfile) {
                [_buttonURL setTitle:@"Tap here to enter your URL." forState:UIControlStateNormal];
            } else {
                [_buttonURL setTitle:@"This foodie has no web link." forState:UIControlStateNormal];
            }
            [_buttonURL setTitle:@"" forState:UIControlStateNormal]; //For now the url is not editable
        } else {
            [_buttonURL setTitle:_userInfo.website forState:UIControlStateNormal];
        }
        [_buttonURL sizeToFit];
    }
    
    // RULE: Only update the button when we know for sure whose profile is.
    if ( _viewingOwnProfile) {
        NSLog  (@"VIEWING OWN PROFILE.");
        // RULE: Show the user's own stats.
        [self  indicateFollowing];
        [_userView setShowCog];
        [self refreshUserStats];
    }
    else  {
        [OOAPI getFollowersOf:_userInfo.userID
                      success:^(NSArray *users) {
                          BOOL foundSelf = NO;
                          for (UserObject *user in users) {
                              // RULE: If we are following this user then we make the follow button disappear.
                              if (user.userID == ownUserIdentifier) {
                                  foundSelf = YES;
                                  break;
                              }
                          }

                          dispatch_async(dispatch_get_main_queue(), ^{
                              if  (!foundSelf) {
                                  [weakSelf indicateNotFollowing];
                              } else {
                                  [weakSelf indicateFollowing];
                              }
                              [weakSelf refreshUserStats];
                          });
                          
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog(@"CANNOT FETCH FOLLOWERS OF USER");
                          [weakSelf indicateNotFollowing];
                      }];
    }
    
    if  (_userInfo.about.length) {
        [_buttonDescription setTitle:_userInfo.about forState:UIControlStateNormal];
    } else {
        if (_viewingOwnProfile) {
            [_buttonDescription setTitle:@"Tap here and tell us about yourself." forState:UIControlStateNormal ];
        } else {
            NSString *pronoun = @"their";
            
            if (_userInfo.gender.length) {
                unichar ch = [_userInfo.gender characterAtIndex:0];
                if ( ch == 'f' || ch == 'F') {
                    pronoun = @"her";
                } else {
                    pronoun = @"his";
                }
            }

            NSString *expression=[NSString  stringWithFormat: @"This user probably just needs a second to finish %@ meal, stay tuned.", pronoun];
            [_buttonDescription setTitle:expression forState:UIControlStateNormal];
        }
    }
    
    [self layoutSubviews];
    
    _buttonFollowees.alpha = 0;
    _buttonFollowers.alpha = 0;
    _buttonFolloweesCount.alpha = 0;
    _buttonFollowersCount.alpha = 0;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = NO;
        self.clipsToBounds = YES;

        _backgroundImageView = makeImageView(self, @"background-image.jpg");
        _backgroundImageFade = makeView( self, UIColorRGBA(0x80000000));

        _filterView= [[OOFilterView alloc] init];
        [self addSubview:_filterView];
        [_filterView addFilter:LOCAL(@"LISTS") target:self selector:@selector(userTappedOnListsFilter:)];//  index 0
        [_filterView addFilter:LOCAL(@"PHOTOS") target:self selector:@selector(userTappedOnPhotosFilter:)];//  index 1
        
        _userView= [[OOUserView alloc] init];
        _userView.delegate= self;
        [self addSubview:_userView];
        
        self.viewSpecialties=makeView(self, BLACK);
        self.labelSpecialtyHeader=  makeLabel( _viewSpecialties,  @"Specialties:", kGeomFontSizeSubheader);
        _labelSpecialtyHeader.font= [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeSubheader];
        self.labelSpecialties=  makeLabel( _viewSpecialties,  @"", kGeomFontSizeSubheader);
        _labelSpecialtyHeader.textColor=WHITE;
        _labelSpecialties.textColor=WHITE;
        _labelSpecialtyHeader.backgroundColor=BLACK;
        _labelSpecialties.backgroundColor=BLACK;
        
        self.buttonURL=makeButton(self, @"URL", kGeomFontSizeSubheader, YELLOW, CLEAR,  self, @selector(userPressedURLButton:), 0);
        _buttonURL.hidden= YES;
        
        _buttonFollowees= makeButton(self, @"FOLLOWING", kGeomFontSizeSubheader, YELLOW, CLEAR,  self, @selector(userPressedFollowees:), 0);
        _buttonFollowers= makeButton(self, @"FOLLOWERS", kGeomFontSizeSubheader, YELLOW, CLEAR,  self, @selector(userPressedFollowers:), 0);
        
        _buttonFolloweesCount= makeButton(self, @"", kGeomFontSizeHeader, WHITE, CLEAR,  self, @selector(userPressedFollowees:), 0);
        _buttonFollowersCount= makeButton(self, @"", kGeomFontSizeHeader, WHITE, CLEAR,  self, @selector(userPressedFollowers:), 0);
        
        _buttonFollowersCount.titleLabel.font = [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader];
        _buttonFolloweesCount.titleLabel.font = _buttonFollowersCount.titleLabel.font;
        
        _buttonDescription = makeButton(self,  @"", 1, WHITE,
                                        BLACK,  self,
                                        @selector(userTappedDescription:) , 0);
        _buttonDescription.contentEdgeInsets = UIEdgeInsetsMake(0, kGeomSpaceEdge, 0, kGeomSpaceEdge);
        _buttonDescription.titleLabel.numberOfLines= 0;
        _buttonDescription.titleLabel.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeAbout];
        
        _labelVenuesCount= makeLabel(self,  @"", kGeomFontSizeStatsText);
        _labelPhotoCount= makeLabel(self,  @"", kGeomFontSizeStatsText);
        _labelLikesCount= makeLabel(self,  @"", kGeomFontSizeStatsText);
        _labelVenues= makeIconLabel(self, kFontIconPin, kGeomFontSizeStatsIcons);
        _labelPhoto= makeIconLabel(self, kFontIconPhoto, kGeomFontSizeStatsIcons);
        _labelLikes= makeIconLabel(self, kFontIconYum, kGeomFontSizeStatsIcons);
        
        _labelVenuesCount.textColor= WHITE;
        _labelPhotoCount.textColor= WHITE;
        _labelLikesCount.textColor= WHITE;
        _labelVenues.textColor= WHITE;
        _labelPhoto.textColor= WHITE;
        _labelLikes.textColor= WHITE;

        _labelVenuesCount.textAlignment= NSTextAlignmentLeft;
        _labelPhotoCount.textAlignment= NSTextAlignmentLeft;
        _labelLikesCount.textAlignment= NSTextAlignmentLeft;
        
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        
        self.buttonFollow= makeButton(self, @"FOLLOW",
                                       kGeomFontSizeSubheader, BLACK, YELLOW,
                                       self,
                                       @selector(userPressedFollow:), 0);
        [_buttonFollow setTitle:@"FOLLOWING" forState:UIControlStateSelected];
        [_buttonFollow setTitleColor:WHITE forState:UIControlStateSelected];
        _buttonFollow.layer.borderColor=YELLOW.CGColor;
        _buttonFollow.layer.cornerRadius= kGeomCornerRadius;
        _buttonFollow.layer.borderWidth= 1;
        _buttonFollow.hidden= YES;
        
        [self registerForNotification:kNotificationUserStatsChanged
                              calling:@selector(updateUserStats:)
         ];
        [self registerForNotification:kNotificationOwnProfileNeedsUpdate
                              calling:@selector(updateOwnProfile:)
         ];
        
        self.backgroundColor=BLACK;
    }
    return self;
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user;
{
    [self.delegate userPressedSettings];
}

- (void)updateSpecialtiesLabel
{
    if (!_userInfo.specialties.count) {
        _labelSpecialties.text = @"None";
        return;
    }
    
    if (_userInfo.specialties.count != 1)
        _labelSpecialtyHeader.text = @"Specialties:";
    else
        _labelSpecialtyHeader.text = @"Specialty:";
    
    NSString *specialtyString;
    NSMutableArray *s = [NSMutableArray array];
    for (SpecialtyObject *object in _userInfo.specialties) {
        [s addObject:[NSString stringWithFormat:@"#%@",object.name]];
    }
    
    specialtyString = [s componentsJoinedByString:@", "];
    _labelSpecialties.text= specialtyString;
}

- (void)userPressedURLButton: (id) sender
{
    NSString *urlString= _userInfo.website;
    if  (!urlString) {
        return;
    }
    NSString *urlStringLower = [_userInfo.website lowercaseString ];
    if  (![urlStringLower hasPrefix: @"http://"] && ![urlStringLower hasPrefix: @"https://"]) {
        urlString= concatenateStrings(@"http://", urlString);
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
}

- (void)userPressedSettings: (id) sender
{
    [self.delegate userPressedSettings];
}

- (void)updateOwnProfile: (NSNotification*)not
{
    if ( !_viewingOwnProfile) {
        return;
    }
    [self refreshUserImage];
    [self loadUserInfo];
}

- (void)fetchFollowers
{
    __weak ProfileHeaderView *weakSelf = self;
    
    [OOAPI getFollowersOf:_userInfo.userID
                  success:^(NSArray *users) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if  (!users.count) {
                              if (_userInfo.userID == [Settings sharedInstance].userObject.userID) {
                                  [APP.tabBar setSelectedIndex: kTabIndexConnect];
                              }
                              NSLog  (@"NO FOLLOWERS");
                              return ;
                          }
                          
                          UserListVC *vc = [[UserListVC alloc] init];
                          vc.desiredTitle = @"FOLLOWERS";
                          vc.usersArray = users.mutableCopy;
                          vc.user = _userInfo;
                          [weakSelf.vc.navigationController pushViewController:vc animated:YES];
                          
                          NSLog (@"SUCCESS IN FETCHING %lu FOLLOWERS", (unsigned long)users.count);
                      });
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog  (@"UNABLE TO FETCH FOLLOWERS");
                  }     ];
}

- (void)userPressedFollowers: (id) sender
{
    if  (self.vc.uploading) {
        return;
    }
    
    [self fetchFollowers];
}

- (void)fetchFollowing
{
    __weak  ProfileHeaderView *weakSelf = self;
    
    [OOAPI getFollowingOf:_userInfo.userID
                  success:^(NSArray *users) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if  (!users.count) {
                              if (_userInfo.userID == [Settings sharedInstance].userObject.userID) {
                                  [APP.tabBar setSelectedIndex:kTabIndexConnect];
                              }

                              NSLog  (@"NO FOLLOWEES");
                              return ;
                          }
                          UserListVC *vc = [[UserListVC alloc] init];
                          vc.user= _userInfo;
                          vc.desiredTitle = @"Following";
                          vc.usersArray = users.mutableCopy;
                          [weakSelf.vc.navigationController pushViewController: vc animated:YES];
                          NSLog(@"SUCCESS IN FETCHING %lu FOLLOWEES", (unsigned long)users.count);
                      });
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"CANNOT GET LIST OF PEOPLE WE ARE FOLLOWING");
                  }];
    
}

- (void)userPressedFollowees:(id)sender
{
    if  (self.vc.uploading) {
        return;
    }
    [self fetchFollowing];
}

- (void)userTappedDescription:(id)sender
{
    if (! _viewingOwnProfile) {
        return;
    }
    
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
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [weakSelf.buttonDescription setTitle:text forState: UIControlStateNormal];
                       });
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog(@"FAILED TO SET ABOUT INFO FOR USER");
                   }
     ];
}

- (void)userTappedOnListsFilter:(id)sender
{
    [self.delegate userTappedOnLists];
}

- (void)userTappedOnPhotosFilter:(id)sender
{
    [self.delegate performSelector:@selector(userTappedOnPhotos)
                         withObject:nil
                         afterDelay:.1
     ];
}

- (void) verifyUnfollow
{
    __weak ProfileHeaderView *weakSelf = self;

    UIAlertController *a = [UIAlertController alertControllerWithTitle:LOCAL(@"Really Un-follow?")
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [weakSelf doUnfollow];
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf indicateNotFollowing];
                            NSLog (@"SUCCESSFULLY UNFOLLOWED USER");
                        });
                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                        NSLog (@"FAILED TO UNFOLLOW USER");
                    }];
}

- (void)indicateFollowing
{
    _buttonFollow.selected= YES;
    _followingThisUser=YES;
    _buttonFollow.backgroundColor = UIColorRGBA(kColorBlack);
    _buttonFollow.layer.borderWidth= 1;
    _buttonFollow.hidden= NO;
}

- (void)indicateNotFollowing
{
    _followingThisUser=NO;
    _buttonFollow.selected= NO;
    _buttonFollow.backgroundColor= YELLOW;
    _buttonFollow.layer.borderWidth= 0;
    _buttonFollow.hidden= NO;

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
    
    CGFloat w = width(self);
    CGFloat h = height(self);
    CGFloat spacing=  kGeomSpaceInter;
    
    _backgroundImageView.frame = CGRectMake(0, 0, w, h-kGeomHeightFilters);
    _backgroundImageFade.frame = CGRectMake(0, 0, w, h-kGeomHeightFilters);
    _backgroundImageView.backgroundColor = YELLOW;
    NSUInteger y = kGeomSpaceEdge;
    _userView.frame = CGRectMake((w-kGeomProfileImageSize)/2, y, kGeomProfileImageSize, kGeomProfileImageSize);
    
    const  float buttonSettingsSize= _viewingOwnProfile? 30:0;
    _buttonSettings.frame = CGRectMake(_userView.frame.origin.x+kGeomProfileImageSize-buttonSettingsSize,
                                       y + kGeomProfileImageSize-buttonSettingsSize,
                                       buttonSettingsSize,buttonSettingsSize);
    _buttonSettingsInner.frame= _buttonSettings.frame;
    y += kGeomProfileImageSize + spacing;

    [_buttonFollowers sizeToFit];
    [_buttonFollowees sizeToFit];
    [_buttonFollowersCount sizeToFit];
    [_buttonFolloweesCount sizeToFit];
    float upperLabelHeight=  20;
    float lowerLabelHeight= 18;
    float horizontalSpaceForText=  (320-kGeomProfileImageSize)/2;
    float yFollowers = (kGeomProfileImageSize +2*kGeomSpaceEdge -upperLabelHeight-lowerLabelHeight)/2;
    
    float leftX= w/2 - kGeomProfileImageSize/2  - horizontalSpaceForText;
    float rightX= w/2 + kGeomProfileImageSize/2;
    _buttonFollowersCount.frame = CGRectMake(leftX, yFollowers, horizontalSpaceForText, upperLabelHeight);
    _buttonFolloweesCount.frame = CGRectMake(rightX, yFollowers, horizontalSpaceForText, upperLabelHeight);
    yFollowers +=upperLabelHeight;
    _buttonFollowers.frame = CGRectMake(leftX, yFollowers, horizontalSpaceForText, lowerLabelHeight);
    _buttonFollowees.frame = CGRectMake(rightX, yFollowers, horizontalSpaceForText, lowerLabelHeight);
    
    // Layout the statistics labels.
    [_labelVenues sizeToFit];
    [_labelVenuesCount sizeToFit];
    [_labelPhoto sizeToFit];
    [_labelPhotoCount sizeToFit];
    [_labelLikes sizeToFit];
    [_labelLikesCount sizeToFit];
    float w1 = width(_labelVenues);
    float w2 = width(_labelVenuesCount);
    float w3 = width(_labelPhoto);
    float w4 = width(_labelPhotoCount);
    float w5 = width(_labelLikes);
    float w6 = width(_labelLikesCount);
    float x = (w-w1-w2-w3-w4-w6-w5-2*kGeomSpaceInter)/2;
    _labelVenues.frame = CGRectMake(x,y ,w1,kGeomProfileStatsItemHeight);
    x += w1;
    
    _labelVenuesCount.frame = CGRectMake(x,y,w2,kGeomProfileStatsItemHeight);
    x += w2+kGeomSpaceInter;
    
    _labelPhoto.frame = CGRectMake(x,y ,w3,kGeomProfileStatsItemHeight);
    x += w3;
    
    _labelPhotoCount.frame = CGRectMake(x,y,w4,kGeomProfileStatsItemHeight);
    x += w4 +kGeomSpaceInter;
    
    _labelLikes.frame = CGRectMake(x,y ,w5,kGeomProfileStatsItemHeight);
    x += w5;
    
    _labelLikesCount.frame = CGRectMake(x,y,w6,kGeomProfileStatsItemHeight);

    y +=kGeomProfileStatsItemHeight;
    
    if ( !_viewingOwnProfile) {
        _buttonFollow.frame = CGRectMake(w/2-kGeomButtonWidth/2,
                                         y+(kGeomProfileStatsItemHeight-kGeomFollowButtonHeight)/2,
                                         kGeomButtonWidth,  kGeomFollowButtonHeight );
        y += PROFILE_HEADERVIEW_FOLLOW_HEIGHT;
    }
    
    if ( _userInfo.isFoodie && _userInfo.website.length) {
        _buttonURL.frame = CGRectMake(0, y, w,kGeomProfileHeaderViewHeightOfBloggerButton);
        y += PROFILE_HEADERVIEW_URL_HEIGHT;
    }
    
    _buttonDescription.frame = CGRectMake(0, y, w,kGeomProfileTextviewHeight);
    y += kGeomProfileTextviewHeight;
    
    if (_userInfo.hasSpecialties ) {
        _viewSpecialties.frame= CGRectMake(0,y,w, PROFILE_HEADERVIEW_SPECIALTIES_HEIGHT);
        [_labelSpecialtyHeader sizeToFit];
        [_labelSpecialties sizeToFit];
        float requiredHeaderHeight=_labelSpecialtyHeader.frame.size.height;
        float requiredSpecialtiesHeight=_labelSpecialtyHeader.frame.size.height;
        float yHeader= 0;
        _labelSpecialtyHeader.frame= CGRectMake(0,yHeader,w, requiredHeaderHeight);
        yHeader +=requiredHeaderHeight;
        _labelSpecialties.frame= CGRectMake(0,yHeader,w, requiredSpecialtiesHeight);
        y += PROFILE_HEADERVIEW_SPECIALTIES_HEIGHT;
        
    } else {
        _labelSpecialtyHeader.frame= CGRectMake(0,y,w, 0);
        _labelSpecialties.frame= CGRectMake(0,y,w, 0);
    }
    
    _filterView.frame = CGRectMake(0, y, w, kGeomHeightFilters);
    [self bringSubviewToFront:_filterView];
    _filterView.userInteractionEnabled=YES;
    y+=kGeomHeightFilters;
    
    self.frame= CGRectMake(0,0,w,y);
}

@end

//==============================================================================
@interface ProfileVC ()

@property (nonatomic, strong) UICollectionView *cv;
@property (nonatomic, strong) ProfileVCCVLayout *listsAndPhotosLayout;

@property (nonatomic, strong) NSArray *arrayLists;
@property (nonatomic, strong) NSArray *arrayPhotos;

@property (nonatomic, strong) UserObject *profileOwner;
@property (nonatomic, assign) BOOL viewingOwnProfile;
@property (nonatomic, strong) UIAlertController *optionsAC;
@property (nonatomic, strong) ProfileHeaderView *headerView;
@property (nonatomic, assign) BOOL didFetchUserObject;
@property (nonatomic, assign) BOOL didFetchStats;
@property (nonatomic, assign) NSUInteger lastShownUser;
@property (nonatomic, assign) MediaItemObject *mediaItemBeingEdited;
@property (nonatomic, strong) RestaurantPickerVC *restaurantPicker;
@property (nonatomic, strong) UIImage *imageToUpload;
@property (nonatomic, strong) RestaurantObject *selectedRestaurant;
@property (nonatomic, assign) BOOL viewingLists; // false => viewing photos
@property (nonatomic, assign) BOOL pickerIsForRestaurants;
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
    
    [self checkThatStatsAreUpToDate];
//    if (_lastShownUser && _lastShownUser != _userInfo.userID) {
//        _didFetchStats = NO;
//        _lastShownUser = _userInfo.userID;
//    }
    
//    __weak  ProfileVC *weakSelf = self;
//    if ( !_didFetchUserObject) {
//        [_profileOwner refreshWithSuccess:^(BOOL changed){
//            weakSelf.didFetchUserObject= YES;
//            
//            [weakSelf.cv reloadData ];
//            [weakSelf checkThatStatsAreUpToDate];
//        } failure:^{
//            NSLog  (@"NETWORK ERROR");
//        }];
//    } else {
//        [self checkThatStatsAreUpToDate];
//        
//        // NOTE: There's no explicit requirement to re-fetch the UserObject, but
//        // if we find that it has changed e.g. from a different device updating
//        // the backend, then tell the supplementary view.
//        [_profileOwner refreshWithSuccess:^(BOOL changed){
//            if (changed) {
//                NOTIFY(kNotificationOwnProfileNeedsUpdate);
//            }
//        } failure:^{
//            NSLog  (@"NETWORK ERROR");
//        }];
//    }
}

- (void)checkThatStatsAreUpToDate
{
//    if (!_didFetchStats) {
//        _didFetchStats=YES;
        [self  refetchListsPhotosAndStats ];
//    }
    
}

- (void)done:(id)sender
{
    if  (!self.uploading) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) dealloc
{
    self.headerView = nil;
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
    
    [self.aiv startAnimating];
    
    [self registerForNotification:kNotificationRestaurantListsNeedsUpdate
                          calling:@selector(handleRestaurantListAltered:)
     ];
    [self registerForNotification:kNotificationPhotoDeleted
                          calling:@selector(handlePhotoDeleted:)
     ];
    [self registerForNotification:kNotificationListDeleted
                          calling:@selector(handleListDeleted:)
     ];
    [self registerForNotification:kNotificationListAltered
                          calling:@selector(handleListAltered:)
     ];
    // NOTE:  Unregistered in dealloc.
    
    // Ascertain whether reviewing our own profile based on passed-in UserObject pointer.
    //
    if (!_userInfo) {
        _viewingOwnProfile = YES;
        _didFetchUserObject = NO;
        _userInfo = [Settings sharedInstance].userObject;
        self.profileOwner = _userInfo;
    } else {
        self.profileOwner = _userInfo;
        _didFetchUserObject = YES; // By caller.
        UserObject *currentUser = [Settings sharedInstance].userObject;
        NSUInteger ownUserIdentifier = [currentUser userID];
        _viewingOwnProfile = _userInfo.userID == ownUserIdentifier;
    }
    
    if (_viewingOwnProfile) {
        [self setRightNavWithIcon:kFontIconAdd target:self action:@selector(handleUpperRightButton)];
    } else {
        [self setRightNavWithIcon:@"" target:nil action:nil];
    }
    
//    _lastShownUser = _userInfo.userID;
    
    NSUInteger totalControllers= self.navigationController.viewControllers.count;
    if (totalControllers  == 1) {
        [self setLeftNavWithIcon:nil target:nil action:NULL ];
    } else {
        [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:) ];
    }
    
    self.listsAndPhotosLayout= [[ProfileVCCVLayout alloc] init];
    _listsAndPhotosLayout.delegate= self;
    _listsAndPhotosLayout.userIsSelf=_viewingOwnProfile;
    _listsAndPhotosLayout.userIsFoodie=_userInfo.isFoodie;
    _listsAndPhotosLayout.foodieHasURL = _userInfo.website.length > 0;
    _listsAndPhotosLayout.userHasSpecialties = _userInfo.hasSpecialties;
    [_listsAndPhotosLayout setShowingLists: YES];
    
    _cv = makeCollectionView(self.view, self, _listsAndPhotosLayout);
#define PROFILE_CV_PHOTO_CELL  @"profilephotocell"
#define PROFILE_CV_LIST_CELL  @"profilelistCell"
#define PROFILE_CV_HEADER_CELL  @"profileHeaderCell"
#define PROFILE_CV_EMPTY_CELL  @"profileEmptyCell"    
    
    // NOTE: When _viewingLists==YES, use ProfileCVListRow else use PhotoCVCell.
    [_cv registerClass:[PhotoCVCell class] forCellWithReuseIdentifier: PROFILE_CV_PHOTO_CELL];
    [_cv registerClass:[ListStripCVCell class] forCellWithReuseIdentifier: PROFILE_CV_LIST_CELL];
    [_cv registerClass:[ProfileEmptyCell class] forCellWithReuseIdentifier: PROFILE_CV_EMPTY_CELL];
    [_cv registerClass:[ProfileHeaderView class ] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
   withReuseIdentifier:PROFILE_CV_HEADER_CELL];
    
    NSString *string= _profileOwner.username.length ? concatenateStrings( @"@", _profileOwner.username) :  @"Missing username";
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:string
                                                       subHeader:[NSString stringWithFormat:@"%@ %@", _profileOwner.firstName, _profileOwner.lastName]];
    [self setNavTitle:nto];
    
    [self.view bringSubviewToFront:self.uploadProgressBar];
}

//------------------------------------------------------------------------------
// Name:    handleListAltered
// Purpose: If one of our list objects was deleted then update our UI.
//------------------------------------------------------------------------------
- (void)handleListAltered: (NSNotification*)not
{
    NSLog (@"LIST ALTERED");
    [self getLists];
}

//------------------------------------------------------------------------------
// Name:    handleListDeleted
// Purpose: If one of our list objects was deleted then update our UI.
//------------------------------------------------------------------------------
- (void)handleListDeleted: (NSNotification*)not
{
    NSLog (@"LIST DELETED");
    [self getLists];
}

//------------------------------------------------------------------------------
// Name:    handlePhotoDeleted
// Purpose: If one of our media objects was deleted then update our UI.
//------------------------------------------------------------------------------
- (void)handlePhotoDeleted:(NSNotification*)not
{
    BOOL foundIt = NO;

    NSNumber *mediaObjectIDNumber = not.object;
    NSUInteger mediaObjectID = [mediaObjectIDNumber isKindOfClass: [NSNumber class ]] ?mediaObjectIDNumber.unsignedIntegerValue:0;

    for (MediaItemObject* item in _arrayPhotos) {
        if (item.mediaItemId == mediaObjectID) {
            foundIt = YES;
            break;
        }
    }

    if (foundIt) {
        [self getPhotos];
    }

    [_headerView refreshUserStats];
}

- (void)handleRestaurantListAltered:(NSNotification*)not
{
    [self getLists];
    [_headerView refreshUserStats];
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.cv.frame = self.view.bounds;
    
    CGFloat w = width(self.view);
    self.uploadProgressBar.frame = CGRectMake(0, 0, w, 10);
}

- (void)updateSpecialtiesLabel
{
    [_headerView updateSpecialtiesLabel];
}

- (void)getSpecialties {
    [self.view bringSubviewToFront:self.aiv];
    if (![self.aiv isAnimating]) {
        [self.aiv startAnimating];
        self.aiv.message = @"loading";
    }

    __weak ProfileVC *weakSelf = self;
    [_profileOwner refreshSpecialtiesWithSuccess:^(BOOL changed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateSpecialtiesLabel];
            weakSelf.listsAndPhotosLayout.userHasSpecialties = weakSelf.profileOwner.hasSpecialties;
            [weakSelf.headerView setNeedsLayout];
            [weakSelf.cv setNeedsLayout];
            [weakSelf.cv reloadData];
        });
    } failure:^{
        NSLog (@"UNABLE TO FETCH SPECIALTIES!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.aiv stopAnimating];
            [weakSelf.view sendSubviewToBack: weakSelf.aiv];
        });
    }];
}

- (void)getLists {
    __weak ProfileVC *weakSelf = self;
    [self.view bringSubviewToFront:self.aiv];
    if (![self.aiv isAnimating]) {
        [self.aiv startAnimating];
        self.aiv.message = @"loading";
    }
    
    OOAPI *api = [[OOAPI alloc] init];
    [api getListsOfUser:((_userID) ? _userID : _profileOwner.userID) withRestaurant:0
                success:^(NSArray *foundLists) {
                    NSLog (@"NUMBER OF LISTS FOR USER:  %ld", (long)foundLists.count);
                    weakSelf.arrayLists = foundLists;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.aiv stopAnimating];
                        [weakSelf.view sendSubviewToBack:weakSelf.aiv];
                        [weakSelf.cv reloadData];
                        [weakSelf.headerView refreshUserStats];
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                    NSLog(@"ERROR WHILE GETTING LISTS FOR USER: %@",e);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.aiv stopAnimating];
                        [weakSelf.view sendSubviewToBack:weakSelf.aiv];
                    });
                }];
}

- (void)getPhotos {
    __weak ProfileVC *weakSelf = self;
    [self.view bringSubviewToFront:self.aiv];
    if (![self.aiv isAnimating]) {
        [self.aiv startAnimating];
        self.aiv.message = @"loading";
    }
    
    [OOAPI getPhotosOfUser:_profileOwner.userID maxWidth:width(self.view) maxHeight:0
                   success:^(NSArray *mediaObjects) {
                       weakSelf.arrayPhotos= mediaObjects;
                       weakSelf.listsAndPhotosLayout.thereAreNoItems= mediaObjects.count == 0;
                       NSLog (@"NUMBER OF PHOTOS FOR USER:  %ld", (long)_arrayPhotos.count);
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [weakSelf.aiv stopAnimating];
                           [weakSelf.view sendSubviewToBack: weakSelf.aiv];
                           [weakSelf.cv reloadData];
                           [weakSelf.headerView refreshUserStats];
                       });
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog  (@"FAILED TO GET PHOTOS");
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [weakSelf.aiv stopAnimating];
                           [weakSelf.view sendSubviewToBack: weakSelf.aiv];
                       });
                   }];
}

- (void)refetchListsPhotosAndStats
{
    [self getSpecialties];
    if (_viewingLists) {
        [self getLists];
    } else {
        [self getPhotos];
    }
}

- (void)userPressedNewPhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        message( @"This app doesn't have access to the camera.");
        return;
    }
    
    _pickerIsForRestaurants= YES;
    [self showPickPhotoUI];
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
    if (!image || ![image isKindOfClass:[UIImage class]])
        return;
    
    __weak ProfileVC *weakSelf = self;
    
    if  (_pickerIsForRestaurants ) {
        
        CGSize s = image.size;
        if (s.width) {
            _imageToUpload = [UIImage imageWithImage:image scaledToSize:CGSizeMake(kGeomUploadWidth, kGeomUploadWidth*s.height/s.width)];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            [weakSelf showRestaurantPicker];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            
            [weakSelf setUserPhoto: image];
        }];
        
    }
}

- (void) userPressedEmptyCell;
{
    if ( _viewingOwnProfile) {
        // RULE: Behavior is the same as the upper right button.
        [self handleUpperRightButton];
    }
}

- (void)setUserPhoto: ( UIImage*)image
{
    __weak ProfileVC *weakSelf = self;
    
    [OOAPI uploadPhoto:image forObject: weakSelf.profileOwner
               success:^{
                   [weakSelf.profileOwner refreshWithSuccess:^(BOOL changed){
                       dispatch_async(dispatch_get_main_queue(), ^{
                           NOTIFY(kNotificationOwnProfileNeedsUpdate);
                       });
                   }
                                                     failure:^{
                                                         NSLog (@"FAILED TO UPDATE USER");
                                                     }];
                   
               }
               failure:^(NSError *error) {
                   NSLog  (@"FAILED TO UPLOAD NEW USER PHOTO");
                   message( @"Unable to uploadprofile photo to server at this time.");
               }];
    
    
}

- (void)showRestaurantPicker
{
    if (_restaurantPicker) return;
    
    self.selectedRestaurant= nil;
    
    _restaurantPicker = [[RestaurantPickerVC alloc] init];
    _restaurantPicker.view.backgroundColor = UIColorRGBA(kColorBlack);
    _restaurantPicker.delegate = self;
    _restaurantPicker.location = [LocationManager sharedInstance].currentUserLocation;
    _restaurantPicker.imageToUpload = _imageToUpload;
    
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    [nc addChildViewController:_restaurantPicker];
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorBlack)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setShadowImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)]];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController presentViewController:nc animated:YES completion:^{
        [_restaurantPicker.view setNeedsUpdateConstraints];
    }];
}

- (void)restaurantPickerVC:(RestaurantPickerVC *)restaurantPickerVC restaurantSelected:(RestaurantObject *)restaurant;
{
    self.selectedRestaurant= restaurant;
    __weak  ProfileVC *weakSelf = self;
    
    [restaurantPickerVC dismissViewControllerAnimated:YES completion:^{
        weakSelf.restaurantPicker = nil;
        [weakSelf performUpload];
    }
     ];
}

- (void)restaurantPickerVCCanceled:(RestaurantPickerVC *)restaurantPickerVC;
{
    __weak  ProfileVC *weakSelf = self;
    
    self.imageToUpload = nil;
    [restaurantPickerVC dismissViewControllerAnimated:YES completion:^{
        weakSelf.restaurantPicker = nil;
    }];
}

- (void)performUpload
{
    __weak  ProfileVC *weakSelf = self;
    self.uploading = YES;
    self.uploadProgressBar.hidden = NO;
    
    if (_selectedRestaurant.restaurantID) {
        [OOAPI uploadPhoto:_imageToUpload forObject:_selectedRestaurant
                   success:^(MediaItemObject *mio){
                       dispatch_async(dispatch_get_main_queue(), ^{
                           weakSelf.imageToUpload= nil;
                           weakSelf.uploading= NO;
                           weakSelf.uploadProgressBar.hidden= YES;
                           [weakSelf getPhotos];
                           [weakSelf userAddingCaptionTo:mio];

                           NOTIFY(kNotificationFoodFeedNeedsUpdate);
                       });
                   }
                   failure:^(NSError *error) {
                       NSLog(@"Failed to upload photo");
                       dispatch_async(dispatch_get_main_queue(), ^{
                           weakSelf.uploading = NO;
                           weakSelf.uploadProgressBar.hidden = YES;
                       });
                   }
                  progress:^(NSUInteger __unused bytesWritten,
                             long long totalBytesWritten,
                             long long totalBytesExpectedToWrite) {
                      long double d = totalBytesWritten;
                      d/=totalBytesExpectedToWrite;
                      dispatch_async(dispatch_get_main_queue(), ^{
                          weakSelf.uploadProgressBar.progress = (float)d;
                      });
                  }
         ];
    } else {
        [OOAPI convertGoogleIDToRestaurant: _selectedRestaurant.googleID success:^(RestaurantObject *restaurant) {
            if (restaurant && [restaurant isKindOfClass:[RestaurantObject class]]) {
                [OOAPI uploadPhoto:_imageToUpload forObject:restaurant
                           success:^(MediaItemObject *mio){
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [weakSelf getPhotos];
                                   weakSelf.imageToUpload= nil;
                                   weakSelf.uploading= NO;
                                   weakSelf.uploadProgressBar.hidden= YES;
                                   [weakSelf userAddingCaptionTo:mio];
                                   
                                   NOTIFY(kNotificationFoodFeedNeedsUpdate);
                               });
                           }
                           failure:^(NSError *error) {
                               NSLog(@"Failed to upload photo");
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   weakSelf.uploading = NO;
                                   weakSelf.uploadProgressBar.hidden = YES;
                               });
                           }
                          progress:^(NSUInteger __unused bytesWritten,
                                     long long totalBytesWritten,
                                     long long totalBytesExpectedToWrite) {
                              long double d= totalBytesWritten;
                              d/=totalBytesExpectedToWrite;
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  weakSelf.uploadProgressBar.progress = (float)d;
                              });
                          }
                 ];
                
            } else {
                NSLog(@"Failed to upload photo because didn't get back a restaurant object");
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.uploading = NO;
                    weakSelf.uploadProgressBar.hidden = YES;
                });
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to upload photo because the google ID was not found");
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.uploading = NO;
                weakSelf.uploadProgressBar.hidden = YES;
            });
        }];
    }
    
    
}

//------------------------------------------------------------------------------
// Name:    imagePickerControllerDidCancel
// Purpose:
//------------------------------------------------------------------------------
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
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
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (list) {
                         [weakSelf performSelectorOnMainThread:@selector(goToExploreScreen:) withObject:list waitUntilDone:NO];
                         [weakSelf getLists];
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

- (void)goToExploreScreen:(ListObject *)list
{
    ExploreVC *vc= [[ExploreVC alloc] init];
    vc.listToAddTo= list;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleUpperRightButton
{
    if (_viewingLists) {
        [self userPressedNewList];
    } else {
        _pickerIsForRestaurants= YES;
        [self showPickPhotoUI];
    }
}

- (void)userTappedOnLists
{
    _viewingLists = YES;
    [_listsAndPhotosLayout setShowingLists:YES];
    
    if (_viewingOwnProfile) {
        [self setRightNavWithIcon:kFontIconAdd target:self action:@selector(handleUpperRightButton)];
    }
    
    _listsAndPhotosLayout.thereAreNoItems= _arrayLists.count==0;
//    [_listsAndPhotosLayout invalidateLayout];
//    [self.cv reloadData];
    [self getLists];
    
}

- (void)userTappedOnPhotos
{
    _viewingLists = NO;
    [_listsAndPhotosLayout setShowingLists:NO];
    
    if (_viewingOwnProfile) {
        [self setRightNavWithIcon:kFontIconPhoto target:self action:@selector(handleUpperRightButton)];
    }
    
    _listsAndPhotosLayout.thereAreNoItems= _arrayPhotos.count==0;
    [self getPhotos];
//    [_listsAndPhotosLayout invalidateLayout];
//    [self.cv reloadData];
}

#pragma mark - Collection View stuff

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:( ProfileVCCVLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if  (_viewingLists ) {
        return kGeomHeightStripListRow;
    } else {
        if (!_arrayPhotos.count) {
            return kGeomHeightStripListRow;
        }
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
            return 0;
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
    
    if  (!total && (!self.aiv.isAnimating || self.aiv.endingAnimation)) {
        // NOTE: We want to show an empty cell when there are no items to show,
        //  but not before the network call has finished.
        total= 1;
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
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        _listsAndPhotosLayout.userIsSelf = _viewingOwnProfile;
        _listsAndPhotosLayout.userIsFoodie = _profileOwner.isFoodie;
        _listsAndPhotosLayout.foodieHasURL = _profileOwner.website.length > 0;

        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                 withReuseIdentifier:PROFILE_CV_HEADER_CELL
                                                        forIndexPath:indexPath];
        
        [view setUserInfo:_profileOwner];

        view.vc = self;
        view.delegate = self;

        return view;
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (_viewingLists) {
        NSLog(@"section:%lu row:%lu", indexPath.section, indexPath.row);
        
        NSUInteger total= self.arrayLists.count;
        if (!total) {
            ProfileEmptyCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:PROFILE_CV_EMPTY_CELL
                                                                             forIndexPath:indexPath];
            if (_viewingOwnProfile) {
                [cell setListMode];
                cell.message = @"Make your first list!";
            } else {
                [cell setMessageMode];
                cell.message = @"This user is still making their first list.";
            }
            return  cell;
        }
        if (row >= total) {
            return nil;
        }
        
        ListStripCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PROFILE_CV_LIST_CELL
                                                                          forIndexPath:indexPath];
        
        NSArray *a = self.arrayLists;
        ListObject *listItem = a[row];
        listItem.listDisplayType = KListDisplayTypeStrip;
        
        cell.navigationController = self.navigationController;
        cell.listItem = listItem;
        
        return cell;
    }
    else {
        NSUInteger total= self.arrayPhotos.count;
        if (!total) {
            ProfileEmptyCell*cell= [collectionView dequeueReusableCellWithReuseIdentifier:PROFILE_CV_EMPTY_CELL
                                                                             forIndexPath:indexPath];

            if (_viewingOwnProfile) {
                [cell setPhotoMode];
                cell.message = @"Take your first picture!";
            } else {
                [cell setMessageMode];
                cell.message = @"Artfully crafted photos coming soon.";
            }

            return  cell;
        }
        if (row >= total) {
            return nil;
        }
        
        PhotoCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PROFILE_CV_PHOTO_CELL
                                                                      forIndexPath:indexPath];
        NSArray *a = self.arrayPhotos;
        MediaItemObject *object = a[row];
        cell.mediaItemObject = object;
        cell.delegate = self;
        [cell showActionButton:NO];
        return cell;
    }
}

- (void)photoCell:(PhotoCVCell *)photoCell showProfile:(UserObject *)userObject
{
    if (_viewingOwnProfile) {
        NSLog(@"OWN PROFILE");
        return;
    }
}

- (void)photoCell:(PhotoCVCell *)photoCell showPhotoOptions:(MediaItemObject *)mio
{
//    __weak ProfileVC *weakSelf = self;
    if (_viewingOwnProfile) {
        NSLog(@"OWN PROFILE");
    } else {
        NSLog(@"Another's PROFILE");
//        [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:a animated:YES completion:nil];
    }
}

- (void)userAddingCaptionTo:(MediaItemObject*)mio
{
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    self.mediaItemBeingEdited = mio;
    
    AddCaptionToMIOVC *vc = [[AddCaptionToMIOVC alloc] init];
    vc.delegate = self;
    vc.textLengthLimit= kUserObjectMaximumAboutTextLength;// XX:
    vc.defaultText = mio.caption;
    
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    vc.mio = mio;
    [vc overrideIsFoodWith:NO];

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
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)photoCell:(PhotoCVCell *)photoCell likePhoto:(MediaItemObject *)mio
{
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.uploading) {
        return;
    }
    
    CGRect originRect = CGRectMake(self.view.center.x, self.view.center.y, 0, 0);
    id cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[PhotoCVCell class]]) {
        originRect = [self.view convertRect:[cell frame] fromView:collectionView];
        originRect.origin.y = originRect.origin.y + kGeomHeightNavBarStatusBar;
    }
    
    NSInteger row= indexPath.row;
    if  (_viewingLists) {
        if (!_arrayLists.count) {
            [self userPressedEmptyCell];
            return;
        }
        ListObject*object = _arrayLists[row];
        RestaurantListVC *vc = [[RestaurantListVC  alloc] init];
        vc.listItem = object;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if (!_arrayPhotos.count) {
            [self userPressedEmptyCell];
            return;
        }
        NSUInteger row = indexPath.row;
        MediaItemObject *mediaObject = _arrayPhotos[row];
        NSUInteger restaurantID = mediaObject.restaurantID;
        if (!restaurantID) {
            [self launchViewPhoto:mediaObject restaurant:nil originFrame:originRect];
        } else {
            __weak ProfileVC *weakSelf = self;
            OOAPI *api=[[OOAPI alloc]init];
            [api getRestaurantWithID:stringFromUnsigned(restaurantID)
                              source:kRestaurantSourceTypeOomami
                             success:^(RestaurantObject *restaurant) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (restaurant) {
                                         [weakSelf launchViewPhoto:mediaObject restaurant:restaurant originFrame:originRect];
                                     } else {
                                         [weakSelf launchViewPhoto:mediaObject restaurant:nil originFrame:originRect];
                                     }
                                 });
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [weakSelf launchViewPhoto:mediaObject restaurant:nil originFrame:originRect];
                                 });
                             }];
        }
    }
}

- (void)launchViewPhoto:(MediaItemObject*)mio restaurant:(RestaurantObject*)restaurant originFrame:(CGRect)originFrame
{
    ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];    
    vc.originRect = originFrame;
    vc.mio = mio;
    vc.restaurant = restaurant;
    vc.delegate = self;
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([toVC isKindOfClass:[ViewPhotoVC class]] && operation == UINavigationControllerOperationPush) {
        ViewPhotoVC *vc = (ViewPhotoVC *)toVC;
        ShowMediaItemAnimator *animator = [[ShowMediaItemAnimator alloc] init];
        animator.presenting = YES;
        animator.originRect = vc.originRect;
        animator.duration = 0.6;
        animationController = animator;
    } else if ([fromVC isKindOfClass:[ViewPhotoVC class]] && operation == UINavigationControllerOperationPop) {
        ShowMediaItemAnimator *animator = [[ShowMediaItemAnimator alloc] init];
        ViewPhotoVC *vc = (ViewPhotoVC *)fromVC;
        animator.presenting = NO;
        animator.originRect = vc.originRect;
        animator.duration = 0.6;
        animationController = animator;
    }
    
    return animationController;
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

- (void) userPressedSettings;
{
    if  (self.uploading || !_viewingOwnProfile) {
        return;
    }
    __weak  ProfileVC *weakSelf = self;
    
    _optionsAC = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"What would you like to do?\n%@", [Common versionString]] preferredStyle:UIAlertControllerStyleActionSheet];
    
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
    
    UIAlertAction *actionProfilePicture = [UIAlertAction actionWithTitle:@"Change Profile Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf  userPressedChangeProfilePicture];
    }];
    
    UIAlertAction *manageTags = [UIAlertAction actionWithTitle:@"Manage Tags" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ManageTagsVC *vc = [[ManageTagsVC alloc] init];
        [weakSelf .navigationController pushViewController:vc animated:YES];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [_optionsAC addAction: actionProfilePicture];
    [_optionsAC addAction:manageTags];
    [_optionsAC addAction:logout];
    [_optionsAC addAction:cancel];
    [self presentViewController:_optionsAC animated:YES completion:nil];
}

- (void)userPressedChangeProfilePicture
{
    _pickerIsForRestaurants= NO;
    [self showPickPhotoUI];
    
}

- (void)importPhotoFromFacebook
{
    __weak  ProfileVC *weakSelf = self;
    [ SocialMedia fetchProfilePhotoWithCompletionBlock:^(NSString*urlString) {
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString: urlString]];
            UIImage*image= [ UIImage imageWithData: data];
            if  (image ) {
                [weakSelf setUserPhoto: image];
            } else {
                NSLog (@"THERE WAS A PROBLEM OBTAINING THE FACEBOOK PHOTO.");
            }
        });
        
    }];
}

- (void)showPickPhotoUI
{
    BOOL haveCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL havePhotoLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    NSString* titleString = _pickerIsForRestaurants ?  @"Add Photo for a Restaurant": @"Set Your Profile Photo";
    NSString* message = _pickerIsForRestaurants ?  @"Take a photo with your camera or add one from your photo library.": nil;
    
    UIAlertController *addPhoto = [UIAlertController alertControllerWithTitle:titleString
                                                                      message:message
                                                               preferredStyle:UIAlertControllerStyleAlert];
    __weak  ProfileVC *weakSelf = self;
    UIAlertAction *cameraUI = [UIAlertAction actionWithTitle:@"Camera"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           [weakSelf showCameraUI];
                                                       }];
    
    UIAlertAction *libraryUI = [UIAlertAction actionWithTitle:@"Library"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            [weakSelf showPhotoLibraryUI];
                                                        }];
    
    UIAlertAction *socialUI = nil;
    if  (!_pickerIsForRestaurants) {
        socialUI= [UIAlertAction actionWithTitle:@"Update from Facebook"
                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                               [weakSelf importPhotoFromFacebook];
                                           }];
        
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       NSLog(@"Cancel");
                                                   }];
    
    if (!haveCamera && ! havePhotoLibrary && ! socialUI) {
        return;
    }
    if (haveCamera) [addPhoto addAction:cameraUI];
    if (havePhotoLibrary) [addPhoto addAction:libraryUI];
    if  (socialUI ) {
        [ addPhoto addAction: socialUI];
    }
    [addPhoto addAction:cancel];
    
    if (havePhotoLibrary ||  haveCamera  || socialUI)
        [self presentViewController:addPhoto animated:YES completion:nil];
}

- (void)showCameraUI
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera ;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)showPhotoLibraryUI
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


@end

@interface ProfileEmptyCell()
@property (nonatomic,strong) UILabel*labelMessage;
@property (nonatomic,strong) UILabel* labelIcon;

@property (nonatomic,assign)  enum  {
        PROFILE_EMPTYCELL_LIST, PROFILE_EMPTYCELL_PHOTO, PROFILE_EMPTYCELL_MESSAGE
    } mode;
@end

@implementation ProfileEmptyCell
- (instancetype) initWithFrame:(CGRect)frame
{
    self=[ super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews= NO;
        _labelIcon= makeIconLabel( self,  @"",kGeomIconSize);
        _labelIcon.textColor= YELLOW;

        _labelMessage= makeLabel(self,  @"?", kGeomFontSizeHeader);
        _labelMessage.textColor = UIColorRGB(kColorLightGray);
        _labelMessage.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

- (void) setMessage:(NSString *)message;
{
    _labelMessage.text= message;
}

- (void)setListMode
{
    _labelIcon.text=kFontIconAdd;
    _mode= PROFILE_EMPTYCELL_LIST;
    [self setNeedsLayout];
}
- (void)setMessageMode
{
    _labelIcon.text= @"";
    _mode= PROFILE_EMPTYCELL_MESSAGE;
    [self setNeedsLayout];
}
- (void)setPhotoMode
{
    _labelIcon.text=kFontIconPhoto;
    _mode= PROFILE_EMPTYCELL_PHOTO;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super  layoutSubviews];
    
    float w = self.bounds.size.width;
    CGSize messageSize= [_labelMessage sizeThatFits:CGSizeMake(w,200)];

    switch (_mode) {
        case PROFILE_EMPTYCELL_LIST:
        case PROFILE_EMPTYCELL_PHOTO:{
            [_labelIcon sizeToFit];
            float w1= _labelIcon.frame.size.width;
            float w2= messageSize.width;
            float requiredWidth= w1+w2 +kGeomSpaceInter;
            float x=  (w-requiredWidth)/2;

            _labelIcon.frame= CGRectMake(x,0, w1,kGeomHeightButton);
            x+= w1 +kGeomSpaceInter;
            _labelMessage.frame= CGRectMake(x,0,w2,kGeomHeightButton);
        } break;
            
        default:{
            float w1= messageSize.width;
            float x=  (w-w1)/2;
            _labelMessage.frame= CGRectMake(x,0,w1,kGeomHeightButton);
        } break;
    }
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    [self setMessageMode];
}
@end


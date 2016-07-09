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
#import "SearchVC.h"
#import "UIImage+Additions.h"
#import "AppDelegate.h"
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
#import "DebugUtilities.h"
#import "RestaurantTVCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Instabug/Instabug.h>

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

    [self userTappedOnListsFilter:nil];
    [_filterView addFilter:LOCAL(@"LISTS") target:self selector:@selector(userTappedOnListsFilter:)];

    if (_userInfo.userType != kUserTypeTrusted) {
        [_filterView addFilter:LOCAL(@"PHOTOS") target:self selector:@selector(userTappedOnPhotosFilter:)];
    }
    
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
                           
                           weakSelf.buttonFollowees.alpha = 1;
                           weakSelf.buttonFollowers.alpha = 1;
                           weakSelf.buttonFolloweesCount.alpha = 1;
                           weakSelf.buttonFollowersCount.alpha = 1;
                           
                           weakSelf.labelPhotoCount.text = stringFromUnsigned(stats.totalPhotos);
                           weakSelf.labelLikesCount.text = stringFromUnsigned(stats.totalLikes);
                           weakSelf.labelVenuesCount.text = stringFromUnsigned(stats.totalVenues);
                           
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

    _buttonDescription.enabled = _viewingOwnProfile;

    __weak ProfileHeaderView *weakSelf = self;
    
    [_userView setUser:_userInfo];
    
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

    
    // RULE: Only update the button when we know for sure whose profile is.
    if ( _viewingOwnProfile) {
        NSLog  (@"VIEWING OWN PROFILE.");
        // RULE: Show the user's own stats.
        [self  indicateFollowing];
        [_userView setShowCog];
        [self refreshUserStats];
    }
    else  {
        [OOAPI getFollowersForUser:_userInfo.userID
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
        _backgroundImageFade = makeView(self, UIColorRGBA(kColorDarkImageOverlay));

        _filterView= [[OOFilterView alloc] init];
        [self addSubview:_filterView];
        
        _userView= [[OOUserView alloc] init];
        _userView.delegate= self;
        [self addSubview:_userView];
        
        self.viewSpecialties=makeView(self, UIColorRGBA(kColorBlack));
        self.labelSpecialtyHeader=  makeLabel( _viewSpecialties,  @"Specialties:", kGeomFontSizeSubheader);
        _labelSpecialtyHeader.font= [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeSubheader];
        self.labelSpecialties=  makeLabel( _viewSpecialties,  @"", kGeomFontSizeSubheader);
        _labelSpecialtyHeader.textColor=UIColorRGBA(kColorText);
        _labelSpecialties.textColor=UIColorRGBA(kColorText);
        _labelSpecialtyHeader.backgroundColor = UIColorRGBA(kColorClear);
        _labelSpecialties.backgroundColor = UIColorRGBA(kColorClear);
        
        self.buttonURL=makeButton(self, @"URL", kGeomFontSizeSubheader, UIColorRGBA(kColorTextActive), UIColorRGBA(kColorClear),  self, @selector(userPressedURLButton:), 0);
        _buttonURL.hidden= YES;
        
        _buttonFollowees= makeButton(self, @"FOLLOWING", kGeomFontSizeSubheader, UIColorRGBA(kColorTextActive), UIColorRGBA(kColorClear),  self, @selector(userPressedFollowees:), 0);
        _buttonFollowers= makeButton(self, @"FOLLOWERS", kGeomFontSizeSubheader, UIColorRGBA(kColorTextActive), UIColorRGBA(kColorClear),  self, @selector(userPressedFollowers:), 0);
        
        _buttonFolloweesCount= makeButton(self, @"", kGeomFontSizeHeader, UIColorRGBA(kColorText), UIColorRGBA(kColorClear),  self, @selector(userPressedFollowees:), 0);
        _buttonFollowersCount= makeButton(self, @"", kGeomFontSizeHeader, UIColorRGBA(kColorText), UIColorRGBA(kColorClear),  self, @selector(userPressedFollowers:), 0);
        
        _buttonFollowersCount.titleLabel.font = [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader];
        _buttonFolloweesCount.titleLabel.font = _buttonFollowersCount.titleLabel.font;
        
        _buttonDescription = makeButton(self,  @"", 1, UIColorRGBA(kColorText),
                                        UIColorRGBA(kColorBackgroundTheme),  self,
                                        @selector(userTappedDescription:) , 0);
        _buttonDescription.contentEdgeInsets = UIEdgeInsetsMake(0, kGeomSpaceEdge, 0, kGeomSpaceEdge);
        _buttonDescription.titleLabel.numberOfLines = 0;
        _buttonDescription.titleLabel.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3];

        [_buttonDescription setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        [_buttonDescription setTitleColor:UIColorRGBA(kColorText) forState:UIControlStateDisabled];
        
        _labelVenuesCount= makeLabel(self,  @"", kGeomFontSizeStatsText);
        _labelPhotoCount= makeLabel(self,  @"", kGeomFontSizeStatsText);
        _labelLikesCount= makeLabel(self,  @"", kGeomFontSizeStatsText);
        _labelVenues= makeIconLabel(self, kFontIconPinDot, kGeomFontSizeStatsIcons);
        _labelPhoto= makeIconLabel(self, kFontIconPhoto, kGeomFontSizeStatsIcons);
        _labelLikes= makeIconLabel(self, kFontIconYum, kGeomFontSizeStatsIcons);
        
        _labelVenuesCount.textColor= UIColorRGBA(kColorText);
        _labelPhotoCount.textColor= UIColorRGBA(kColorText);
        _labelLikesCount.textColor= UIColorRGBA(kColorText);
        _labelVenues.textColor= UIColorRGBA(kColorText);
        _labelPhoto.textColor= UIColorRGBA(kColorText);
        _labelLikes.textColor= UIColorRGBA(kColorText);

        _labelVenuesCount.textAlignment= NSTextAlignmentLeft;
        _labelPhotoCount.textAlignment= NSTextAlignmentLeft;
        _labelLikesCount.textAlignment= NSTextAlignmentLeft;
        
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        
        self.buttonFollow= makeButton(self, @"FOLLOW",
                                       kGeomFontSizeSubheader, UIColorRGBA(kColorTextReverse), UIColorRGBA(kColorTextActive),
                                       self,
                                       @selector(userPressedFollow:), 0);
        [_buttonFollow setTitle:@"FOLLOWING" forState:UIControlStateSelected];
        [_buttonFollow setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateSelected];
        _buttonFollow.layer.borderColor = UIColorRGBA(kColorTextActive).CGColor;
        _buttonFollow.layer.cornerRadius = kGeomCornerRadius;
        _buttonFollow.layer.borderWidth = 1;
        _buttonFollow.hidden = YES;
        
        [self registerForNotification:kNotificationUserStatsChanged
                              calling:@selector(updateUserStats:)
         ];
        [self registerForNotification:kNotificationOwnProfileNeedsUpdate
                              calling:@selector(updateOwnProfile:)
         ];
        
        self.backgroundColor = UIColorRGBA(kColorBlack);
        
//        [DebugUtilities addBorderToViews:@[_buttonDescription, self]];
    }
    return self;
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user;
{
    [self.delegate userPressedSettings:userView];
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

- (void)userPressedURLButton:(id)sender
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

- (void)userPressedSettings:(id)sender
{
    [self.delegate userPressedSettings:sender];
}

- (void)updateOwnProfile:(NSNotification*)not
{
    if ( !_viewingOwnProfile) {
        return;
    }
    [self refreshUserImage];
    [self loadUserInfo];
}

- (void)fetchFollowers
{
    //__weak ProfileHeaderView *weakSelf = self;
 
    UserListVC *vc = [[UserListVC alloc] init];
    vc.desiredTitle = @"FOLLOWERS";
    vc.user = _userInfo;
    [_vc.navigationController pushViewController:vc animated:YES];
    
    __weak UserListVC *weakVC = vc;
    
    [vc.view bringSubviewToFront:vc.aiv];
    [vc.aiv startAnimating];
    
    [OOAPI getFollowersForUser:_userInfo.userID
                  success:^(NSArray *users) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if  (!users.count) {
                              if (_userInfo.userID == [Settings sharedInstance].userObject.userID) {
                                  [APP.tabBar setSelectedIndex: kTabIndexConnect];
                              }
                              NSLog  (@"NO FOLLOWERS");
                              return ;
                          }
                          
                          weakVC.usersArray = users.mutableCopy;
                          [weakVC.aiv stopAnimating];
                          
                          NSLog (@"SUCCESS IN FETCHING %lu FOLLOWERS", (unsigned long)users.count);
                      });
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog (@"UNABLE TO FETCH FOLLOWERS");
                      [weakVC.aiv stopAnimating];
                  }];
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
    //__weak  ProfileHeaderView *weakSelf = self;

    UserListVC *vc = [[UserListVC alloc] init];
    vc.user = _userInfo;
    vc.desiredTitle = @"Following";
    [_vc.navigationController pushViewController: vc animated:YES];
    
    __weak UserListVC *weakVC = vc;
    
    [vc.view bringSubviewToFront:vc.aiv];
    [vc.aiv startAnimating];
    
    [OOAPI getFollowingForUser:_userInfo.userID
                  success:^(NSArray *users) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if  (!users.count) {
                              if (_userInfo.userID == [Settings sharedInstance].userObject.userID) {
                                  [APP.tabBar setSelectedIndex:kTabIndexConnect];
                              }

                              NSLog  (@"NO FOLLOWEES");
                              return ;
                          }
//                          UserListVC *vc = [[UserListVC alloc] init];
//                          vc.user= _userInfo;
//                          vc.desiredTitle = @"Following";
                          weakVC.usersArray = users.mutableCopy;
                          [weakVC.aiv stopAnimating];
//                          [weakSelf.vc.navigationController pushViewController: vc animated:YES];
                          NSLog(@"SUCCESS IN FETCHING %lu FOLLOWEES", (unsigned long)users.count);
                      });
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"CANNOT GET LIST OF PEOPLE WE ARE FOLLOWING");
                      [weakVC.aiv stopAnimating];
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
    __weak ProfileHeaderView *weakSelf = self;
    
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!result) {
            [weakSelf presentUnverifiedMessage:@"To edit your description you will need to verify your email.\n\nCheck your email for a verification link."];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UINavigationController *nc = [[UINavigationController alloc] init];
                
                OOTextEntryModalVC *vc = [[OOTextEntryModalVC alloc] init];
                vc.delegate = self;
                vc.textLengthLimit= kUserObjectMaximumAboutTextLength;
                vc.defaultText = _userInfo.about;
                vc.view.frame = CGRectMake(0, 0, 40, 44);
                [nc addChildViewController:vc];
                
                [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
                [nc.navigationBar setTranslucent:YES];
                nc.view.backgroundColor = [UIColor clearColor];
                
                [weakSelf.vc.navigationController presentViewController:nc animated:YES completion:^{
                    nc.topViewController.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
                }];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"*** Problem verifying user");
        if (error.code == kCFURLErrorNotConnectedToInternet) {
            message(@"You do not appear to be connected to the internet.");
        } else {
            message(@"There was a problem verifying your account.");
        }
        return;
    }];
}

- (void)presentUnverifiedMessage:(NSString *)message {
    UnverifiedUserVC *vc = [[UnverifiedUserVC alloc] initWithSize:CGSizeMake(250, 200)];
    vc.delegate = self;
    vc.action = message;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.transitioningDelegate = vc;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *nc = [UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject;
        if ([nc isKindOfClass:[UINavigationController class]]) {
            ((UINavigationController *)nc).delegate = vc;
        }
        
        [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:vc animated:YES completion:nil];
    });
}

- (void)unverifiedUserVCDismiss:(UnverifiedUserVC *)unverifiedUserVC {
    [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject  dismissViewControllerAnimated:YES completion:^{
        ;
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
                           [weakSelf.buttonDescription setTitle:weakSelf.userInfo.about forState: UIControlStateNormal];
                           [weakSelf setNeedsLayout];
                           [weakSelf.vc.view setNeedsLayout];
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

- (void)verifyUnfollow:(id)sender
{
    __weak ProfileHeaderView *weakSelf = self;

    UIAlertController *a = [UIAlertController alertControllerWithTitle:LOCAL(@"Really Unfollow?")
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    
    a.popoverPresentationController.sourceView = sender;
    a.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;

    
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
                        });
                        NOTIFY(kNotificationConnectNeedsUpdate);
                        NOTIFY(kNotificationUserFollowingChanged);
                        NOTIFY(kNotificationOwnProfileNeedsUpdate);
                        NSLog (@"SUCCESSFULLY UNFOLLOWED USER");
                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                        NSLog (@"FAILED TO UNFOLLOW USER");
                    }];
}

- (void)indicateFollowing
{
    _buttonFollow.selected= YES;
    _followingThisUser=YES;
    _buttonFollow.backgroundColor = UIColorRGBA(kColorClear);
    _buttonFollow.layer.borderWidth= 1;
    _buttonFollow.hidden= NO;
}

- (void)indicateNotFollowing
{
    _followingThisUser = NO;
    _buttonFollow.selected = NO;
    _buttonFollow.backgroundColor = UIColorRGBA(kColorTextActive);
    _buttonFollow.layer.borderWidth = 0;
    _buttonFollow.hidden = NO;

}

//------------------------------------------------------------------------------
// Name:    userPressedFollow
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedFollow:(id)sender
{
    if  (_viewingOwnProfile) {
        return;
    }
    
    __weak ProfileHeaderView *weakSelf = self;
    
    if (_followingThisUser) {
        [self verifyUnfollow:sender];
        return;
    }
    
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!result) {
            [weakSelf presentUnverifiedMessage:[NSString stringWithFormat:@"You will need to verify your email to follow @%@.\n\nCheck your email for a verification link.", _userInfo.username]];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [OOAPI setFollowingUser:_userInfo
                                     to: YES
                                success:^(id responseObject) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSelf indicateFollowing];
                                    });
                                    NOTIFY(kNotificationConnectNeedsUpdate);
                                    NOTIFY(kNotificationUserFollowingChanged);
                                    NOTIFY(kNotificationOwnProfileNeedsUpdate);
                                    NSLog (@"SUCCESSFULLY FOLLOWED USER");
                                } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                                    NSLog (@"FAILED TO FOLLOW/UNFOLLOW USER");
                                }];

            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"*** Problem verifying user");
        if (error.code == kCFURLErrorNotConnectedToInternet) {
            message(@"You do not appear to be connected to the internet.");
        } else {
            message(@"There was a problem verifying your account.");
        }
        return;
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
    CGFloat spacing = kGeomSpaceInter;
    CGSize s;
    
    _backgroundImageView.frame = CGRectMake(0, 0, w, h-kGeomHeightFilters);
    _backgroundImageFade.frame = CGRectMake(0, 0, w, h-kGeomHeightFilters);
    _backgroundImageView.backgroundColor = UIColorRGBA(kColorTextActive);
    NSUInteger y = kGeomSpaceEdge;
    _userView.frame = CGRectMake((w-kGeomProfileImageSize)/2, y, kGeomProfileImageSize, kGeomProfileImageSize);
    
    y += kGeomProfileImageSize + spacing;

    [_buttonFollowers sizeToFit];
    [_buttonFollowees sizeToFit];
    [_buttonFollowersCount sizeToFit];
    [_buttonFolloweesCount sizeToFit];
    CGFloat upperLabelHeight = 20;
    CGFloat lowerLabelHeight = 18;
    CGFloat horizontalSpaceForText = (320-kGeomProfileImageSize)/2;
    CGFloat yFollowers = (kGeomProfileImageSize + 2*kGeomSpaceEdge - upperLabelHeight-lowerLabelHeight)/2;
    
    CGFloat leftX = w/2 - kGeomProfileImageSize/2 - horizontalSpaceForText;
    CGFloat rightX = w/2 + kGeomProfileImageSize/2;
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
    float w3 = (_userInfo.userType == kUserTypeTrusted) ? 0:width(_labelPhoto);
    float w4 = (_userInfo.userType == kUserTypeTrusted) ? 0:width(_labelPhotoCount);
    float w5 = (_userInfo.userType == kUserTypeTrusted) ? 0:width(_labelLikes);
    float w6 = (_userInfo.userType == kUserTypeTrusted) ? 0:width(_labelLikesCount);
    float x = (w-w1-w2-w3-w4-w6-w5-2*kGeomSpaceInter)/2;
    _labelPhoto.frame = CGRectMake(x,y ,w3,kGeomProfileStatsItemHeight);
    x += w3;
    
    _labelPhotoCount.frame = CGRectMake(x,y,w4,kGeomProfileStatsItemHeight);
    x += w4;// +kGeomSpaceInter;
    
    _labelLikes.frame = CGRectMake(x,y ,w5,kGeomProfileStatsItemHeight);
    x += w5;
    
    _labelLikesCount.frame = CGRectMake(x,y,w6,kGeomProfileStatsItemHeight);
    x += w6;
    
    _labelVenues.frame = CGRectMake(x,y ,w1,kGeomProfileStatsItemHeight);
    x += w1;
    
    _labelVenuesCount.frame = CGRectMake(x,y,w2,kGeomProfileStatsItemHeight);
    x += w2+kGeomSpaceInter;

    y += kGeomProfileStatsItemHeight;
    
    if (!_viewingOwnProfile) {
        _buttonFollow.frame = CGRectMake(w/2-kGeomWidthButton/2,
                                         y+(kGeomProfileStatsItemHeight-kGeomFollowButtonHeight)/2,
                                         kGeomWidthButton,  kGeomFollowButtonHeight);
        y += CGRectGetHeight(_buttonFollow.frame) + 2*kGeomSpaceEdge;
    }
    
    if (_userInfo.website.length) {
        _buttonURL.frame = CGRectMake(0, y, w, kGeomProfileHeaderViewHeightOfBloggerButton);
        y += CGRectGetHeight(_buttonURL.frame) + kGeomSpaceEdge;
    }

    s = [_buttonDescription.titleLabel sizeThatFits:CGSizeMake(w-2*kGeomSpaceEdge, 200)];
    _buttonDescription.frame = CGRectMake(0, y, w, s.height+2*kGeomSpaceEdge);
    y = CGRectGetMaxY(_buttonDescription.frame);
    
    if (_userInfo.hasSpecialties) {
        [_labelSpecialtyHeader sizeToFit];
        [_labelSpecialties sizeToFit];
        _viewSpecialties.frame= CGRectMake(0, y, w, CGRectGetHeight(_labelSpecialtyHeader.frame) + CGRectGetHeight(_labelSpecialtyHeader.frame) + 2*kGeomSpaceEdge);
        CGFloat requiredHeaderHeight = CGRectGetHeight(_labelSpecialtyHeader.frame);
        CGFloat requiredSpecialtiesHeight = CGRectGetHeight(_labelSpecialtyHeader.frame);
        CGFloat yHeader = 0;
        _labelSpecialtyHeader.frame = CGRectMake(0, yHeader, w, requiredHeaderHeight);
        yHeader +=requiredHeaderHeight;
        _labelSpecialties.frame= CGRectMake(0,yHeader,w, requiredSpecialtiesHeight);
        y = CGRectGetMaxY(_viewSpecialties.frame);
    } else {
        _labelSpecialtyHeader.frame= CGRectMake(0, y, w, 0);
        _labelSpecialties.frame= CGRectMake(0, y, w, 0);
    }
    
    _filterView.frame = CGRectMake(0, y, w, kGeomHeightFilters);
    [self bringSubviewToFront:_filterView];
    _filterView.userInteractionEnabled=YES;
    y = CGRectGetMaxY(_filterView.frame);//kGeomHeightFilters;
    
    self.frame = CGRectMake(0, 0, w, y);
}

@end

//==============================================================================
@interface ProfileVC ()

@property (nonatomic, strong) UICollectionView *cv;
@property (nonatomic, strong) ProfileVCCVLayout *listsAndPhotosLayout;

@property (nonatomic, strong) NSArray *arrayLists;
@property (nonatomic, strong) NSArray *arrayPhotos;

@property (nonatomic, strong) UIImageView *profilePhoto;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UserObject *profileOwner;
@property (nonatomic, assign) BOOL viewingOwnProfile;
@property (nonatomic, strong) UIAlertController *optionsAC;
@property (nonatomic, strong) ProfileHeaderView *headerView;
@property (nonatomic, assign) BOOL didFetchUserObject;
@property (nonatomic, assign) NSUInteger lastShownUser;
@property (nonatomic, assign) MediaItemObject *mediaItemBeingEdited;
@property (nonatomic, strong) RestaurantPickerVC *restaurantPicker;
@property (nonatomic, strong) UIImage *imageToUpload;
@property (nonatomic, strong) RestaurantObject *selectedRestaurant;
@property (nonatomic, assign) BOOL viewingLists; // false => viewing photos
@property (nonatomic, assign) BOOL pickerIsForRestaurants;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic, strong) NavTitleObject *nto;

@property (nonatomic, strong) AFHTTPRequestOperation *roSearchMyPlaces;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL searchMode;
@property (nonatomic, strong) NSArray *searchResultsArray;
@property (nonatomic, strong) UITableView *searchTable;
@end

static NSString *const kProfilePhotoCellIdentifier = @"profilePhotoCell";
static NSString *const kProfileListCellIdentifier = @"profileListCell";
static NSString *const kProfileHeaderCellIdentifier = @"profileHeaderCell";
static NSString *const kProfileEmptyCellIdentifier = @"profileEmptyCell";
static NSString *const kRestaurantCellIdentifier =   @"restaurantsCell";

@implementation ProfileVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN(@(object_getClassName(self)));

    [self setNavTitle:_nto];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self refreshIfNeeded];
    
    [self.refreshControl addTarget:self action:@selector(forceRefresh:) forControlEvents:UIControlEventValueChanged];
    [_cv addSubview:self.refreshControl];
    _cv.alwaysBounceVertical = YES;
}

- (void)forceRefresh:(id)sender {
    [self setNeedsRefresh];
    [self refreshIfNeeded];
}

- (void)refreshIfNeeded {
    if (_needRefresh) {
        [self refetchListsPhotosAndStats];
        _needRefresh = NO;
    }
}

- (void)setNeedsRefresh {
    _needRefresh = YES;
}

- (void)done:(id)sender
{
    if (!self.uploading) {
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
    [super viewDidLoad];
    
    _userID = 0;
    _viewingLists = YES;
    _needRefresh = YES;
    _arrayLists = @[];
    _arrayPhotos = @[];
    _searchResultsArray=@[];
    
    _searchTable = [UITableView new];
    _searchTable.alpha = 0;
    _searchTable.delegate = self;
    _searchTable.dataSource = self;
    [_searchTable registerClass:[RestaurantTVCell class] forCellReuseIdentifier:kRestaurantCellIdentifier];
    _searchTable.rowHeight = kGeomHeightHorizontalListRow;
    [self.view addSubview:_searchTable];
    _searchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchTable.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _searchMode = NO;
    _searchBar = [UISearchBar new];
    _searchBar.alpha = 0;
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    _searchBar.backgroundColor = UIColorRGBA(kColorNavBar);
    _searchBar.barTintColor = UIColorRGBA(kColorNavBar);
    
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
        [self removeNavButtonForSide:kNavBarSideTypeLeft];
        [self addNavButtonWithIcon:kFontIconPhotoThick target:self action:@selector(handleUpperRightButton) forSide:kNavBarSideTypeRight isCTA:YES];
    } else {
        [self removeNavButtonForSide:kNavBarSideTypeRight];
    }
    
    _searchBar.placeholder = (_viewingOwnProfile) ? @"Find places on your lists" : [NSString stringWithFormat:@"Find places on @%@'s lists", _userInfo.username];
    
//    _lastShownUser = _userInfo.userID;
    
    NSUInteger totalControllers= self.navigationController.viewControllers.count;
    if (totalControllers  == 1) {
        [self removeNavButtonForSide:kNavBarSideTypeLeft];
        [self addNavButtonWithIcon:kFontIconSearch target:self action:@selector(showSearch) forSide:kNavBarSideTypeLeft isCTA:NO];
    } else {
        [self removeNavButtonForSide:kNavBarSideTypeLeft];
        [self addNavButtonWithIcon:kFontIconBack target:self action:@selector(done:) forSide:kNavBarSideTypeLeft isCTA:NO];
        [self addNavButtonWithIcon:kFontIconSearch target:self action:@selector(showSearch) forSide:kNavBarSideTypeLeft isCTA:NO];
    }
    
    self.listsAndPhotosLayout= [[ProfileVCCVLayout alloc] init];
    _listsAndPhotosLayout.delegate= self;
    _listsAndPhotosLayout.userIsSelf=_viewingOwnProfile;
    [_listsAndPhotosLayout setShowingLists:NO];
    
    _cv = makeCollectionView(self.view, self, _listsAndPhotosLayout);
    
    // NOTE: When _viewingLists==YES, use ProfileCVListRow else use PhotoCVCell.
    [_cv registerClass:[PhotoCVCell class] forCellWithReuseIdentifier:kProfilePhotoCellIdentifier];
    [_cv registerClass:[ListStripCVCell class] forCellWithReuseIdentifier:kProfileListCellIdentifier];
    [_cv registerClass:[ProfileEmptyCell class] forCellWithReuseIdentifier:kProfileEmptyCellIdentifier];
    [_cv registerClass:[ProfileHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
   withReuseIdentifier:kProfileHeaderCellIdentifier];
    
    NSString *string = _profileOwner.username.length ? concatenateStrings(@"@", _profileOwner.username) :  @"Oomami User";
    _nto = [[NavTitleObject alloc] initWithHeader:string
                                        subHeader:[NSString stringWithFormat:@"%@ %@", (_profileOwner.firstName)?(_profileOwner.firstName):@"", (_profileOwner.lastName)?_profileOwner.lastName:@""]];
    
    _profilePhoto = [UIImageView new];
    _profilePhoto.contentMode = UIViewContentModeScaleAspectFit;
    _profilePhoto.backgroundColor = UIColorRGBOverlay(kColorBackgroundTheme, 0.90);
    _profilePhoto.userInteractionEnabled = YES;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfilePhotoFullScreen:)];
    [_tapGestureRecognizer setNumberOfTapsRequired:1];
    [_profilePhoto addGestureRecognizer:_tapGestureRecognizer];
    _profilePhoto.hidden = YES;
    
    [self.view addSubview:_profilePhoto];
    
    [self.view bringSubviewToFront:self.uploadProgressBar];
    [self.view bringSubviewToFront:_profilePhoto];
}

- (void)showProfilePhotoFullScreen:(id)sender {
    if (sender == _tapGestureRecognizer) {
        _profilePhoto.hidden = YES;
    } else {
        __weak ProfileVC *weakSelf = self;
        if (!_profileOwner.mediaItem) return;
        
        OOAPI *api = [[OOAPI alloc] init];
        [api getRestaurantImageWithMediaItem:_profileOwner.mediaItem maxWidth:200 maxHeight:0 success:^(NSString *link) {
            [weakSelf.profilePhoto setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                          placeholderImage:nil
                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           weakSelf.profilePhoto.image = image;
                                           [weakSelf.profilePhoto setAlpha:1.0];
                                           weakSelf.profilePhoto.hidden = NO;
                                       });
                                   } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                       });
                                   }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }];
    }
}

- (void)showSearch {
    [self showSearch:!_searchMode];
}

- (void)showSearch:(BOOL)showIt {
    _searchMode = showIt;
    [self.view bringSubviewToFront:_searchTable];
    
    if (showIt) {
        [_searchBar becomeFirstResponder];
    } else {
        _searchBar.text = @"";
        [_searchBar resignFirstResponder];
        _searchTable.alpha = 0;
    }
    
    //_searchBar.showsCancelButton = YES;
    [UIView animateWithDuration:0.5 animations:^{
        _searchBar.alpha = (showIt)? 1:0;
        _searchBar.frame = CGRectMake(0, 0, width(self.view), 40);
        _searchTable.frame = CGRectMake(0, _searchMode?40:0, width(self.view), height(self.view)-(_searchMode?40:0));
        _cv.frame = CGRectMake(0, _searchMode?40:0, width(self.view), height(self.view)-(_searchMode?40:0));
    }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([_searchBar.text length]) {
        [_roSearchMyPlaces cancel];
        [self searchUserPlaces];
        _searchTable.alpha = 1;
    } else {
        _searchTable.alpha = 0;
        [_searchTable reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self showSearch:NO];
    [_searchTable reloadData];
    _searchBar.text = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
}

- (void)searchUserPlaces {
    __weak ProfileVC *weakSelf = self;
    _roSearchMyPlaces = [OOAPI getRestaurantsViaYouSearchForUser:_profileOwner.userID
                                                         withTerm:_searchBar.text
                                                          success:^(NSArray *restaurants) {
                                                              _searchResultsArray = restaurants;
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [weakSelf.searchTable reloadData];
                                                              });
                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                                                              NSLog  (@"ERROR FETCHING YOU'S RESTAURANTS: %@",e );
                                                              
                                                          }
                          ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchResultsArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantTVCell *cell = [tableView dequeueReusableCellWithIdentifier:kRestaurantCellIdentifier];
    cell.restaurant = [_searchResultsArray objectAtIndex:indexPath.row];
    cell.nc = self.navigationController;
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantObject *ro = [_searchResultsArray objectAtIndex:indexPath.row];
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    ANALYTICS_EVENT_UI(@"RestaurantVC-from-Profile-Search");
    vc.title = trimString(ro.name);
    vc.restaurant = ro;
    //vc.eventBeingEdited = self.eventBeingEdited;
    [self.navigationController pushViewController:vc animated:YES];
}


//------------------------------------------------------------------------------
// Name:    handleListAltered
// Purpose: If one of our list objects was deleted then update our UI.
//------------------------------------------------------------------------------
- (void)handleListAltered: (NSNotification*)not
{
    NSLog (@"LIST ALTERED");
    //[self getLists];
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
- (void)handlePhotoDeleted:(NSNotification *)not
{
    BOOL foundIt = NO;

    id object = not.object;
    MediaItemObject *mio = nil;
    
    if ([object isKindOfClass:[MediaItemObject class]]) {
        mio = (MediaItemObject *)object;
    }

    if (mio) {
        for (MediaItemObject* item in _arrayPhotos) {
            if (item.mediaItemId == mio.mediaItemId) {
                foundIt = YES;
                break;
            }
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
    _cv.frame = CGRectMake(0, _searchMode?40:0, width(self.view), height(self.view)-(_searchMode?40:0));
    //self.cv.frame = self.view.bounds;
    CGFloat w = width(self.view);
    self.uploadProgressBar.frame = CGRectMake(0, 0, w, 12);
    [_cv.collectionViewLayout invalidateLayout];
    
    _profilePhoto.frame = self.view.bounds;
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
//            weakSelf.listsAndPhotosLayout.userHasSpecialties = weakSelf.profileOwner.hasSpecialties;
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
    [api getListsOfUser:((_userID) ? _userID : _profileOwner.userID)
         withRestaurant:0
             includeAll:YES
                success:^(NSArray *foundLists) {
                    NSLog (@"NUMBER OF LISTS FOR USER:  %ld", (long)foundLists.count);
                    weakSelf.arrayLists = foundLists;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.aiv stopAnimating];
                        [weakSelf.cv reloadData];
                        [weakSelf.headerView refreshUserStats];
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                    NSLog(@"ERROR WHILE GETTING LISTS FOR USER: %@",e);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.aiv stopAnimating];
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
                           [weakSelf.cv reloadData];
                           [weakSelf.headerView refreshUserStats];
                       });
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog  (@"FAILED TO GET PHOTOS");
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [weakSelf.aiv stopAnimating];
                       });
                   }];
}

- (void)refetchListsPhotosAndStats
{
    [self getSpecialties];
    [self.refreshControl endRefreshing];
    
    //_viewingLists = (_userInfo.userType == kUserTypeTrusted) ? YES:NO;

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
    UIImage *image =  info[@"UIImagePickerControllerEditedImage"];
    if (!image) {
        image = info[@"UIImagePickerControllerOriginalImage"];
    }
    if (!image || ![image isKindOfClass:[UIImage class]])
        return;
    
    __weak ProfileVC *weakSelf = self;
    
    if (_pickerIsForRestaurants) {
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }

        CGSize s = image.size;
        if (s.width) {
            _imageToUpload = [UIImage imageWithImage:image scaledToSize:CGSizeMake(kGeomUploadWidth, kGeomUploadWidth*s.height/s.width)];
        }
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [self imageConfirmedWithMediaWithInfo:info];
        } else {
            ConfirmPhotoVC *vc = [ConfirmPhotoVC new];
            vc.photoInfo = info;
            vc.iv.image = _imageToUpload;
            vc.delegate = self;
            
            UINavigationController *nc = [[UINavigationController alloc] init];
            
            [nc addChildViewController:vc];
            [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
            [nc.navigationBar setTranslucent:YES];
            nc.view.backgroundColor = [UIColor clearColor];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self.navigationController presentViewController:nc animated:YES completion:^{
                    [vc.view setNeedsUpdateConstraints];
                }];
            }];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [weakSelf setUserPhoto: image];
        }];
        
    }
}

- (void)confirmPhotoVCCancelled:(ConfirmPhotoVC *)confirmPhotoVC getNewPhoto:(BOOL)getNewPhoto {
    [self dismissViewControllerAnimated:YES completion:^{
        if (getNewPhoto) {
            [self showPhotoLibraryUI];
        }
    }];
}

- (void)confirmPhotoVCAccepted:(ConfirmPhotoVC *)confirmPhotoVC photoInfo:(NSDictionary *)photoInfo image:(UIImage *)image {
    [self dismissViewControllerAnimated:YES completion:^{
        [self imageConfirmedWithMediaWithInfo:photoInfo];
    }];
}

- (void)imageConfirmedWithMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSURL *url = info[@"UIImagePickerControllerReferenceURL"];
    
    __weak ProfileVC *weakSelf = self;
    
    if (url) {
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:url resultBlock:^(ALAsset *asset) {
            NSDictionary *metadata = asset.defaultRepresentation.metadata;
            if (metadata) {
                NSString *longitudeRef = metadata[@"{GPS}"][@"LongitudeRef"];
                NSNumber *longitude = metadata[@"{GPS}"][@"Longitude"];
                NSString *latitudeRef = metadata[@"{GPS}"][@"LatitudeRef"];
                NSNumber *latitude = metadata[@"{GPS}"][@"Latitude"];
                
                if ([longitudeRef isEqualToString:@"W"]) longitude = [NSNumber numberWithDouble:-[longitude doubleValue]];
                
                if ([latitudeRef isEqualToString:@"S"]) latitude = [NSNumber numberWithDouble:-[latitude doubleValue]];
                
                if (longitude && latitude) {
                    CLLocationCoordinate2D photoLocation = CLLocationCoordinate2DMake([latitude doubleValue],
                                                                                      [longitude doubleValue]);
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    [weakSelf showRestaurantPickerAtCoordinate:photoLocation];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [weakSelf showMissinGPSMessage];
                }
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
                [weakSelf showMissinGPSMessage];
            }
        } failureBlock:^(NSError *error) {
            //User denied access
            NSLog(@"Unable to access image: %@", error);
            [self dismissViewControllerAnimated:YES completion:nil];
            [weakSelf showMissinGPSMessage];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [weakSelf showMissinGPSMessage];
    }
}

- (void)showMissinGPSMessage {
    [self showRestaurantPickerAtCoordinate:[LocationManager sharedInstance].currentUserLocation];
}

- (void)showRestaurantPickerAtCoordinate:(CLLocationCoordinate2D)location {
    RestaurantPickerVC *restaurantPicker = [[RestaurantPickerVC alloc] init];
    restaurantPicker.location = location;
    restaurantPicker.delegate = self;
    restaurantPicker.imageToUpload = _imageToUpload;
    
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    [nc addChildViewController:restaurantPicker];
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController presentViewController:nc animated:YES completion:^{
        [restaurantPicker.view setNeedsUpdateConstraints];
    }];
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
    _restaurantPicker.delegate = self;
    _restaurantPicker.location = [LocationManager sharedInstance].currentUserLocation;
    _restaurantPicker.imageToUpload = _imageToUpload;
    
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    [nc addChildViewController:_restaurantPicker];
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
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
        [OOAPI convertGoogleIDToRestaurant:_selectedRestaurant.googleID success:^(RestaurantObject *restaurant) {
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
                         [FBSDKAppEvents logEvent:kAppEventListCreated];
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
    SearchVC *vc= [[SearchVC alloc] init];
    vc.listToAddTo= list;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleUpperRightButton
{
    __weak ProfileVC *weakSelf = self;
    
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!result) {
            if (_viewingLists) {
                [weakSelf presentUnverifiedMessage:@"To create a list you will need to verify your email.\n\nCheck your email for a verification link."];
            } else {
                [weakSelf presentUnverifiedMessage:@"To upload a photo you will need to verify your email.\n\nCheck your email for a verification link."];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_viewingLists) {
                    [weakSelf userPressedNewList];
                } else {
                    _pickerIsForRestaurants= YES;
                    [weakSelf showPickPhotoUI];
                }
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"*** Problem verifying user");
        if (error.code == kCFURLErrorNotConnectedToInternet) {
            message(@"You do not appear to be connected to the internet.");
        } else {
            message(@"There was a problem verifying your account.");
        }
        return;
    }];
}

- (void)userTappedOnLists
{
    _viewingLists = YES;
    [_listsAndPhotosLayout setShowingLists:YES];

    if (_viewingOwnProfile) {
        [self removeNavButtonForSide:kNavBarSideTypeRight];
        [self addNavButtonWithIcon:kFontIconCreateListThick target:self action:@selector(handleUpperRightButton) forSide:kNavBarSideTypeRight isCTA:YES];
    }

    _listsAndPhotosLayout.thereAreNoItems= _arrayLists.count==0;
    [self getLists];
}

- (void)userTappedOnPhotos
{
    _viewingLists = NO;
    [_listsAndPhotosLayout setShowingLists:NO];
    
    if (_viewingOwnProfile) {
        [self removeNavButtonForSide:kNavBarSideTypeRight];
        [self addNavButtonWithIcon:kFontIconPhotoThick target:self action:@selector(handleUpperRightButton) forSide:kNavBarSideTypeRight isCTA:YES];
    }
    
    _listsAndPhotosLayout.thereAreNoItems= _arrayPhotos.count==0;
    [self getPhotos];
}

#pragma mark - Collection View stuff

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ProfileVCCVLayout *)collectionViewLayout heightForheader:(NSUInteger)section {
    return CGRectGetHeight(_headerView.frame);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:( ProfileVCCVLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if  (_viewingLists ) {
        return kGeomHeightStripListRow;
    } else {
        if (!_arrayPhotos.count) {
            return kGeomHeightStripListRow;
        }
        NSInteger row = indexPath.row;
        MediaItemObject *mio = row <_arrayPhotos.count ? _arrayPhotos[row] :nil;
        if  (mio) {
            CGFloat w = mio.width;
            CGFloat h = mio.height;
            CGFloat aspect = (h > 0)? w/h:0.05;
            CGFloat availableWidth = [UIScreen mainScreen ].bounds.size.width/2;
            CGFloat height = availableWidth/aspect;
            return height + ((mio.source == kMediaItemTypeOomami)? 30:0) ;
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ProfileHeaderView *view = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        _listsAndPhotosLayout.userIsSelf = _viewingOwnProfile;

        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                 withReuseIdentifier:kProfileHeaderCellIdentifier
                                                        forIndexPath:indexPath];
        
        view.delegate = self;
        [view setUserInfo:_profileOwner];
        view.vc = self;
        
        _headerView = view;
//        [DebugUtilities addBorderToViews:@[_headerView, _cv]];
        return view;
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (_viewingLists) {
        NSLog(@"section:%ld row:%ld", (long)indexPath.section, (long)indexPath.row);
        
        NSUInteger total= self.arrayLists.count;
        if (!total) {
            ProfileEmptyCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:kProfileEmptyCellIdentifier
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
        
        ListStripCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProfileListCellIdentifier
                                                                          forIndexPath:indexPath];
        
        NSArray *a = self.arrayLists;
        ListObject *listItem = a[row];
        listItem.listDisplayType = KListDisplayTypeStrip;
        
        cell.navigationController = self.navigationController;
        cell.listItem = listItem;
        cell.userContext = _userInfo;
        
        return cell;
    }
    else {
        NSUInteger total= self.arrayPhotos.count;
        if (!total) {
            ProfileEmptyCell*cell= [collectionView dequeueReusableCellWithReuseIdentifier:kProfileEmptyCellIdentifier
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
        
        PhotoCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProfilePhotoCellIdentifier
                                                                      forIndexPath:indexPath];
        NSArray *a = self.arrayPhotos;
        MediaItemObject *object = a[row];
        cell.mediaItemObject = object;
        cell.backgroundColor = UIColorRGBA(kColorTileBackground);
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

- (void)photoCell:(PhotoCVCell *)photoCell userNotVerified:(MediaItemObject *)mio {
    [self presentUnverifiedMessage:@"To yum the photo you will need to verify your email.\n\nCheck your email for a verification link."];
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
    [vc overrideIsFoodWith:YES];

    [nc addChildViewController:vc];
    
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
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
                           _mediaItemBeingEdited.caption = text;
                           NOTIFY_WITH(kNotificationMediaItemAltered, _mediaItemBeingEdited);
                           _mediaItemBeingEdited= nil;
                           
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
    
    NSInteger row = indexPath.row;
    if  (_viewingLists) {
        if (!_arrayLists.count) {
            [self userPressedEmptyCell];
            return;
        }
        ListObject *object = _arrayLists[row];
        RestaurantListVC *vc = [[RestaurantListVC alloc] init];
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
            [self launchViewPhoto:mediaObject restaurant:nil originFrame:originRect index:row];
        } else {
            __weak ProfileVC *weakSelf = self;
            OOAPI *api = [[OOAPI alloc] init];
            [api getRestaurantWithID:stringFromUnsigned(restaurantID)
                              source:kRestaurantSourceTypeOomami
                             success:^(RestaurantObject *restaurant) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (restaurant) {
                                         [weakSelf launchViewPhoto:mediaObject restaurant:restaurant originFrame:originRect index:row];
                                     } else {
                                         [weakSelf launchViewPhoto:mediaObject restaurant:nil originFrame:originRect index:row];
                                     }
                                 });
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [weakSelf launchViewPhoto:mediaObject restaurant:nil originFrame:originRect index:row];
                                 });
                             }];
        }
    }
}

- (void)launchViewPhoto:(MediaItemObject*)mio restaurant:(RestaurantObject*)restaurant originFrame:(CGRect)originFrame index:(NSUInteger)index
{
    ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];    
    vc.originRect = originFrame;
    vc.mio = mio;
    vc.restaurant = restaurant;
    vc.items = _arrayPhotos;
    vc.currentIndex = index;
    vc.delegate = self;
    vc.dismissNCDelegate = self;
    vc.dismissTransitionDelegate = self;
    
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
        animator.duration = 0.8;
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

- (void)userPressedSettings:(id)sender;
{
    if (!_viewingOwnProfile) {
        [self showProfilePhotoFullScreen:sender];
        return;
    }
    
    if  (self.uploading) {
        return;
    }
    __weak  ProfileVC *weakSelf = self;
    
    _optionsAC = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"What would you like to do?\n%@", [Common versionString]] preferredStyle:UIAlertControllerStyleActionSheet];
    
    _optionsAC.popoverPresentationController.sourceView = sender;
    _optionsAC.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;

    UIAlertAction *logout = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
        [[Settings sharedInstance] removeUser];
        [[Settings sharedInstance] removeMostRecentLocation];
        [[Settings sharedInstance] removeDateString];
        [[Settings sharedInstance] removeSearchRadius];
        [APP clearCache];
        [APP.tabBar performSegueWithIdentifier:@"welcomeUISegue" sender:self];
    }];
    
    UIAlertAction *actionProfilePicture = [UIAlertAction actionWithTitle:@"Change Profile Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf  userPressedChangeProfilePicture];
    }];
    
    UIAlertAction *actionSendFeedback = [UIAlertAction actionWithTitle:@"Send Feedback" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [Instabug invokeWithInvocationMode:IBGInvocationModeFeedbackSender];
    }];
    
    UIAlertAction *manageTags = [UIAlertAction actionWithTitle:@"Manage Tags" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ManageTagsVC *vc = [[ManageTagsVC alloc] init];
        [weakSelf .navigationController pushViewController:vc animated:YES];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [_optionsAC addAction: actionProfilePicture];
    [_optionsAC addAction:manageTags];
    [_optionsAC addAction:actionSendFeedback];
    [_optionsAC addAction:logout];
    [_optionsAC addAction:cancel];
    [self presentViewController:_optionsAC animated:YES completion:nil];
}

- (void)showPhoto {
    
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

- (void)showCameraUI {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera ;
        
        [self presentViewController:picker animated:YES completion:NULL];
    } else if(authStatus == AVAuthorizationStatusDenied) {
        [self getAccessToCamera];
    } else if(authStatus == AVAuthorizationStatusRestricted) {
        [self getAccessToCamera];
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", AVMediaTypeVideo);
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = NO;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera ;
                
                [self presentViewController:picker animated:YES completion:NULL];
            } else {
                NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                [self getAccessToCamera];
            }
        }];
    } else {
        // impossible, unknown authorization status
    }
}

- (void)getAccessToCamera {
    UIAlertController *cameraAccess = [UIAlertController alertControllerWithTitle:@"Access Required" message:@"You will need to give Oomami access to your camera from settings in order to take a photo that you can upload." preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction *gotoSettings = [UIAlertAction actionWithTitle:@"Give Access"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [Common goToSettings:kAppSettingsCamera];
                                                           }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     }];
    [cameraAccess addAction:gotoSettings];
    [cameraAccess addAction:cancel];
    [self presentViewController:cameraAccess animated:YES completion:^{
        ;
    }];
}

- (void)showPhotoLibraryUI
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    // check the status for ALAuthorizationStatusAuthorized or ALAuthorizationStatusDenied e.g
    
    if (status == ALAuthorizationStatusDenied) {
        //show alert for asking the user to give permission
        
        UIAlertController *photosAccess = [UIAlertController alertControllerWithTitle:@"Access Required" message:@"You will need to give Oomami access to your photos from settings in order to pick a photo to upload." preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction *gotoSettings = [UIAlertAction actionWithTitle:@"Give Access"
                                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                   [Common goToSettings:kAppSettingsPhotos];
                                                               }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                         }];
        [photosAccess addAction:gotoSettings];
        [photosAccess addAction:cancel];
        [self presentViewController:photosAccess animated:YES completion:^{
            ;
        }];
        
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)presentUnverifiedMessage:(NSString *)message {
    UnverifiedUserVC *vc = [[UnverifiedUserVC alloc] initWithSize:CGSizeMake(250, 200)];
    vc.delegate = self;
    vc.action = message;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.transitioningDelegate = vc;
    self.navigationController.delegate = vc;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:vc animated:YES completion:^{
        }];
    });
}

- (void)unverifiedUserVCDismiss:(UnverifiedUserVC *)unverifiedUserVC {
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
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
        _labelIcon.textColor= UIColorRGBA(kColorTextActive);

        _labelMessage= makeLabel(self,  @"?", kGeomFontSizeHeader);
        _labelMessage.textColor = UIColorRGBA(kColorGrayMiddle);
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
    
    CGFloat w = width(self);

    CGSize messageSize = [_labelMessage sizeThatFits:CGSizeMake(w,200)];

    switch (_mode) {
        case PROFILE_EMPTYCELL_LIST:
        case PROFILE_EMPTYCELL_PHOTO:{
            [_labelIcon sizeToFit];
            CGFloat w1 = _labelIcon.frame.size.width;
            CGFloat w2 = messageSize.width;
            CGFloat requiredWidth = w1+w2+kGeomSpaceInter;
            CGFloat x = (w-requiredWidth)/2;

            _labelIcon.frame = CGRectMake(x, height(self)/2, w1, kGeomHeightButton);
            x+= w1 + kGeomSpaceInter;
            _labelMessage.frame = CGRectMake(x, height(self)/2, w2, kGeomHeightButton);
        } break;
            
        default:{
            CGFloat w1 = messageSize.width;
            CGFloat x =  (w-w1)/2;
            _labelMessage.frame = CGRectMake(x,height(self)/2,w1,kGeomHeightButton);
        } break;
    }
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    [self setMessageMode];
}

@end


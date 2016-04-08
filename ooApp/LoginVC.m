//------------------------------------------------------------------------------
//
//  LoginVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/17/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "LoginVC.h"
#import "AppDelegate.h"
#import "DebugUtilities.h"
#import "LocationManager.h"
#import "OONetworkManager.h"
#import "NSString+MD5.h"
#import "CreateUsernameVC.h"
#import "OOAPI.h"
#import "SocialMedia.h"
#import "UIImageEffects.h"
#import "OOErrorObject.h"
#import <Instabug/Instabug.h>

@interface LoginVC ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) FBSDKLoginButton *facebookLoginButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIButton *tryAgain;
@property (nonatomic, strong) UILabel *facebookMessage;
@property (nonatomic, strong) UILabel *quickMessage;
@property (nonatomic, strong) UILabel *emailMessage;
@property (nonatomic, strong) UILabel *labelMessage;
@property (nonatomic, assign) BOOL wentToExplore;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;
@property (nonatomic, strong) UILabel *info;
@property (nonatomic, strong) UIView *horizontalLine;
@end

@implementation LoginVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void) viewDidLoad
{
    ENTRY;

    [super viewDidLoad];
    
    _wentToExplore = NO;
    
    _aiv = [[UIActivityIndicatorView alloc] init];
    _aiv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    _info = [[UILabel alloc] init];
    [_info withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorTextReverse backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
    
    _overlay = [[UIView alloc] init];
    _overlay.backgroundColor = UIColorRGBOverlay(kColorBlack, 0.35);
    

    
    UIImage *backgroundImage = [UIImageEffects imageByApplyingBlurToImage:[UIImage imageNamed:@"background_image.png"] withRadius:30 tintColor: UIColorRGBOverlay(kColorBlack, 0) saturationDeltaFactor:1 maskImage:nil];

    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);

    _horizontalLine = [[UIView alloc] init];
    _horizontalLine.backgroundColor = UIColorRGBA(kColorBordersAndLines);
    
    _backgroundImageView = makeImageView(self.view, backgroundImage);
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.opaque = NO;
    
    _facebookLoginButton = [[FBSDKLoginButton alloc] init];
    [_facebookLoginButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Facebook"] forState:UIControlStateNormal];
    _facebookLoginButton.delegate = self;
    _facebookLoginButton.layer.cornerRadius = 0;
    _facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    _tryAgain = [UIButton buttonWithType:UIButtonTypeCustom];
    [_tryAgain withText:@"Try Again" fontSize:kGeomFontSizeH3 width:100 height:kGeomHeightButton backgroundColor:kColorButtonBackground textColor:kColorText borderColor:kColorClear target:self selector:@selector(initiateLoginFlow)];
    _tryAgain.titleLabel.font = [UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH2];
    _tryAgain.layer.cornerRadius = kGeomCornerRadius;

    _emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_emailButton withText:@"Email" fontSize:kGeomFontSizeH3 width:100 height:kGeomHeightButton backgroundColor:kColorBackgroundTheme textColor:kColorTextActive borderColor:kColorClear target:self selector:@selector(showEmailLogin)];
    _emailButton.titleLabel.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _emailButton.layer.cornerRadius = kGeomCornerRadius;

    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton withIcon:kFontIconBack fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:kGeomDimensionsIconButton backgroundColor:kColorClear target:self selector:@selector(goBack)];
    [_backButton setTitleColor:UIColorRGBA(kColorNavBarText) forState:UIControlStateNormal];

    _quickMessage = [[UILabel alloc] init];
    [_quickMessage withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorTextReverse backgroundColor:kColorClear];
    _quickMessage.text = @"Log in quickly:";
    
    _facebookMessage = [[UILabel alloc] init];
    [_facebookMessage withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4] textColor:kColorTextReverse backgroundColor:kColorClear];
    _facebookMessage.textAlignment = NSTextAlignmentCenter;
    _facebookMessage.text = @"Oomami will never post to Facebook without your permission";

    _emailMessage = [[UILabel alloc] init];
    [_emailMessage withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorTextReverse backgroundColor:kColorClear];
    _emailMessage.text = @"or use your email:";
    
    [self.view addSubview:_backgroundImageView];
    [self.view addSubview:_overlay];
    [self.view addSubview:_facebookMessage];
    [self.view addSubview:_quickMessage];
    [self.view addSubview:_emailMessage];
    [self.view addSubview:_facebookLoginButton];
    [self.view addSubview:_emailButton];
    [self.view addSubview:_aiv];
    [self.view addSubview:_info];
    [self.view addSubview:_tryAgain];
    [self.view addSubview:_backButton];
    [self.view addSubview:_horizontalLine];
    
    _tryAgain.hidden = YES;
    
    //[DebugUtilities addBorderToViews:@[_backButton]];
}

- (void)doLayout
{
    CGFloat w = width(self.view);
    CGFloat buttonWidth = (IS_IPAD) ? kGeomWidthButtoniPadMax : w - 4*kGeomSpaceEdge;
    
    _backgroundImageView.frame = self.view.bounds;
    _backgroundImageView.clipsToBounds = YES;
    
    _overlay.frame = _backgroundImageView.bounds;

    CGFloat y = kGeomHeightNavBarStatusBar;
    
    y += kGeomSpaceEdge;
    
    [_quickMessage sizeToFit];
    [_emailMessage sizeToFit];
    
    _quickMessage.frame = CGRectMake((w-buttonWidth)/2, y, buttonWidth, CGRectGetHeight(_quickMessage.frame));

    y -= 5; // as per Jay
    [_labelMessage sizeToFit];
    _labelMessage.frame = CGRectMake(0, y, w, _labelMessage.frame.size.height);
    
    _facebookLoginButton.frame =  CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_quickMessage.frame) + kGeomSpaceEdge, buttonWidth, kGeomHeightButton);
    
    [_facebookMessage sizeToFit];
    _facebookMessage.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_facebookLoginButton.frame) + kGeomSpaceEdge, buttonWidth, CGRectGetHeight(_facebookMessage.frame));
    
    _horizontalLine.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_facebookMessage.frame) + kGeomSpaceEdge, buttonWidth, 1);

    _emailMessage.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_horizontalLine.frame) + kGeomSpaceEdge, buttonWidth, CGRectGetHeight(_emailMessage.frame));

    _emailButton.frame =  CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_emailMessage.frame) + kGeomSpaceEdge, buttonWidth, kGeomHeightButton);

    CGFloat facebookButtonHeight = facebookButtonHeight = kGeomHeightButton;
    
    _backButton.frame = CGRectMake(kGeomSpaceEdge, kGeomHeightStatusBar, kGeomDimensionsIconButton, kGeomDimensionsIconButton);
    
    [_aiv sizeToFit];
    _aiv.center = self.view.center;
    _tryAgain.center = self.view.center;
    
    CGRect frame = _info.frame;
    frame.size = [_info sizeThatFits:CGSizeMake(buttonWidth, 100)];
    frame.origin = CGPointMake((w-CGRectGetWidth(frame))/2, CGRectGetMaxY(_tryAgain.frame) + kGeomSpaceEdge);
    _info.frame = frame;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    NSLog(@"LoginVC bounds= %@", NSStringFromCGRect(self.view.bounds));
    [self doLayout];
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN(@( object_getClassName(self)));

    _wentToExplore = NO;
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    showMainUI
// Purpose:
//------------------------------------------------------------------------------
- (void)showMainUI
{
    ENTRY;

    if (_wentToExplore) { // Prevent duplicate simultaneous calls.
        return;
    }
    _wentToExplore= YES;
    
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    if (!facebookToken) {
        NSLog  (@"THERE IS NO FACEBOOK TOKEN");
    }
    else {
        NSSet *permissions = [facebookToken permissions];
        NSLog(@"USER PERMISSIONS = %@", permissions);
    }
    
    //---------------------------------------------------
    // RULE: If we have valid user information already
    // that means the user logged in via OO but not FB,
    // so we must update the backend to add the FB
    // user ID.
    //
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSString *email = userInfo.email;
    if (email.length > 1 && !userInfo.userID) {
        NSLog(@"user has OO account already but this is their first Facebook login.");
    }
    
    if (email.length) {
        [Instabug setUserEmail:email];
    }

    //---------------------------------------------------
    // RULE: If the application was deleted, we may have
    //  the Facebook ID but not the email address and
    //  certainly not the authorization token. In this case
    //  we need to ask FB for the email address.
    //
    NSString *token = userInfo.backendAuthorizationToken;
    
    NSString *identifier = facebookToken.userID;
    if (facebookToken && identifier && (!token || !token.length) && (! email || !email.length)) {
        NSLog(@"HAVE FACEBOOK TOKEN BUT NO EMAIL AND NO AUTHORIZATION TOKEN");
//        [self fetchEmailFromFacebookFor:identifier];
    } else {
        [self showMainUIWithUserEmail:email];
    }
}

- (void)showMainUIWithUserEmail:(NSString *)email
{
    ENTRY;
    
    if  (!email || !email.length) {
        LOGS(@"NO EMAIL.");
        return;
    }
    
    if (!is_reachable()) {
        static BOOL toldThem = NO;
        if (!toldThem) {
            toldThem = YES;
            message(@"The Internet is not reachable.");
        }
        
        [self performSelector:@selector(showMainUIWithUserEmail:) withObject:email afterDelay:1];
        return;
    }
    
    [SocialMedia fetchProfilePhotoWithCompletionBlock:NULL];
    
    UserObject* userInfo = [Settings sharedInstance].userObject;

    NSLog (@"USERNAME %@",userInfo.username);

    self.navigationController.delegate = nil;
    self.transitioningDelegate = nil;

    if (userInfo.username.length) {
        [self performSegueWithIdentifier:@"mainUISegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"gotoCreateUsername" sender:self];
    }
}

//------------------------------------------------------------------------------
// Name:    viewDidAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    ENTRY;
    [super viewDidAppear:animated];
}

- (void)showEmailLogin {
    [self performSegueWithIdentifier:@"gotoEmailLogin" sender:self];
}

- (void)initiateLoginFlow {
    _facebookLoginButton.enabled = NO;
    _tryAgain.hidden = YES;
    
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    [_aiv startAnimating];
    
    if (facebookToken) {
        _facebookLoginButton.enabled = _emailButton.enabled = NO;
        _info.hidden = NO;
        _info.text = kLoggingYouIn;
        [self.view setNeedsLayout];
        
        // Transition if the user recently logged in.
        [OOAPI authWithFacebookToken:facebookToken.tokenString success:^(UserObject *user, NSString *token) {
            if (token && user) {
                [_aiv stopAnimating];
                _info.hidden = YES;
                user.backendAuthorizationToken = token;
                [[Settings sharedInstance] setUserObject:user];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMainUI];
                });
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"auth failure %@", error);
            [_aiv stopAnimating];
            
            if (error.code == kCFURLErrorNotConnectedToInternet) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _tryAgain.hidden = NO;
                    _info.text = @"You don't appear to be connected to the internet. Make sure you have a good connection and try again.";
                    [self.view setNeedsLayout];
                });
            } else {
                OOErrorObject *ooError = [OOErrorObject errorFromDict:[operation.responseObject objectForKey:kKeyError]];
                if (ooError.type == kOOErrorCodeTypeConnectingAccountToUnverifiedUser) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _tryAgain.hidden = NO;
                        _info.text = @"The account's email address is registered, but has not been verified. Once you verify we'll be able to connect it to this social media account.";
                        [self.view setNeedsLayout];
                    });
                } else if (ooError.type == kOOErrorCodeTypeFacebookNeedEmailPermission) {
                    [self logout];
                    _tryAgain.hidden = NO;
                    _info.text = @"It appears you did not give Oomami access to your email address through Facebook. Your email will not be shared with anyone without your permission. If you still want to log on to Oomami using Facebook:\n\n1. Go to Facebook->Settings->Apps->All Apps->Oomami click Remove App\n2. Log in to Oomami using Facebook again, but make sure not to disable access to your email address.";
                    [self.view setNeedsLayout];
                } else {
                    [self logout];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _facebookLoginButton.enabled = _emailButton.enabled =YES;
                        [_facebookLoginButton setNeedsLayout];
                        _info.text = @"There was a problem logging you in. Try again.";
                        [self.view setNeedsLayout];
                    });
                }
            }
        }];
    } else {
        [self logout];
        [_aiv stopAnimating];
        _facebookLoginButton.enabled = _emailButton.enabled = YES;
    }
}

- (void)logout {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [[Settings sharedInstance] removeUser];
    [[Settings sharedInstance] removeMostRecentLocation];
    [[Settings sharedInstance] removeDateString];
    [[Settings sharedInstance] removeSearchRadius];
    [APP clearCache];
}

- (void)loginButtonDidimageViewLogout:(FBSDKLoginButton *)loginButton
{
    ENTRY;

    NSLog (@"loginButtonDidimageViewLogout: USER LOGGED OUT");
}

//------------------------------------------------------------------------------
// Name:    didCompleteWithResult
// Purpose:
//------------------------------------------------------------------------------
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    ENTRY;
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=email"
                                       parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSLog(@"fetched user:%@", result);
             [self initiateLoginFlow];
         } else {
             NSLog (@"Facebook server gave error %@", error);
             NSString *string = @"We had a problem logging you in via Facebook.";
             message(string);
         }
     }];
}

//------------------------------------------------------------------------------
// Name:    loginButtonDidLogOut
// Purpose:
//------------------------------------------------------------------------------
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSLog (@"USER TO LOG OUT");
}


@end

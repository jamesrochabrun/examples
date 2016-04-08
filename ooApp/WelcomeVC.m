//------------------------------------------------------------------------------
//
//  Welcome.VC
//  ooApp
//
//  Created by Anuj Gujar on 3/23/16.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "WelcomeVC.h"
#import "AppDelegate.h"
#import "DebugUtilities.h"
#import "LocationManager.h"
#import "OONetworkManager.h"
#import "NSString+MD5.h"
#import "CreateUsernameVC.h"
#import "OOAPI.h"
#import "SocialMedia.h"
#import "SignupVC.h"
#import <Instabug/Instabug.h>
#import "ShowAuthScreenAnimator.h"

@interface WelcomeVC ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *signupButton;
@property (nonatomic, strong) UIButton *tryAgain;
@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) UILabel *labelMessage;
@property (nonatomic, assign) BOOL wentToExplore;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;
@property (nonatomic, strong) UILabel *info;
@property (nonatomic, strong) UIView *verticalLine;
@end

@implementation WelcomeVC

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
    
    _overlay = [[UIView alloc] init];
    _overlay.backgroundColor = UIColorRGBOverlay(kColorBlack, 0.35);
    
    _info = [[UILabel alloc] init];
    [_info withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorNavBarText backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"background_image.png"];
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _verticalLine = [[UIView alloc] init];
    _verticalLine.backgroundColor = UIColorRGBA(kColorWhite);
    
    _backgroundImageView = makeImageView(self.view, backgroundImage);
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.opaque = NO;
    
    [Common addMotionEffectToView:_backgroundImageView];
    
    _logoLabel = [[UILabel alloc] init];
    [_logoLabel withFont:[UIFont fontWithName:kFontIcons size:width(self.view)*0.75] textColor:kColorBackgroundTheme backgroundColor:kColorClear];
    _logoLabel.text = kFontIconLogoFull;
    _logoLabel.frame = CGRectMake(0, 0, width(self.view)*0.75, IS_IPAD ? 175:100);
    
    _tryAgain = [UIButton buttonWithType:UIButtonTypeCustom];
    [_tryAgain withText:@"Try Again" fontSize:kGeomFontSizeH3 width:100 height:kGeomHeightButton backgroundColor:kColorButtonBackground textColor:kColorText borderColor:kColorClear target:self selector:@selector(initiateLoginFlow)];
    _tryAgain.titleLabel.font = [UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH2];
    _tryAgain.layer.cornerRadius = kGeomCornerRadius;
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginButton withText:@"Log In" fontSize:kGeomFontSizeH3 width:100 height:kGeomHeightButton backgroundColor:kColorTextActive textColor:kColorTextReverse borderColor:kColorClear target:self selector:@selector(showLogin)];
    _loginButton.titleLabel.font = [UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH2];
    
    _signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_signupButton withText:@"Sign Up" fontSize:kGeomFontSizeH3 width:100 height:kGeomHeightButton backgroundColor:kColorTextActive textColor:kColorTextReverse borderColor:kColorClear target:self selector:@selector(showSignup)];
    _signupButton.titleLabel.font = [UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH2];
    
    [self.view addSubview:_backgroundImageView];
    [self.view addSubview:_overlay];
    [self.view addSubview:_logoLabel];
    [self.view addSubview:_aiv];
    [self.view addSubview:_info];
    [self.view addSubview:_tryAgain];
    [self.view addSubview:_signupButton];
    [self.view addSubview:_loginButton];
    [_signupButton addSubview:_verticalLine];
    
    self.labelMessage= makeLabel(self.view,  @"What are you in the mood for?", kGeomFontSizeHeader);
    _labelMessage.textColor= UIColorRGBA(kColorWhite);
    
    _tryAgain.hidden = YES;
    //    [DebugUtilities addBorderToViews:@[_logoLabel]];
}

- (void)doLayout
{
    CGFloat h = height(self.view);
    CGFloat w = width(self.view);
    
    CGRect frame = self.view.bounds;
    frame.origin = CGPointMake(-kGeomMotionEffectDelta, -kGeomMotionEffectDelta);
    frame.size = CGSizeMake(frame.size.width+2*kGeomMotionEffectDelta, frame.size.height+2*kGeomMotionEffectDelta);
    _backgroundImageView.frame = frame;
    _backgroundImageView.clipsToBounds = YES;
    
    _overlay.frame = _backgroundImageView.bounds;
    
    CGFloat y = height(self.view)*0.25;
    _logoLabel.frame = CGRectMake((width(self.view) - width(_logoLabel))/2, y, width(_logoLabel), height(_logoLabel));
    
    y += height(_logoLabel);
        
    y -= 5; // as per Jay
    [_labelMessage sizeToFit];
    _labelMessage.frame = CGRectMake(0, y, w, _labelMessage.frame.size.height);
    
    CGFloat facebookButtonHeight = facebookButtonHeight = kGeomHeightButton;
    
    _signupButton.frame = CGRectMake(0, h-kGeomHeightButton, w/2, kGeomHeightButton);
    _loginButton.frame = CGRectMake(w-w/2, h-kGeomHeightButton, w/2, kGeomHeightButton);
    
    _loginButton.layer.cornerRadius =
    _signupButton.layer.cornerRadius = 0;
    
    _tryAgain.frame =  CGRectMake((w-CGRectGetWidth(_tryAgain.frame))/2, h-3*kGeomHeightButton - kGeomSpaceInter, CGRectGetWidth(_tryAgain.frame), kGeomHeightButton);
    [_aiv sizeToFit];
    _aiv.center = _tryAgain.center;
    
    _verticalLine.frame = CGRectMake(CGRectGetWidth(_signupButton.frame)-1, kGeomSpaceLineEdgeBuffer, 1, CGRectGetHeight(_signupButton.frame)-2*kGeomSpaceLineEdgeBuffer);
    
    frame = _info.frame;
    frame.size = [_info sizeThatFits:CGSizeMake(width(self.view) - 2*kGeomSpaceEdge, 100)];
    frame.size.width = width(self.view) - 2*kGeomSpaceEdge;
    frame.origin = CGPointMake(kGeomSpaceEdge, CGRectGetMaxY(_tryAgain.frame) + kGeomSpaceEdge);
    _info.frame = frame;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    NSLog(@"LoginVC bounds= %@", NSStringFromCGRect(self.view.bounds));
    [self doLayout];
}

- (void)showLogin {
    [self performSegueWithIdentifier:@"gotoLogin" sender:self];
}

- (void)showSignup {
    [self performSegueWithIdentifier:@"gotoSignup" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"gotoSignup"])
    {
        // Get reference to the destination view controller
        SignupVC *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.navControllerDelegate = self;
    }
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
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.delegate = self;
    self.transitioningDelegate = self;
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
    
    //    NSString *saltedString = [NSString stringWithFormat:@"%@.%@", email, SECRET_BACKEND_SALT];
    //    NSString *md5 = [saltedString MD5String];
    //    md5 = [md5 lowercaseString];
    //    seekingToken = YES;
    //
    
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
    _signupButton.hidden =
    _loginButton.hidden = YES;

    UserObject *user = [Settings sharedInstance].userObject;
    if (user.backendAuthorizationToken && user.userID) {
        NSString *token = user.backendAuthorizationToken;
        _info.hidden = NO;
        [_aiv startAnimating];
        _info.text = kLoggingYouIn;
        [self.view setNeedsLayout];
        [OOAPI getUserWithID:user.userID success:^(UserObject *user) {
            user.backendAuthorizationToken = token;
            [[Settings sharedInstance] setUserObject:user];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_aiv stopAnimating];
                _info.hidden = YES;
                [self showMainUI];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            _info.hidden = YES;
            [_aiv stopAnimating];
            _signupButton.hidden =
            _loginButton.hidden = NO;
        }];
    } else {
        FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
        if (facebookToken) {
            [self initiateLoginFlow:facebookToken];
        } else {
            _info.hidden = YES;
            _signupButton.hidden =
            _loginButton.hidden = NO;
        }
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if (operation == UINavigationControllerOperationPush) {

        ShowAuthScreenAnimator *animator = [[ShowAuthScreenAnimator alloc] init];
        animator.presenting = YES;
        animator.duration = 0.35;
        animationController = animator;
    } else if (operation == UINavigationControllerOperationPop) {
        ShowAuthScreenAnimator *animator = [[ShowAuthScreenAnimator alloc] init];
        animator.presenting = NO;
        animator.duration = 0.35;
        animationController = animator;
    } else {
        NSLog(@"*** operation=%ld, fromVC=%@ , toVC=%@", (long)operation, [fromVC class], [toVC class]);
    }
    
    return animationController;
}

- (void)initiateLoginFlow:(FBSDKAccessToken *)facebookToken {
    _tryAgain.hidden = YES;
    
    
    [_aiv startAnimating];
    
    if (facebookToken) {
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
                [self logout];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _info.text = @"There was a problem logging you in. Try again.";
                    _info.hidden = YES;
                    _signupButton.hidden =
                    _loginButton.hidden = NO;
                    [self.view setNeedsLayout];
                });
            }
        }];
    } else {
        [self logout];
        [_aiv stopAnimating];
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

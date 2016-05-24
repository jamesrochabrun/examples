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
#import "IntroScreenView.h"

@interface WelcomeVC ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *signupButton;
//@property (nonatomic, strong) UIButton *tryAgain;
@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UILabel *answerLabel;
@property (nonatomic, strong) UIButton *answerButton;
@property (nonatomic, assign) BOOL wentToExplore;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;
@property (nonatomic, strong) UILabel *info;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *introScreensScrollView;
@property (nonatomic, strong) UIScrollView *activeScrollView;
@property (nonatomic, strong) NSArray *introScreenBackgroundViews;
@property (nonatomic, strong) NSArray *introScreenViews;
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
    
    _activeScrollView = [UIScrollView new];
    _activeScrollView.delegate = self;
    
    _introScreensScrollView = [UIScrollView new];
    _introScreensScrollView.delegate = self;
    
    _introScreensScrollView.contentOffset = _activeScrollView.contentOffset;
    
    _aiv = [[UIActivityIndicatorView alloc] init];
    _aiv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    _overlay = [[UIView alloc] init];
    _overlay.backgroundColor = UIColorRGBOverlay(kColorBlack, 0.45);
    
    _info = [[UILabel alloc] init];
    [_info withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorNavBarText backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
    
    UIImage *backgroundImage = [UIImage imageNamed:kImageBackgroundImage];
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _verticalLine = [[UIView alloc] init];
    _verticalLine.backgroundColor = UIColorRGBA(kColorWhite);
    
    _backgroundImageView = [UIImageView new];
    _backgroundImageView.image = backgroundImage;
    [self.view addSubview:_backgroundImageView];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.opaque = NO;
    
    [Common addMotionEffectToView:_backgroundImageView];
    
    _logoLabel = [[UILabel alloc] init];
    [_logoLabel withFont:[UIFont fontWithName:kFontIcons size:width(self.view)*0.75] textColor:kColorBackgroundTheme backgroundColor:kColorClear];
    _logoLabel.text = kFontIconLogoFull;
    _logoLabel.frame = CGRectMake(0, 0, width(self.view)*0.75, IS_IPAD ? 175:100);
    
//    _tryAgain = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_tryAgain withText:@"Try Again" fontSize:kGeomFontSizeH3 width:100 height:kGeomHeightButton backgroundColor:kColorButtonBackground textColor:kColorText borderColor:kColorClear target:self selector:@selector(startAuthFlow)];
//    _tryAgain.titleLabel.font = [UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH2];
//    _tryAgain.layer.cornerRadius = kGeomCornerRadius;
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginButton withText:@"Log In" fontSize:kGeomFontSizeH3 width:100 height:kGeomHeightButton backgroundColor:kColorTextActive textColor:kColorTextReverse borderColor:kColorClear target:self selector:@selector(showLogin)];
    _loginButton.titleLabel.font = [UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH2];
    
    _signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_signupButton withText:@"Sign Up" fontSize:kGeomFontSizeH3 width:100 height:kGeomHeightButton backgroundColor:kColorTextActive textColor:kColorTextReverse borderColor:kColorClear target:self selector:@selector(showSignup)];
    _signupButton.titleLabel.font = [UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH2];
    
    _questionLabel = [UILabel new];
    [_questionLabel withFont:[UIFont fontWithName: kFontLatoRegular size:kGeomFontSizeH1] textColor:kColorTextReverse backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
    _questionLabel.text = @"What are you in the mood for?";

    _answerLabel = [UILabel new];
    [_answerLabel withFont:[UIFont fontWithName: kFontLatoRegular size:kGeomFontSizeH1] textColor:kColorTextReverse backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
    _answerLabel.text = @"Oomami can help you answer that.";
    
    _answerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_answerButton withText:@"Show me." fontSize:kGeomFontSizeH3 width:100 height:kGeomHeightButton backgroundColor:kColorClear textColor:kColorTextReverse borderColor:kColorTextReverse target:self selector:@selector(showIntro)];
    _answerButton.titleLabel.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH1];
    _answerButton.layer.cornerRadius = kGeomCornerRadius;


    UIView *bMainView = [UIView new];
    UIView *mainView = [UIView new];
    [mainView addSubview:_logoLabel];
    [mainView addSubview:_questionLabel];
    [mainView addSubview:_answerLabel];
    [mainView addSubview:_answerButton];
    [mainView addSubview:_aiv];
    [mainView addSubview:_info];
//    [mainView addSubview:_tryAgain];
    
    [self.view addSubview:_backgroundImageView];
    [self.view addSubview:_overlay];
    [self.view addSubview:_signupButton];
    [self.view addSubview:_loginButton];
    [_signupButton addSubview:_verticalLine];
    
//    _tryAgain.hidden = YES;
    
    CGFloat paralaxWidth = self.view.frame.size.width*kParalaxFactor;
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width+paralaxWidth, self.view.frame.size.height - kGeomHeightButton);

    IntroScreenView *bIntro1 = [[IntroScreenView alloc] initWithFrame:frame];
    IntroScreenView *bIntro2 = [[IntroScreenView alloc] initWithFrame:frame];
    IntroScreenView *bIntro3 = [[IntroScreenView alloc] initWithFrame:frame];
    IntroScreenView *bIntro4 = [[IntroScreenView alloc] initWithFrame:frame];
    _introScreenBackgroundViews = [NSArray arrayWithObjects:bMainView, bIntro4, bIntro3, bIntro2, bIntro1, nil];
    //[DebugUtilities addBorderToViews:_introScreenBackgroundViews];
    for (UIView *v in _introScreenBackgroundViews) {
        [_introScreensScrollView addSubview:v];
    }
    
    bIntro1.introTitle = @"Food Feed.";
    bIntro1.introDescription = @"Oomami reveals the best dishes and drinks shared by your food network. The food feed is your local menu on steroids.";
    bIntro1.underlinedWords = @[@"shared"];
    
    bIntro2.introTitle = @"Search.";
    bIntro2.introDescription = @"Search by location, cuisine or name for the best spots. Oomami tells you what is popular in your food network.";
    bIntro2.underlinedWords = @[@"your food network"];
    
    bIntro3.introTitle = @"Connect.";
    bIntro3.introDescription = @"Invite your friends and follow foodies around the world. Create your personalized food network!";
    bIntro3.underlinedWords = @[@"follow foodies"];
    
    bIntro4.introTitle = @"You.";
    bIntro4.introDescription = @"Never forget your foodie finds by uploading photos and creating lists of your experiences. Your little black book is just a few taps away.";
    bIntro4.underlinedWords = @[@"photos", @"lists"];
    
    frame = self.view.frame;
    frame.size.height = frame.size.height - kGeomHeightButton;
    
    IntroScreenView *intro1 = [[IntroScreenView alloc] initWithFrame:frame];
    IntroScreenView *intro2 = [[IntroScreenView alloc] initWithFrame:frame];
    IntroScreenView *intro3 = [[IntroScreenView alloc] initWithFrame:frame];
    IntroScreenView *intro4 = [[IntroScreenView alloc] initWithFrame:frame];
    _introScreenViews = [NSArray arrayWithObjects:mainView, intro4, intro3, intro2, intro1, nil];
    for (UIView *v in _introScreenViews) {
        [_activeScrollView addSubview:v];
    }
    
    intro1.phoneImageURL = IS_IPAD ? @"S1ipad.png":@"S1.png";
    intro2.phoneImageURL = IS_IPAD ? @"S2ipad.png":@"S2.png";
    intro3.phoneImageURL = IS_IPAD ? @"S3ipad.png":@"S3.png";
    intro4.phoneImageURL = IS_IPAD ? @"S4ipad.png":@"S4.png";
 
    [self.view addSubview:_introScreensScrollView];
    [self.view addSubview:_activeScrollView];
    
    _activeScrollView.pagingEnabled = YES;
    
    _pageControl = [UIPageControl new];
    _pageControl.numberOfPages = [_introScreenViews count];
    [self.view addSubview:_pageControl];
    _pageControl.pageIndicatorTintColor = UIColorRGBA(kColorTextReverse);
    _pageControl.currentPageIndicatorTintColor = UIColorRGBA(kColorText);
    _pageControl.hidden = YES;
 
    
//    [DebugUtilities addBorderToViews:@[_activeScrollView, _introScreensScrollView]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    NSLog(@"LoginVC bounds= %@", NSStringFromCGRect(self.view.bounds));
    CGFloat h = height(self.view);
    CGFloat w = width(self.view);
    CGFloat buttonWidth = (IS_IPAD) ? kGeomWidthButtoniPadMax : w - 4*kGeomSpaceEdge;
    
    CGFloat cw = w;
    CGFloat ch = h - kGeomHeightButton;
    
    CGRect frame = self.view.bounds;
    frame.origin = CGPointMake(-kGeomMotionEffectDelta, -kGeomMotionEffectDelta);
    frame.size = CGSizeMake(frame.size.width+2*kGeomMotionEffectDelta, frame.size.height+2*kGeomMotionEffectDelta);
    _backgroundImageView.frame = frame;
    _backgroundImageView.clipsToBounds = YES;
    
    _overlay.frame = _backgroundImageView.bounds;
    
    CGFloat y = height(self.view)*0.25;
    _logoLabel.frame = CGRectMake((width(self.view) - width(_logoLabel))/2, y, width(_logoLabel), height(_logoLabel));
    
    y += height(_logoLabel);
    
    y -= 15;
    [_questionLabel sizeToFit];
    _questionLabel.frame = CGRectMake(0, y, w, _questionLabel.frame.size.height);
    
    _answerButton.frame = CGRectMake((w-buttonWidth/2)/2, ch-kGeomHeightButton - 3*kGeomSpaceEdge, buttonWidth/2, kGeomHeightButton);

    [_answerLabel sizeToFit];
    _answerLabel.frame = CGRectMake((w-width(_answerLabel))/2, CGRectGetMinY(_answerButton.frame) - kGeomSpaceEdge - height(_answerLabel), width(_answerLabel), height(_answerLabel));

    CGFloat facebookButtonHeight = facebookButtonHeight = kGeomHeightButton;
    
    _signupButton.frame = CGRectMake(0, h-kGeomHeightButton, w/2, kGeomHeightButton);
    _loginButton.frame = CGRectMake(w-w/2, h-kGeomHeightButton, w/2, kGeomHeightButton);
    
    _loginButton.layer.cornerRadius =
    _signupButton.layer.cornerRadius = 0;
    
    CGPoint center = CGPointMake(w/2, CGRectGetMinY(_answerLabel.frame) - 2*kGeomHeightButton - kGeomSpaceInter);
//    _tryAgain.frame =  CGRectMake((w-CGRectGetWidth(_tryAgain.frame))/2, CGRectGetMinY(_answerLabel.frame) - 2*kGeomHeightButton - kGeomSpaceInter, CGRectGetWidth(_tryAgain.frame), kGeomHeightButton);
    [_aiv sizeToFit];
    _aiv.center = center;
    
    _verticalLine.frame = CGRectMake(CGRectGetWidth(_signupButton.frame)-1, kGeomSpaceLineEdgeBuffer, 1, CGRectGetHeight(_signupButton.frame)-2*kGeomSpaceLineEdgeBuffer);
    
    frame = _info.frame;
    frame.size = [_info sizeThatFits:CGSizeMake(width(self.view) - 2*kGeomSpaceEdge, 100)];
    frame.size.width = width(self.view) - 2*kGeomSpaceEdge;
    frame.origin = CGPointMake(kGeomSpaceEdge, CGRectGetMidY(_aiv.frame) + kGeomHeightButton/2 + kGeomSpaceEdge);
    _info.frame = frame;
    
    frame = self.view.frame;
    CGFloat paralaxWidth = frame.size.width*kParalaxFactor;
    
    frame.size.width += paralaxWidth;
    frame.origin.x -=  paralaxWidth/2;
    frame.size.height -= kGeomHeightButton;
    _introScreensScrollView.frame = frame;
    
    _introScreensScrollView.contentSize = CGSizeMake([_introScreenViews count]*(_activeScrollView.frame.size.width+paralaxWidth),
                                                     _activeScrollView.frame.size.height);

    frame = self.view.frame;
    frame.size.height -= kGeomHeightButton;
    _activeScrollView.frame = frame;

    _activeScrollView.contentSize = CGSizeMake([_introScreenViews count]*_activeScrollView.frame.size.width, _activeScrollView.frame.size.height);

    NSUInteger i = 0;
    frame.size.width = _activeScrollView.frame.size.width;
    frame.size.height = _activeScrollView.frame.size.height;
    frame.origin.y = 0;
    
    for (UIView *v in _introScreenViews) {
        frame.origin.x = i*frame.size.width;
        v.frame = frame;
        i++;
    }
    
    i = 0;
    frame.size = _introScreensScrollView.frame.size;
    
    for (UIView *v in _introScreenBackgroundViews) {
        frame.origin.x = i*frame.size.width;
        v.frame = frame;
        i++;
    }
    
    frame = _pageControl.frame;
    
    frame.size = CGSizeMake(50, 26);
    
    if(IS_IPAD)
        frame.origin = CGPointMake((self.view.frame.size.width-frame.size.width)/2, kGeomHeightStatusBar);
    else
        frame.origin = CGPointMake((self.view.frame.size.width-frame.size.width)/2, 2*kGeomSpaceEdge);
    
    _pageControl.frame = CGRectIntegral(frame);
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
    
    NSLog (@"USERNAME %@",userInfo.username);
    
    self.navigationController.delegate = nil;
    self.transitioningDelegate = nil;
    
    if (userInfo.username.length) {
        [self performSegueWithIdentifier:@"mainUISegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"gotoCreateUsername" sender:self];
    }
    
    _signupButton.hidden = _loginButton.hidden = NO;
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

    [self startAuthFlow];
}

- (void)startAuthFlow {
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
            _info.text = @"Could not log you in";
            [_aiv stopAnimating];
            _signupButton.hidden =
            _loginButton.hidden = NO;
        }];
    } else {
        FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
        if (facebookToken) {
            [self initiateLoginFlow:facebookToken];
        } else {
            _info.hidden = NO;
            _signupButton.hidden =
            _loginButton.hidden = NO;
        }
    }
}

- (void)showIntro {
    [_activeScrollView scrollRectToVisible:CGRectMake(width(_activeScrollView), 0, width(_activeScrollView), height(_activeScrollView)) animated:YES];
    NSUInteger page = 1;
    _pageControl.currentPage = page;
    
    [UIView transitionWithView:_backgroundImageView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        _backgroundImageView.image = [self getImageForPage:page];
                    } completion:NULL];
    
    [UIView animateWithDuration:0.3 animations:^{
        _overlay.backgroundColor = UIColorRGBOverlay(((page) ? kColorBlack:kColorBlack), ((page) ? 0.55:0.45));
        _pageControl.hidden = (page) ? NO : YES;
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat percent = _introScreensScrollView.frame.size.width/_activeScrollView.frame.size.width;
    if (scrollView == _activeScrollView) {
        [_introScreensScrollView setContentOffset:CGPointMake(scrollView.contentOffset.x * percent, _introScreensScrollView.contentOffset.y)];
    }
}
    
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger page = roundf(_activeScrollView.contentOffset.x/_activeScrollView.frame.size.width);
    _pageControl.currentPage = page;
    
    [UIView transitionWithView:_backgroundImageView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        _backgroundImageView.image = [self getImageForPage:page];
                    } completion:NULL];
    
    [UIView animateWithDuration:0.3 animations:^{
        _overlay.backgroundColor = UIColorRGBOverlay(((page) ? kColorBlack:kColorBlack), ((page) ? 0.55:0.45));
        _pageControl.hidden = (page) ? NO : YES;
    }];
}

- (UIImage *)getImageForPage:(NSUInteger)page {
    switch (page) {
        case 0:
            return [UIImage imageNamed:kImageBackgroundImage];
            break;
        case 4:
            return [UIImage imageNamed:kImageBackgroundFoodFeed];
            break;
        case 3:
            return [UIImage imageNamed:kImageBackgroundSearch];
            break;
        case 2:
            return [UIImage imageNamed:kImageBackgroundConnect];
            break;
        case 1:
            return [UIImage imageNamed:kImageBackgroundProfile];
            break;
        default:
            break;
    }
    return [UIImage imageNamed:kImageBackgroundImage];
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
//    _tryAgain.hidden = YES;
    
    
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
            } else {
                _info.hidden = NO;
                _info.text = @"hmmmmm";
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"auth failure %@", error);
            [_aiv stopAnimating];
            
            if (error.code == kCFURLErrorNotConnectedToInternet) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    _tryAgain.hidden = NO;
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

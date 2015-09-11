//
//  LoginVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/17/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "LoginVC.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Common.h"
#import "DebugUtilities.h"
#import "LocationManager.h"
#import "OONetworkManager.h"

@interface LoginVC ()
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) FBSDKLoginButton *facebookLogin;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property (nonatomic, strong) UIButton *forgotPassword;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, assign) BOOL showingKeyboard;

@end

@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _backgroundImage = [[UIImageView alloc] init];
    _backgroundImage.image = [UIImage imageNamed:@"background-image.jpg"];
    _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    
    _logo = [[UIImageView alloc] init];
    _logo.contentMode = UIViewContentModeScaleAspectFit;
    _logo.backgroundColor = UIColorRGBA(kColorClear);
    _logo.image = [UIImage imageNamed:@"Logo.png"];
    
    _facebookLogin = [[FBSDKLoginButton alloc] init];
    _facebookLogin.delegate = self;
    _facebookLogin.layer.cornerRadius = kGeomCornerRadius;
    [_facebookLogin addTarget:self action:@selector(loginThroughFacebook:) forControlEvents:UIControlEventTouchUpInside];

    _username = [[UITextField alloc] init];
    _username.backgroundColor = UIColorRGBA(kColorGrayMiddle);
    _username.placeholder = @"username";
    _username.layer.cornerRadius = kGeomCornerRadius;
    _username.delegate= self;
    
    _password = [[UITextField alloc] init];
    _password.backgroundColor = UIColorRGBA(kColorGrayMiddle);
    _password.placeholder = @"password";
    _password.textColor = UIColorRGB(kColorWhite);
    _password.layer.cornerRadius = kGeomCornerRadius;
    _password.delegate = self;
    
    _forgotPassword = [[UIButton alloc] init];
    [_forgotPassword withText:@"Forgot your password?" fontSize:9 width:40 height:10 backgroundColor:kColorClear target:self selector:@selector(showMainUI)];
    
    _forgotPassword.translatesAutoresizingMaskIntoConstraints = NO;
    _username.translatesAutoresizingMaskIntoConstraints = NO;
    _password.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    _facebookLogin.translatesAutoresizingMaskIntoConstraints = NO;
    _logo.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_backgroundImage];
    [self.view addSubview:_logo];
    [self.view addSubview:_facebookLogin];
    [self.view addSubview:_username];
    [self.view addSubview:_password];
    [self.view addSubview:_forgotPassword];
    [self layout];
    
    [[LocationManager sharedInstance] askUserWhetherToTrack ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoginDidTranspire) name:@"facebookLoginDidTranspire" object:nil ];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)facebookLoginDidTranspire
{
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (token) {
        // Instantaneous transition if the user  really logged in.
        [self showMainUI];
    } else {
        NSLog (@"Was not able to get token, will try again in one second.");
        [self performSelector:@selector(facebookLoginDidTranspire2) withObject:nil afterDelay:1];
    }
}
- (void)facebookLoginDidTranspire2
{
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (token) {
        // Instantaneous transition if the user  really logged in.
        [self showMainUI];
    } else {
        NSLog (@"Really unable to get token.");
    }
}

- (void)layout
{
    // Create the views and metrics dictionaries
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _forgotPassword, _logo, _username, _password, _facebookLogin, _backgroundImage);

    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(75)-[_logo(100)]-(>=20)-[_facebookLogin(height)]-(>=60)-[_username(height)]-spaceInter-[_password(height)]-(>=20)-[_forgotPassword]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    // Horizontal layout - we only need one "column" of information because of the alignment options used when creating the horizontal layout

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_logo(<=275)]-(>=20)-|" options:0 metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_facebookLogin(width)]-(>=20)-|" options:0 metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_username(_facebookLogin)]-(>=20)-|" options:0 metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_password(_facebookLogin)]-(>=20)-|" options:0 metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_forgotPassword]-(>=20)-|" options:0 metrics:metrics views:views]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_logo
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_logo.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_facebookLogin
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_facebookLogin.superview
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.f constant:0.f]];

    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_username
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_username.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_password
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_password.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_forgotPassword
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_forgotPassword.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    [self performSelector:@selector(adjustInputFields) withObject:nil afterDelay:4];
}

- (void)adjustInputFields
{
//    [self.view layoutIfNeeded];
//    [self adjustInputField];
}

- (void)adjustInputField
{
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _forgotPassword, _logo, _username, _password, _facebookLogin, _backgroundImage);

    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[_logo(100)]-(>=20)-[_facebookLogin(height)]-spaceInter-[_username(height)]-spaceInter-[_password(height)]-(>=200)-[_forgotPassword]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)showMainUI
{
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (!token) {
        // RULE: Currently Facebook access is required.
        return;
    }
    
    NSSet * permissions= [ token permissions ];
    NSLog  (@"USER PERMISSIONS=  %@", permissions );
    
    //---------------------------------------------------
    // RULE: If we have valid user information already
    // that means the user logged in via OO but not FB,
    // so we must update the backend to add the FB
    // user ID.
    //
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSString *email= nil;
    if  (userInfo.gender.length > 1 && userInfo.userID.length == 0) {
        message( @"user has OO account already but this is their first Facebook login.");
        email= userInfo.email;
    }
    
    //---------------------------------------------------
    // RULE: Find out if back end knows this user already.
    //
    NSString*  identifier = token.userID;
    NSString* requestString;
//    identifier=  @"abcdef";
    if  (! [identifier containsString: @":" ]) {
        requestString= [NSString stringWithFormat:  @"https://%@/users?facebook_id=%@&email=%@", kOOURL, identifier, email ?: @""];
    } else {
        requestString= [NSString stringWithFormat:  @"https://%@/users?email=%@", kOOURL, identifier];
    }
    
    __weak LoginVC *weakSelf= self;
    [[OONetworkManager sharedRequestManager] GET:requestString
                                      parameters:nil
                                         success:^void(id   result) {
                                             NSLog  (@"PRE-EXISTING OO USER %@, %@",  identifier , result);
                                             [weakSelf letBackendKnowThatPreExistingUserLoggedIntoFacebook:identifier ];
                                         }
                                         failure:^void(NSError *   error) {
                                             NSLog  (@"AS YET UNKNOWN OO USER  %@, %@",  identifier, error.localizedDescription);
                                             [weakSelf fetchDetailsAboutNewUser:identifier ];
                                         }];

    // RULE:  While the above is happening take the user to the Discover page regardless of whether the backend was reached.
    [self performSegueWithIdentifier:@"mainUISegue" sender:self];
}

- (void)fetchDetailsAboutNewUser: (NSString*)identifier
{
    if  (!identifier) {
        return;
    }
    
    NSString* first=nil;
    NSString* last= nil;
    NSString* name= nil;
    NSString* gender= nil;

    //---------------------------------------------
    //  Make a formal request for user information.
    //
    __weak LoginVC *weakSelf= self;
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/v2.4/%@?fields=name,gender", identifier] //picture?type=large&redirect=false
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection,
                                           id result,
                                           NSError *error)
     {
        if (!error) {
            NSLog(@"result: %@",result);
            
            NSString* nameFromGetRequest=nil;
            NSString* genderFromGetRequest=nil;
            if ([result isKindOfClass: [NSDictionary  class] ] ) {
                nameFromGetRequest= ((NSDictionary*)result) [ @"name"];
                genderFromGetRequest= ((NSDictionary*)result) [ @"gender"];
            }
            
            // NOTE  if the Facebook server gave us the username then use it.
            [weakSelf conveyUserInformationToOurServer: identifier
                                                  name:nameFromGetRequest ?:  name
                                                gender: genderFromGetRequest ?: gender];
            
            UserObject* userInfo= [Settings sharedInstance].userObject;
            userInfo.userID= identifier;
            userInfo.gender=  genderFromGetRequest ?: gender;
        } else {
            NSLog (@"ERROR DOING FACEBOOK REQUEST:  %@", error);
            
            // NOTE: If we reach this point,  the backend does not yet know about this user.
        }
    }
     ];     // startWithCompletionHandler
    
}

- (void) letBackendKnowThatPreExistingUserLoggedIntoFacebook: (NSString*)identifier
{
//    [self fetchDetailsAboutNewUser: identifier]; return;
    
    NSString* requestString=[NSString stringWithFormat: @"https://%@/users?facebook_id=%@",
                             kOOURL,
                             identifier
                             ];
    
    requestString= [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    [[OONetworkManager sharedRequestManager] PUT: requestString
                                      parameters:nil
                                         success:^void(AFHTTPRequestOperation * operation, id   result) {
                                             NSLog  (@"DID PUT");
                                         }
                                         failure:^  void(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog (@"PUT FAILED %@",error);
                                         }
     ];
    
}

- (void) conveyUserInformationToOurServer: (NSString*)identifier
                                     name:(NSString*)name
                                   gender: (NSString*)gender;
{
    NSString* requestString=[NSString stringWithFormat: @"https://%@/users?facebook_id=%@&name=%@",
                             kOOURL,
                             identifier,
                             name ?:  @"unknown"];
    
    requestString= [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];

    [[OONetworkManager sharedRequestManager] POST: requestString
                                       parameters:nil
                                          success:^void(AFHTTPRequestOperation * operation, id   result) {
                                              NSLog  (@"DID POST");
                                          }
                                          failure:^  void(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog (@"POST FAILED %@",error);
                                          }     ];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super viewDidDisappear:animated ];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [DebugUtilities addBorderToViews:@[self.view, _backgroundImage, _logo, _facebookLogin, _username, _password]];
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (token) {
        // Instantaneous transition if the user recently logged in.
        [self showMainUI];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
        }
    }
     
     - (void)keyboardHidden: (id) foobar
    {
        self.showingKeyboard= NO;
    }
     
     - (void)keyboardShown: (id) foobar
    {
        self.showingKeyboard= YES;
    }
     
     - (void)loginThroughFacebook:(id)sender
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                // Automatic login was not possible,  so transferring to Facebook website or app...
                
                NSLog (@"Unable to log you in immediately: %@",error.localizedDescription);
            }
            else if (result.isCancelled) {
                // Handle cancellations
            }
            else {
                // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            
            if ([result.grantedPermissions containsObject:@"email"]) {
                // Do work
                [self showMainUI];
            }
        }
    }];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog (@"loginButtonDidLogOut");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == _password) {
        [theTextField resignFirstResponder];
    } else if (theTextField == _username) {
        theTextField.returnKeyType = UIReturnKeyGo;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=email" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             //profile photo link
             //10152388406186153/picture?type=large
             //fields
             //me?fields=first_name,age_range,last_name,id,gender,email

             NSLog(@"fetched user:%@", result);
         }
     }];

}

@end

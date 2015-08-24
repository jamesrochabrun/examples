//
//  LoginVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/17/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "LoginVC.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "DebugUtilities.h"

@interface LoginVC ()
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) FBSDKLoginButton *facebookLogin;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property (nonatomic, strong) UIButton *forgotPassword;
@property (nonatomic, strong) UIImageView *logo;
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_facebookLogin addTarget:self action:@selector(loginThroughFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    _backgroundImage = [[UIImageView alloc] init];
    _backgroundImage.image = [UIImage imageNamed:@"background-image.jpg"];
    _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    
    
    _logo = [[UIImageView alloc] init];
    _logo.contentMode = UIViewContentModeScaleAspectFill;
    _logo.backgroundColor = UIColorRGBA(0x33333333);
    _logo.image = [UIImage imageNamed:@"Logo_idea1.png"];
    
    _facebookLogin = [[FBSDKLoginButton alloc] init];
    _facebookLogin.delegate = self;
    _facebookLogin.layer.cornerRadius = kGeomCornerRadius;
    
    _username = [[UITextField alloc] init];
    _username.backgroundColor = UIColorRGBA(kColorGrayMiddle);
    _username.placeholder = @"username";
    _username.layer.cornerRadius = kGeomCornerRadius;
    
    _password = [[UITextField alloc] init];
    _password.backgroundColor = UIColorRGBA(kColorGrayMiddle);
    _password.placeholder = @"password";
    _password.textColor = UIColorRGB(kColorWhite);
    _password.layer.cornerRadius = kGeomCornerRadius;
    _password.delegate = self;
    
    _forgotPassword = [[UIButton alloc] init];
    [_forgotPassword withText:@"Forgot your password?" fontSize:9 width:40 height:10 backgroundColor:kColorClear target:nil selector:nil];
    
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
}

- (void)layout {
    // Create the views and metrics dictionaries
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _forgotPassword, _logo, _username, _password, _facebookLogin, _backgroundImage);

    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[_logo(100)]-(>=20)-[_facebookLogin(height)]-(>=60)-[_username(height)]-spaceInter-[_password(height)]-(>=20)-[_forgotPassword]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    // Horizontal layout - we only need one "column" of information because of the alignment options used when creating the horizontal layout

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_logo(<=200)]-(>=20)-|" options:0 metrics:metrics views:views]];

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

- (void)adjustInputFields {
//    [self.view layoutIfNeeded];
//    [self adjustInputField];
}

- (void)adjustInputField {
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _forgotPassword, _logo, _username, _password, _facebookLogin, _backgroundImage);

    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[_logo(100)]-(>=20)-[_facebookLogin(height)]-spaceInter-[_username(height)]-spaceInter-[_password(height)]-(>=200)-[_forgotPassword]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (token) {
        self.view.alpha = 1;

//        [self performSegueWithIdentifier:@"mainUISegue" sender:self];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"frames: self=%@", NSStringFromCGRect(self.view.frame));
    NSLog(@"frames: IV=%@", NSStringFromCGRect(_backgroundImage.frame));
    NSLog(@"frames: LG=%@", NSStringFromCGRect(_logo.frame));
    NSLog(@"frames: FB=%@", NSStringFromCGRect(_facebookLogin.frame));
    NSLog(@"frames: UN=%@", NSStringFromCGRect(_username.frame));
    NSLog(@"frames: PW=%@", NSStringFromCGRect(_password.frame));
//    [DebugUtilities addBorderToViews:@[self.view, _backgroundImage, _logo, _facebookLogin, _username, _password]];
}

- (void)loginThroughFacebook:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Process error
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if ([result.grantedPermissions containsObject:@"email"]) {
                // Do work
            }
        }
    }];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
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

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
    [self performSegueWithIdentifier:@"mainUISegue" sender:self];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=email" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             
             FBSDKProfile *fbProfile = [FBSDKProfile currentProfile];
             NSLog(@"fetched user:%@", result);
         }
     }];

}

@end

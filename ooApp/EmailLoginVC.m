//
//  EmailLoginVC.m
//  ooApp
//
//  Created by Anuj Gujar on 3/23/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "EmailLoginVC.h"
#import "UIImageEffects.h"
#import "OOAPI.h"
#import "OOErrorObject.h"

@interface EmailLoginVC ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, strong) UILabel *backendResultMessage;
@property (nonatomic, strong) UIView *hLine1;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;
@property (nonatomic, strong) UILabel *info;
@end

@implementation EmailLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _overlay = [[UIView alloc] init];
    _overlay.backgroundColor = UIColorRGBOverlay(kColorBlack, 0.25);
    
    _aiv = [UIActivityIndicatorView new];
    _aiv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    _info = [[UILabel alloc] init];
    [_info withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorTextReverse backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
    _info.hidden = YES;
    
    UIImage *backgroundImage = [UIImageEffects imageByApplyingBlurToImage:[UIImage imageNamed:@"background_image.png"] withRadius:30 tintColor: UIColorRGBOverlay(kColorBlack, 0) saturationDeltaFactor:1 maskImage:nil];
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _hLine1 = [[UIView alloc] init];
    _hLine1.backgroundColor = UIColorRGBA(kColorBordersAndLines);
    
    _backgroundImageView = makeImageView(self.view, backgroundImage);
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.opaque = NO;

    _emailTextField = [[UITextField alloc] init];
    _emailTextField.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _emailTextField.placeholder = @"Email";
    _emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailTextField.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _emailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kGeomSpaceEdge, 5)];
    _emailTextField.leftViewMode = UITextFieldViewModeAlways;
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailTextField.delegate = self;
    _emailTextField.returnKeyType = UIReturnKeyNext;
    
    _passwordTextField = [[UITextField alloc] init];
    _passwordTextField.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _passwordTextField.placeholder = @"Password";
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordTextField.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kGeomSpaceEdge, 5)];
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    _passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
    _passwordTextField.delegate = self;
    _passwordTextField.returnKeyType = UIReturnKeyGo;
    
    _backendResultMessage = [[UILabel alloc] init];
    [_backendResultMessage withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorNavBarText backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
    _backendResultMessage.textAlignment = NSTextAlignmentCenter;
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton withIcon:kFontIconBack fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:kGeomDimensionsIconButton backgroundColor:kColorClear target:self selector:@selector(goBack)];
    [_backButton setTitleColor:UIColorRGBA(kColorNavBarText) forState:UIControlStateNormal];

    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginButton withText:@"Log In" fontSize:kGeomFontSizeH2 width:0 height:0 backgroundColor:kColorTextActive target:self selector:@selector(logIn)];
    [_loginButton setTitleColor:UIColorRGBA(kColorTextReverse) forState:UIControlStateNormal];
    
    _forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forgotPasswordButton withText:@"" fontSize:kGeomFontSizeH3 width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(resetPassword)];
    
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:@"Forgot your password?"
                                                            attributes: @{
                                                                          NSUnderlineStyleAttributeName:
                                                                              @(NSUnderlineStyleSingle),
                                                                          NSFontAttributeName:
                                                                              [UIFont fontWithName: kFontLatoRegular size:kGeomFontSizeH3],
                                                                          NSForegroundColorAttributeName : UIColorRGBA(kColorNavBarText)
                                                                          }];

    [_forgotPasswordButton setAttributedTitle:as forState:UIControlStateNormal];
    [_forgotPasswordButton sizeToFit];
    
    _passwordTextField.delegate =
    _emailTextField.delegate = self;
    
    [self.view addSubview:_backgroundImageView];
    [self.view addSubview:_overlay];
    [self.view addSubview:_emailTextField];
    [self.view addSubview:_passwordTextField];
    [self.view addSubview:_backButton];
    [self.view addSubview:_loginButton];
    [self.view addSubview:_forgotPasswordButton];
    [self.view addSubview:_backendResultMessage];
    [self.view addSubview:_aiv];
    [self.view addSubview:_info];
    [_emailTextField addSubview:_hLine1];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat w = width(self.view);
    CGFloat buttonWidth = (IS_IPAD) ? kGeomWidthButtoniPadMax : w - 4*kGeomSpaceEdge;
    
    _backButton.frame = CGRectMake(kGeomSpaceEdge, kGeomHeightStatusBar, kGeomDimensionsIconButton, kGeomDimensionsIconButton);

    _backgroundImageView.frame = _overlay.frame = self.view.bounds;
    
    CGFloat y = kGeomHeightNavBarStatusBar;
    y += kGeomSpaceEdge;
    
    _emailTextField.frame =  CGRectMake((w-buttonWidth)/2, y, buttonWidth, kGeomHeightTextField);
    _passwordTextField.frame =  CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_emailTextField.frame), buttonWidth, kGeomHeightTextField);
    _hLine1.frame = CGRectMake(kGeomSpaceLineEdgeBuffer, CGRectGetHeight(_emailTextField.frame)-1, CGRectGetWidth(_emailTextField.frame)-2*kGeomSpaceLineEdgeBuffer, 1);
    
    CGRect frame;
    frame.size = [_backendResultMessage sizeThatFits:CGSizeMake(buttonWidth, 200)];
    frame.origin = CGPointMake((w-frame.size.width)/2, CGRectGetMaxY(_passwordTextField.frame) + 2*kGeomSpaceEdge);
    _backendResultMessage.frame = frame;

    _loginButton.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_backendResultMessage.frame) + 2*kGeomSpaceEdge, buttonWidth, kGeomHeightButton);
    
    _forgotPasswordButton.frame = CGRectMake((w-CGRectGetWidth(_forgotPasswordButton.frame))/2, CGRectGetMaxY(_loginButton.frame) + 2*kGeomSpaceEdge, CGRectGetWidth(_forgotPasswordButton.frame), kGeomHeightButton);
    
    [_aiv sizeToFit];
    _aiv.center = self.view.center;
    [_info sizeToFit];
    _info.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_aiv.frame), buttonWidth, CGRectGetHeight(_info.frame));
}

- (void)logIn {
    if (![self validateForm]) return;
    
    [_aiv startAnimating];
    _info.text = kLoggingYouIn;
    _info.hidden = NO;
    _loginButton.enabled = NO;
    
    [OOAPI authWithEmail:_emailTextField.text password:_passwordTextField.text success:^(UserObject *user, NSString *token) {
        user.backendAuthorizationToken = token;
        [[Settings sharedInstance] setUserObject:user];
        [[Settings sharedInstance] save];
        dispatch_async(dispatch_get_main_queue(), ^{
            _loginButton.enabled = YES;
            _info.hidden = YES;
            [_aiv stopAnimating];
            [self showMainUI];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == kCFURLErrorNotConnectedToInternet) {
            _backendResultMessage.text = @"It looks like you are not connected to the internet. Make sure you've got a good connection then try again.";
        } else {
            OOErrorObject *ooError = [OOErrorObject errorFromDict:[operation.responseObject objectForKey:kKeyError]];
            if (ooError.type == kOOErrorCodeTypeAuthorizationFailed) {
                _backendResultMessage.text = @"The username and password combination is not valid.";
            } else {
                _backendResultMessage.text = @"The username and password combination is not valid.";
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _loginButton.enabled = YES;
            _info.hidden = YES;
            [_aiv stopAnimating];
            [self.view setNeedsLayout];
        });
    }];
}

- (void)showMainUI {
    UserObject *user = [Settings sharedInstance].userObject;
    self.navigationController.delegate = nil;
    self.transitioningDelegate = nil;
    if (user.username.length) {
        [self performSegueWithIdentifier:@"mainUISegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"gotoCreateUsername" sender:self];
    }
}

- (void)resetPassword {
    NSString *email = _emailTextField.text;
    [self validateForm];
    if ([Common validateEmailWithString:email]) {
        [OOAPI resetPasswordWithEmail:_emailTextField.text success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                _backendResultMessage.text = @"A password reset link was sent to your email.";
                [self.view setNeedsLayout];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _backendResultMessage.text = @"Could not send a reset password email.";
                [self.view setNeedsLayout];
            });
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self validateForm];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailTextField) {
        [_passwordTextField becomeFirstResponder];
    } else {
        [_passwordTextField resignFirstResponder];
    }
    return YES;
}

- (BOOL)validateForm {
    BOOL result = YES;
    _backendResultMessage.text = @"";
    
    if (![Common validateEmailWithString:trimString(_emailTextField.text)]) {
        _backendResultMessage.text = @"The email address does not appear to be valid.";
        result = NO;
    } else if (![Common validatePasswordWithString:trimString(_passwordTextField.text)]) {
        _backendResultMessage.text = @"The password must be at least 6 characters.";
        result = NO;
    }
    
    [self.view setNeedsLayout];
    
    return result;
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

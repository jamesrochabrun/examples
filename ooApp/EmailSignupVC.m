//
//  EmailSignupVC.m
//  ooApp
//
//  Created by Anuj Gujar on 3/23/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "EmailSignupVC.h"
#import "UIImageEffects.h"
#import "OOErrorObject.h"
#import "OOAPI.h"

@interface EmailSignupVC ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *firstnameTextField;
@property (nonatomic, strong) UITextField *lastnameTextField;
@property (nonatomic, strong) UIButton *signupButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *errorMessage;
@property (nonatomic, strong) UIView *hLine1, *hLine2, *hLine3;
@end

@implementation EmailSignupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _overlay = [[UIView alloc] init];
    _overlay.backgroundColor = UIColorRGBOverlay(kColorBlack, 0.25);
    
    
    UIImage *backgroundImage = [UIImageEffects imageByApplyingBlurToImage:[UIImage imageNamed:@"background_image.png"] withRadius:30 tintColor: UIColorRGBOverlay(kColorBlack, 0) saturationDeltaFactor:1 maskImage:nil];
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _backgroundImageView = makeImageView(self.view, backgroundImage);
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.opaque = NO;
    
    _hLine1 = [[UIView alloc] init];
    _hLine2 = [[UIView alloc] init];
    _hLine3 = [[UIView alloc] init];
    _hLine1.backgroundColor =
    _hLine2.backgroundColor =
    _hLine3.backgroundColor = UIColorRGBA(kColorBordersAndLines);

    _emailTextField = [[UITextField alloc] init];
    _emailTextField.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _emailTextField.placeholder = @"Email";
    _emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailTextField.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _emailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kGeomSpaceEdge, 5)];
    _emailTextField.leftViewMode = UITextFieldViewModeAlways;
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    _passwordTextField = [[UITextField alloc] init];
    _passwordTextField.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _passwordTextField.placeholder = @"Password";
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordTextField.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kGeomSpaceEdge, 5)];
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    _firstnameTextField = [[UITextField alloc] init];
    _firstnameTextField.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _firstnameTextField.placeholder = @"Firstname";
    _firstnameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _firstnameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _firstnameTextField.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _firstnameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kGeomSpaceEdge, 5)];
    _firstnameTextField.leftViewMode = UITextFieldViewModeAlways;
    _firstnameTextField.keyboardType = UIKeyboardTypeAlphabet;
    
    _lastnameTextField = [[UITextField alloc] init];
    _lastnameTextField.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _lastnameTextField.placeholder = @"Lastname";
    _lastnameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _lastnameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _lastnameTextField.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _lastnameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kGeomSpaceEdge, 5)];
    _lastnameTextField.leftViewMode = UITextFieldViewModeAlways;
    _lastnameTextField.keyboardType = UIKeyboardTypeAlphabet;
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton withIcon:kFontIconBack fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:kGeomDimensionsIconButton backgroundColor:kColorClear target:self selector:@selector(goBack)];
    [_backButton setTitleColor:UIColorRGBA(kColorNavBarText) forState:UIControlStateNormal];
    
    _signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_signupButton withText:@"Sign Up" fontSize:kGeomFontSizeH2 width:0 height:0 backgroundColor:kColorTextActive target:self selector:@selector(signUp)];
    [_signupButton setTitleColor:UIColorRGBA(kColorTextReverse) forState:UIControlStateNormal];
    
    _errorMessage = [[UILabel alloc] init];
    [_errorMessage withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorNavBarText backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
    _errorMessage.textAlignment = NSTextAlignmentCenter;
    
    _firstnameTextField.delegate =
    _lastnameTextField.delegate =
    _passwordTextField.delegate =
    _emailTextField.delegate = self;
    
    [self.view addSubview:_backgroundImageView];
    [self.view addSubview:_overlay];
    [self.view addSubview:_emailTextField];
    [self.view addSubview:_passwordTextField];
    [self.view addSubview:_firstnameTextField];
    [self.view addSubview:_lastnameTextField];
    [self.view addSubview:_backButton];
    [self.view addSubview:_signupButton];
    [self.view addSubview:_errorMessage];
    [_emailTextField addSubview:_hLine1];
    [_passwordTextField addSubview:_hLine2];
    [_firstnameTextField addSubview:_hLine3];
}

- (void)signUp {
    if (![self validateForm]) return;
    [OOAPI createUserWithEmail:_emailTextField.text
                   andPassword:_passwordTextField.text
                  andFirstName:_firstnameTextField.text
                   andLastName:_lastnameTextField.text
                       success:^(UserObject *user, NSString *token) {
                           user.backendAuthorizationToken = token;
                           [Settings sharedInstance].userObject = user;
                           [[Settings sharedInstance] save];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [self showMainUI];
                           });
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           if (error.code == kCFURLErrorNotConnectedToInternet) {
                               _errorMessage.text = @"It looks like you are not connected to the internet. Make sure you've got a good connection then try again.";
                           } else {
                               OOErrorObject *ooError = [OOErrorObject errorFromDict:[operation.responseObject objectForKey:kKeyError]];
                               if (ooError.type == kOOErrorCodeTypeUniqueConstraint) {
                                   _errorMessage.text = @"That email is already associated with an account.";
                               } else if (ooError.type == kOOErrorCodeTypeInvalidPassword) {
                                   _errorMessage.text = @"The password must be at least 6 characters.";
                               } else if (ooError.type == kOOErrorCodeTypeInvalidEmail) {
                                   _errorMessage.text = @"The email address does not appear to be valid.";
                               } else if (ooError.type == kOOErrorCodeTypeMissingInformation) {
                                   _errorMessage.text = @"All of the fields are required.";
                               } else {
                                   _errorMessage.text = @"Could not create the account.";
                               }
                           }
                           [self.view setNeedsLayout];
                   }];
}

- (BOOL)validateForm {
    BOOL result = YES;
    _errorMessage.text = @"";
    
    if (![Common validateEmailWithString:trimString(_emailTextField.text)]) {
        _errorMessage.text = @"The email address does not appear to be valid.";
        result = NO;
    } else if (![Common validatePasswordWithString:trimString(_passwordTextField.text)]) {
        _errorMessage.text = @"The password must be at least 6 characters.";
        result = NO;
    } else if (![trimString(_firstnameTextField.text) length]) {
        _errorMessage.text = @"Please tell us your first name.";
        result = NO;
    } else if (![trimString(_lastnameTextField.text) length]) {
        _errorMessage.text = @"Please tell us your last name.";
        result = NO;
    }

    [_errorMessage setNeedsLayout];
    [_errorMessage setNeedsDisplay];
    
    return result;
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
    _firstnameTextField.frame =  CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_passwordTextField.frame), buttonWidth, kGeomHeightTextField);
    _lastnameTextField.frame =  CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_firstnameTextField.frame), buttonWidth, kGeomHeightTextField);
    _hLine1.frame = CGRectMake(kGeomSpaceLineEdgeBuffer, CGRectGetHeight(_emailTextField.frame)-1, CGRectGetWidth(_emailTextField.frame)-2*kGeomSpaceLineEdgeBuffer, 1);
    _hLine2.frame = CGRectMake(kGeomSpaceLineEdgeBuffer, CGRectGetHeight(_passwordTextField.frame)-1, CGRectGetWidth(_passwordTextField.frame)-2*kGeomSpaceLineEdgeBuffer, 1);
    _hLine3.frame = CGRectMake(kGeomSpaceLineEdgeBuffer, CGRectGetHeight(_firstnameTextField.frame)-1, CGRectGetWidth(_firstnameTextField.frame)-2*kGeomSpaceLineEdgeBuffer, 1);

    CGRect frame;
    frame.size = [_errorMessage sizeThatFits:CGSizeMake(buttonWidth, 200)];
    frame.origin = CGPointMake((w-frame.size.width)/2, CGRectGetMaxY(_lastnameTextField.frame) + kGeomSpaceInter);
    _errorMessage.frame = frame;

    _signupButton.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_errorMessage.frame) + kGeomSpaceInter, buttonWidth, kGeomHeightButton);
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

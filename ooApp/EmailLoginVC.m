//
//  EmailLoginVC.m
//  ooApp
//
//  Created by Anuj Gujar on 3/23/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "EmailLoginVC.h"

@interface EmailLoginVC ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, strong) UIView *hLine1;
@end

@implementation EmailLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _overlay = [[UIView alloc] init];
    _overlay.backgroundColor = UIColorRGBOverlay(kColorBlack, 0.25);
    
    UIImage *backgroundImage = [UIImage imageNamed:@"background_image.png"];
    
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
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton withIcon:kFontIconBack fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:kGeomDimensionsIconButton backgroundColor:kColorClear target:self selector:@selector(goBack)];
    [_backButton setTitleColor:UIColorRGBA(kColorNavBarText) forState:UIControlStateNormal];

    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginButton withText:@"Log In" fontSize:kGeomFontSizeH2 width:0 height:0 backgroundColor:kColorButtonBackground target:self selector:@selector(logIn)];
    
    _forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forgotPasswordButton withText:@"" fontSize:kGeomFontSizeH3 width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(forgotPassword)];
    
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
    [_emailTextField addSubview:_hLine1];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat w = width(self.view);
    CGFloat h = height(self.view);
    CGFloat buttonWidth = (IS_IPAD) ? kGeomWidthButtoniPadMax : w - 2*kGeomSpaceEdge;
    
    _backButton.frame = CGRectMake(kGeomSpaceEdge, kGeomHeightStatusBar, kGeomDimensionsIconButton, kGeomDimensionsIconButton);

    _backgroundImageView.frame = _overlay.frame = self.view.bounds;
    
    CGFloat y = kGeomHeightNavBarStatusBar;
    y += kGeomSpaceEdge;
    
    _emailTextField.frame =  CGRectMake((w-buttonWidth)/2, y, buttonWidth, kGeomHeightButton);
    _passwordTextField.frame =  CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_emailTextField.frame), buttonWidth, kGeomHeightButton);
    _hLine1.frame = CGRectMake(kGeomSpaceLineEdgeBuffer, CGRectGetHeight(_emailTextField.frame)-1, CGRectGetWidth(_emailTextField.frame)-2*kGeomSpaceLineEdgeBuffer, 1);
    
    _loginButton.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_passwordTextField.frame) + 2*kGeomSpaceEdge, buttonWidth, kGeomHeightButton);
    
    _forgotPasswordButton.frame = CGRectMake((w-CGRectGetWidth(_forgotPasswordButton.frame))/2, CGRectGetMaxY(_loginButton.frame) + 2*kGeomSpaceEdge, CGRectGetWidth(_forgotPasswordButton.frame), kGeomHeightButton);
}

- (void)logIn {
    
}

- (void)forgotPassword {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
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
    
    
    return YES;
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

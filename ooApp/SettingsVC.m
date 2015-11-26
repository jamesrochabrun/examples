//
//  SettingsVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "SettingsVC.h"
#import "Settings.h"
#import "ManageTagsVC.h"

@interface SettingsVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FBSDKLoginButton *facebookButton;
@property (nonatomic, strong) UIButton *manageTags;
@end

@implementation SettingsVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _facebookButton = [[FBSDKLoginButton alloc] init];
    _facebookButton.delegate = self;
    [_scrollView addSubview:_facebookButton];
    _facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    _manageTags = [UIButton buttonWithType:UIButtonTypeCustom];
    [_manageTags withText:@"Manage Tags" fontSize:kGeomFontSizeHeader width:100 height:40 backgroundColor:kColorOffWhite target:self selector:@selector(manageTags:)];
    _manageTags.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_manageTags];
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Settings" subHeader:nil];
    self.navTitle = nto;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _facebookButton, _manageTags, _scrollView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(spaceInter)-[_facebookButton(height)]-(20)-[_manageTags(height)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_facebookButton(width)]-(>=20)-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_manageTags(width)]-(>=20)-|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_facebookButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_scrollView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_manageTags
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_scrollView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
}

- (void)manageTags:(id)sender {
    ManageTagsVC *vc = [[ManageTagsVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Facebook delegate methods

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    [[Settings sharedInstance] clearUser];
    
    [self.revealViewController performSegueWithIdentifier:@"loginUISegue" sender:self];
    //performSegueWithIdentifier:@"loginUISegue" sender:self];
//    [self performSegueWithIdentifier:@"loginUISegue" sender:self];
}

@end

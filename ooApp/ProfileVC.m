//
//  ProfileVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ProfileVC.h"

@interface ProfileVC ()

@property (nonatomic, strong) FBSDKLoginButton *facebookButton;

@end

@implementation ProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _facebookButton = [[FBSDKLoginButton alloc] init];
    _facebookButton.delegate = self;
    [self.view addSubview:_facebookButton];
    _facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.screenTitle = @"Profile";
    
    [self layout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layout
{
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _facebookButton);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(75)-[_facebookButton(height)]-(75)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_facebookButton(width)]-(>=20)-|" options:0 metrics:metrics views:views]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_facebookButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_facebookButton.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    
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

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
    
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self.revealViewController performSegueWithIdentifier:@"loginUISegue" sender:self];
    //performSegueWithIdentifier:@"loginUISegue" sender:self];
//    [self performSegueWithIdentifier:@"loginUISegue" sender:self];
}

@end

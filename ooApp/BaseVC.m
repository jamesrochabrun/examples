//
//  BaseVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "BaseVC.h"
#import "WhatsNewVC.h"
#import "NavTitleView.h"

//revealViewController.rearViewRevealWidth = 200;
//revealViewController.rearViewRevealOverdraw = 0;// Cannot drag and see beyond width 200
//revealViewController.toggleAnimationDuration = 0.2;// Faster slide animation
//revealViewController.toggleAnimationType = SWRevealToggleAnimationTypeEaseOut;// Simply ease out. No Spring animation.
//revealViewController.frontViewShadowRadius = 5; // More shadow


@interface BaseVC ()

@property (nonatomic, strong) NavTitleView *navTitleView;

@end

@implementation BaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorRGBA(kColorBlack);
    
    _leftNavButton = [[UIBarButtonItem alloc] init];
    self.navigationItem.leftBarButtonItem = _leftNavButton;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    revealViewController.delegate = self;

    if (revealViewController) {
        revealViewController.rearViewRevealWidth = kGeomSideBarRevealWidth;
        [self.leftNavButton setTitle:kFontIconMenu];
        [self.leftNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:kFontIcons size:kGeomIconSize], NSFontAttributeName,
                                           UIColorRGB(kColorYellow), NSForegroundColorAttributeName,
                                           nil] forState:UIControlStateNormal];
        [self.leftNavButton setTarget:self.revealViewController];
        [self.leftNavButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    _navTitleView = [[NavTitleView alloc] init];
    _navTitleView.frame = CGRectMake(0, 0,
                                     [UIScreen mainScreen].bounds.size.width - kGeomWidthMenuButton*2,
                                     44);
    self.navigationItem.titleView = _navTitleView;

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)]];
    [self.navigationController.navigationBar setTranslucent:YES];

    
//    [self.navigationController.navigationBar setTintColor:UIColorRGBA(kColorNavBar)];
    
//    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationBar setShadowImage:[UIImage new]];
//    [self.navigationBar setTranslucent:YES];
    
//    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];

}

- (void)setLeftNavWithIcon:(NSString *)icon target:(id)target action:(SEL)selector {
    [self.leftNavButton setTitle:icon];
    [self.leftNavButton setTarget:target];
    [self.leftNavButton setAction:selector];
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (revealController.frontViewPosition == FrontViewPositionRight) {
        UIView *lockingView = [UIView new];
        lockingView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:@selector(revealToggle:)];
        [lockingView addGestureRecognizer:tap];
        [lockingView addGestureRecognizer:revealController.panGestureRecognizer];
        [lockingView setTag:1000];
        [revealController.frontViewController.view addSubview:lockingView];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(lockingView);
        
        [revealController.frontViewController.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"|[lockingView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
        [revealController.frontViewController.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lockingView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
        [lockingView sizeToFit];
    }
    else
        [[revealController.frontViewController.view viewWithTag:1000] removeFromSuperview];
}

- (void)setNavTitle:(NavTitleObject *)navTitle
{
    _navTitle = navTitle;
    _navTitleView.navTitle = _navTitle;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

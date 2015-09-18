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
    self.view.backgroundColor = UIColorRGBA(kColorGray);

    _menu = [[UIBarButtonItem alloc] init];
    self.navigationItem.leftBarButtonItem = _menu;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        revealViewController.rearViewRevealWidth = self.view.frame.size.width - 60;
        [self.menu setTitle:kFontIconMenu];
        [self.menu setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:kFontIcons size:kGeomIconSize], NSFontAttributeName,
                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                           nil] forState:UIControlStateNormal];
        [self.menu setTarget: self.revealViewController];
        [self.menu setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
    
    _navTitleView = [[NavTitleView alloc] init];
    self.navigationItem.titleView = _navTitleView;
}

- (void)layout
{

}

- (void)setNavTitle:(NavTitleObject *)navTitle {
    _navTitle = navTitle;
    _navTitleView.navTitle = _navTitle;
    _navTitleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame)-100 , 44);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
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

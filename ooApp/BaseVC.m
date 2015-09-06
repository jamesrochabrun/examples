//
//  BaseVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "BaseVC.h"
#import "DiscoverVC.h"

//revealViewController.rearViewRevealWidth = 200;
//revealViewController.rearViewRevealOverdraw = 0;// Cannot drag and see beyond width 200
//revealViewController.toggleAnimationDuration = 0.2;// Faster slide animation
//revealViewController.toggleAnimationType = SWRevealToggleAnimationTypeEaseOut;// Simply ease out. No Spring animation.
//revealViewController.frontViewShadowRadius = 5; // More shadow


@interface BaseVC ()

@property (nonatomic, strong) UILabel *titleView;
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
        [self.menu setTitle:kFontIconDiscover];
        [self.menu setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:kFontIcons size:kGeomIconSize], NSFontAttributeName,
                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                           nil] forState:UIControlStateNormal];
        [self.menu setTarget: self.revealViewController];
        [self.menu setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
    
    _titleView = [[UILabel alloc] init];
//    _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [_titleView withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear];
    self.navigationItem.titleView = _titleView;
}

- (void)layout
{
//    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
//    
//    NSDictionary *views = NSDictionaryOfVariableBindings(_titleView);
//    
//    // Vertical layout - note the options for aligning the top and bottom of all views
//    [self.navigationController.navigationBar.titleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=10-[_titleView]->=10-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    
//    [self.navigationItem.titleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=10-[_titleView]->=10-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    
//    [self.navigationItem.titleView addConstraint:[NSLayoutConstraint constraintWithItem:_titleView
//                                                     attribute:NSLayoutAttributeCenterX
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:_titleView.superview
//                                                     attribute:NSLayoutAttributeCenterX
//                                                    multiplier:1.f constant:0.f]];
//
//    
//    [self.navigationItem.titleView addConstraint:[NSLayoutConstraint constraintWithItem:_titleView
//                                                     attribute:NSLayoutAttributeCenterY
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:_titleView.superview
//                                                     attribute:NSLayoutAttributeCenterY
//                                                    multiplier:1.f constant:0.f]];
//
//
}

- (void)setScreenTitle:(NSString *)screenTitle {
    _screenTitle = screenTitle;
    _titleView.text = _screenTitle;
    [_titleView sizeToFit];
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

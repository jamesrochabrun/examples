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
@property (nonatomic, strong) UIButton *displayDropDownButton;
@end

@implementation BaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);

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
    _displayDropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _displayDropDownButton.frame = _navTitleView.bounds;
    [_displayDropDownButton addTarget:self action:@selector(toggleDropDown) forControlEvents:UIControlEventTouchUpInside];
    [_navTitleView addSubview:_displayDropDownButton];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)]];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    _dropDownList = [[DropDownListTVC alloc] init];
//    _dropDownList.view.frame = CGRectMake(0, 0, width(self.view), 200);
    _dropDownList.view.backgroundColor = UIColorRGBA(kColorOffWhite);
    _dropDownList.view.hidden = YES;
    
    [self.navigationController.view addSubview:_dropDownList.view];
    [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
}

- (void)toggleDropDown {
    if (_displayDropDownButton.selected) {
        [self displayDropDown:NO];
    } else {
        [self displayDropDown:YES];
    }
}


- (void)setLeftNavWithIcon:(NSString *)icon target:(id)target action:(SEL)selector {
    [self.leftNavButton setTitle:icon];
    [self.leftNavButton setTarget:target];
    [self.leftNavButton setAction:selector];
}

-(void)displayDropDown:(BOOL)showIt {
    CGRect ddlFrame = _dropDownList.view.frame;
    
    if (showIt) {
        [_displayDropDownButton setSelected:YES];
        //        [_tap addTarget:self action:@selector(closeCategoryDropdown:)];
        //        sFrame.origin.y = dFrame.size.height+SHARED_APP_DEL_iPhone.navBarAdjustment;
        ddlFrame.origin.y = 44 + 20;
        //        [_dropDownList.tableView reloadData];
        
        //        [_mainCoverView addGestureRecognizer:_tap];
        //        _mainCoverView.backgroundColor = [UIColor clearColor];
        _dropDownList.view.hidden = NO;
        [_dropDownList.tableView reloadData];
    } else {
        [_displayDropDownButton setSelected:NO];
        //        [_tap removeTarget:self action:@selector(closeCategoryDropdown:)];
        //        sFrame.origin.y = 0 + SHARED_APP_DEL_iPhone.navBarAdjustment;
        //        if (self.navigationBarHidden)
        //            sFrame.size.height = [self searchBarHeight] + SHARED_APP_DEL_iPhone.statusBarAdjustment;
        ddlFrame.origin.y = 44 + 20 -_dropDownList.view.frame.size.height;
        //        [_mainCoverView removeGestureRecognizer:_tap];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        //        _categoryButton.enabled = NO;
        //        _downArrow.transform = (showIt) ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
        _dropDownList.view.frame = ddlFrame;
    } completion:^(BOOL finished) {
        if (!showIt) {
            _dropDownList.view.hidden = YES;
            //            _mainCoverView.backgroundColor = [UIColor clearColor];
        } else {
            //            _mainCoverView.backgroundColor = [UIColor clearColor];
            //            [_categoryDropDownList.tableView flashScrollIndicators];
            //            [_categoryDropDownList scrollToCurrent];
        }
        //_categoryButton.enabled = YES;
    }];
    
    //    _categoryButton.selected = showIt;
    //    _mainCoverView.hidden = !showIt;
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
    [_navTitleView setNeedsLayout];
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

- (void)dropDownList:(DropDownListTVC *)dropDownList optionTapped:(id)object {
    NSLog(@"subclass should implement this if it wants to respond to a drop down list tap");
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

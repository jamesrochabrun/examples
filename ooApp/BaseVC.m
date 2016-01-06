//
//  BaseVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "BaseVC.h"
#import "WhatsNewVC.h"
#import "DebugUtilities.h"
#import "DropDownListTVC.h"
#import "DebugUtilities.h"

//revealViewController.rearViewRevealWidth = 200;
//revealViewController.rearViewRevealOverdraw = 0;// Cannot drag and see beyond width 200
//revealViewController.toggleAnimationDuration = 0.2;// Faster slide animation
//revealViewController.toggleAnimationType = SWRevealToggleAnimationTypeEaseOut;// Simply ease out. No Spring animation.
//revealViewController.frontViewShadowRadius = 5; // More shadow


@interface BaseVC ()
@property (nonatomic, strong) UIButton *displayDropDownButton;
@property (nonatomic, strong) UIView *mainCoverView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@end

@implementation BaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);

    _leftNavButton = [[UIBarButtonItem alloc] init];
    self.navigationItem.leftBarButtonItem = _leftNavButton;

    _rightNavButton = [[UIBarButtonItem alloc] init];
    self.navigationItem.rightBarButtonItem = _rightNavButton;
    [self.rightNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont fontWithName:kFontIcons size:kGeomIconSize], NSFontAttributeName, UIColorRGB(kColorYellow), NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
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
    
    _mainCoverView = [[UIView alloc] initWithFrame:self.view.frame];
    _mainCoverView.backgroundColor = UIColorRGBA(kColorOverlay40);
    _mainCoverView.hidden = YES;
    [self.view addSubview:_mainCoverView];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDropDownList:)];

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

- (void)setRightNavWithIcon:(NSString *)icon target:(id)target action:(SEL)selector {
    [self.rightNavButton setTitle:icon];
    [self.rightNavButton setTarget:target];
    [self.rightNavButton setAction:selector];
}

-(void)displayDropDown:(BOOL)showIt {
    if (![_dropDownList.options count]) return;
    CGRect ddlFrame = _dropDownList.view.frame;
    
    if (showIt) {
        [_displayDropDownButton setSelected:YES];
        [_tap addTarget:self action:@selector(closeDropDownList:)];
        ddlFrame.origin.y = 44 + 20;
        [_dropDownList.tableView reloadData];
        [_mainCoverView addGestureRecognizer:_tap];
        _mainCoverView.backgroundColor = UIColorRGBA(kColorClear);
        _mainCoverView.hidden = _dropDownList.view.hidden = NO;
        [self.view bringSubviewToFront:_mainCoverView];
    } else {
        [_displayDropDownButton setSelected:NO];
        [_tap removeTarget:self action:@selector(closeDropDownList:)];
        ddlFrame.origin.y = 44 + 20 -_dropDownList.view.frame.size.height;
        [_mainCoverView removeGestureRecognizer:_tap];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [_navTitleView setDDLState:!showIt];
        if (showIt) {
            _mainCoverView.backgroundColor = UIColorRGBA(kColorOverlay35);
        } else {
            _mainCoverView.backgroundColor = [UIColor clearColor];
        }
        _dropDownList.view.frame = ddlFrame;
    } completion:^(BOOL finished) {
        if (!showIt) {
            _dropDownList.view.hidden = YES;
            _mainCoverView.hidden = YES;
        } else {

        }
    }];
    
    _mainCoverView.hidden = !showIt;
}

- (void)closeDropDownList:(id)sender {
    [self displayDropDown:NO];
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (revealController.frontViewPosition == FrontViewPositionRight) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMenuWillOpen object:self];
        
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

- (void)registerForNotification:(NSString*) name calling:(SEL)selector
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector: selector
                   name: name
                 object:nil];
}

- (void)unregisterFromNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver: self  ];
}

- (void)dealloc
{
    [self unregisterFromNotifications];
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

@end

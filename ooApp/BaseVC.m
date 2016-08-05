//
//  BaseVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "BaseVC.h"
#import "WhatsNewVC.h"
#import "DropDownListTVC.h"
#import "AppDelegate.h"
#import "DebugUtilities.h"

@interface BaseVC ()
@property (nonatomic, strong) UIButton *displayDropDownButton;
@property (nonatomic, strong) UIView *mainCoverView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIView *leftBarButtonView;
@property (nonatomic, strong) UIView *rightBarButtonView;
@property (nonatomic, strong) NSMutableArray *leftBarItems;
@property (nonatomic, strong) NSMutableArray *rightBarItems;
@end

@implementation BaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _aiv = [[OOAIV alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
    _aiv.message = @"loading";
    
    CGRect frame = _aiv.frame;
    frame.origin.x = (width(self.view) - width(_aiv))/2;
    frame.origin.y = ((height(self.view) - kGeomHeightNavBarStatusBar - kGeomHeightTabBar) - height(_aiv))/2;
    _aiv.frame = frame;
    [self.view addSubview:_aiv];

    _leftBarItems = [NSMutableArray array];
    _rightBarItems = [NSMutableArray array];
    _leftBarButtonView = [UIView new];
    _rightBarButtonView = [UIView new];

    self.navigationItem.leftBarButtonItems = _leftBarItems;// @[_leftNavButton];
    
    _navTitleView = [[NavTitleView alloc] init];
    _navTitleView.frame = CGRectZero;
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
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:@{NSForegroundColorAttributeName:UIColorRGBA(kColorText),
                                NSFontAttributeName:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2]}];

    _dropDownList = [[DropDownListTVC alloc] init];
    _dropDownList.view.backgroundColor = UIColorRGBA(kColorCellBackground);
    _dropDownList.view.hidden = YES;
    
    self.uploadProgressBar = [UIProgressView new];
    self.uploadProgressBar.tintColor = UIColorRGBA(kColorTextActive);
    self.uploadProgressBar.trackTintColor = UIColorRGBA(kColorTextReverse);
    [self.view addSubview:self.uploadProgressBar];
    self.uploadProgressBar.hidden = YES;

    [self.navigationController.view addSubview:_dropDownList.view];
    [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor grayColor];
    //[DebugUtilities addBorderToViews:@[_leftBarButtonView, _rightBarButtonView, _navTitleView]];
}

- (void)toggleDropDown {
    if (_displayDropDownButton.selected) {
        [self displayDropDown:NO];
    } else {
        [self displayDropDown:YES];
    }
}

- (UIButton *)addNavButtonWithIcon:(NSString *)icon target:(id)target action:(SEL)selector forSide:(NavBarSideType)side isCTA:(BOOL)isCTA {
    //side = -1 left, 1 = right
    
    isCTA = NO;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button withText:icon fontSize:kGeomIconSize width:0 height:0 backgroundColor:kColorClear target:target selector:selector];
    [button setTitleColor:(isCTA)?UIColorRGBA(kColorTextActive):UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
    [button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [button setTitle:icon forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = kGeomWidthNavBarCTAButton/2;
    button.layer.borderColor = UIColorRGBA(kColorTextActive).CGColor;
    button.layer.borderWidth = (isCTA)?2:0;
    button.backgroundColor = isCTA?UIColorRGBA(kColorClear):UIColorRGBA(kColorClear);
    
    CGRect frame;
    UIBarButtonItem *bbi;
    
    if (side == kNavBarSideTypeLeft) {
        button.frame = CGRectMake([_leftBarItems count]*40, 0, (isCTA)?kGeomWidthNavBarButton:kGeomWidthNavBarCTAButton, (isCTA)?kGeomHeightNavBarCTAButton:kGeomHeightNavBarButton);
        [_leftBarButtonView addSubview:button];
        [_leftBarItems addObject:button];
        frame = CGRectMake(0, 0, [_leftBarItems count]*40, (isCTA)?kGeomHeightNavBarCTAButton:kGeomHeightNavBarButton);
        _leftBarButtonView.frame = frame;
        bbi = [[UIBarButtonItem alloc] initWithCustomView:_leftBarButtonView];
        self.navigationItem.leftBarButtonItem = bbi;
    } else if (side == kNavBarSideTypeRight) {
        [_rightBarButtonView addSubview:button];
        [_rightBarItems addObject:button];
        frame = CGRectMake(0, 0, [_rightBarItems count]*40, (isCTA)?kGeomHeightNavBarCTAButton:kGeomHeightNavBarButton);
        _rightBarButtonView.frame = frame;
        NSInteger i = 0;
        for (UIView *v in [_rightBarItems reverseObjectEnumerator]) {
            v.frame = CGRectMake(i*40, 0,  (isCTA)?kGeomWidthNavBarCTAButton:kGeomWidthNavBarButton, (isCTA)?kGeomHeightNavBarCTAButton:kGeomHeightNavBarButton);
            i++;
        }
        bbi = [[UIBarButtonItem alloc] initWithCustomView:_rightBarButtonView];
        self.navigationItem.rightBarButtonItem = bbi;
    }
    
    _navTitleView.frame = CGRectMake(0, 0, width(self.view) - fmaxf(2*width(_leftBarButtonView), 2*width(_rightBarButtonView)) - 50, kGeomHeightNavBar);
    
    return button;
    //[DebugUtilities addBorderToViews:@[button]];
}

- (void)removeNavButtonForSide:(NavBarSideType)side {
    if (side == kNavBarSideTypeLeft) {
        [_leftBarItems removeAllObjects];
        [[_leftBarButtonView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    } else if (side == kNavBarSideTypeRight) {
        [_rightBarItems removeAllObjects];
        [[_rightBarButtonView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
}

- (CGRect)getRightButtonFrame {
    CGRect frame;
    frame = [self.view convertRect:_rightBarButtonView.frame toView:nil];
    return frame;
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

- (void)setNavTitle:(NavTitleObject *)navTitle
{
    _navTitle = navTitle;
    _navTitleView.navTitle = _navTitle;
    [_navTitleView setNeedsLayout];
}

- (void)registerForNotification:(NSString *)name calling:(SEL)selector
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:selector
                   name:name
                 object:nil];
}

- (void)unregisterFromNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)dealloc {
    [self unregisterFromNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.tabBarController.tabBar.hidden = NO;

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.backgroundColor = UIColorRGBA(kColorOverlay40);
    
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = kGeomHeightStatusBar;
    self.navigationController.navigationBar.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropDownList:(DropDownListTVC *)dropDownList optionTapped:(id)object {
    NSLog(@"subclass should implement this if it wants to respond to a drop down list tap");
}

@end

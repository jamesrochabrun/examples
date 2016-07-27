//
//  SubBaseVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/15/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "SubBaseVC.h"
#import "NavTitleView.h"

#import "DebugUtilities.h"

@interface SubBaseVC ()

@property (nonatomic, strong) NavTitleView *navTitleView;
//@property (nonatomic, strong) UIBarButtonItem *leftNavButton;
//@property (nonatomic, strong) UIBarButtonItem *rightNavButton;
//@property (nonatomic, strong) UIButton *rightBarButtonView;
//@property (nonatomic, strong) UIButton *leftBarButtonView;
@property (nonatomic, strong) UIView *leftBarButtonView;
@property (nonatomic, strong) UIView *rightBarButtonView;
@property (nonatomic, strong) NSMutableArray *leftBarItems;
@property (nonatomic, strong) NSMutableArray *rightBarItems;

@end

@implementation SubBaseVC

- (id)init {
    self = [super init];
    if (self) {
        _navTitleView = [[NavTitleView alloc] init];

        self.navigationItem.titleView = _navTitleView;
        
        _navTitleView.frame = CGRectMake(0, 0,
                                         [UIScreen mainScreen].bounds.size.width - kGeomWidthMenuButton*2,
                                         44);
        
        _aiv = [[OOAIV alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
        _aiv.message = @"loading";

        self.navigationItem.titleView = _navTitleView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect frame = _aiv.frame;
    frame.origin.x = (width(self.view) - width(_aiv))/2;
    frame.origin.y = ((height(self.view) - kGeomHeightNavBarStatusBar - kGeomHeightTabBar) - height(_aiv))/2;
    _aiv.frame = frame;
    [self.view addSubview:_aiv];
    
//    _rightBarButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_rightBarButtonView withText:@"" fontSize:kGeomIconSize width:40 height:40 backgroundColor:kColorClear target:nil selector:nil];
//    [_rightBarButtonView setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
//    _rightBarButtonView.titleLabel.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
//    
//    _rightNavButton = [[UIBarButtonItem alloc] initWithCustomView:_rightBarButtonView];
//    self.navigationItem.rightBarButtonItem = _rightNavButton;
//
//    _leftBarButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_leftBarButtonView withText:@"" fontSize:kGeomIconSize width:40 height:40 backgroundColor:kColorClear target:nil selector:nil];
//    [_leftBarButtonView setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
//    _leftBarButtonView.titleLabel.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
//    
//    _leftNavButton = [[UIBarButtonItem alloc] initWithCustomView:_leftBarButtonView];
//    self.navigationItem.leftBarButtonItem = _leftNavButton;

    _leftBarItems = [NSMutableArray array];
    _rightBarItems = [NSMutableArray array];
    _leftBarButtonView = [UIView new];
    _rightBarButtonView = [UIView new];

    self.uploadProgressBar = [UIProgressView new];
    self.uploadProgressBar.tintColor = UIColorRGBA(kColorTextActive);
    self.uploadProgressBar.trackTintColor = UIColorRGBA(kColorTextReverse);
    [self.view addSubview:self.uploadProgressBar];
    self.uploadProgressBar.hidden = NO;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.tabBarController.tabBar.hidden = NO;
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = kGeomHeightStatusBar;
    self.navigationController.navigationBar.frame = frame;
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


- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
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

//- (void)setLeftNavWithIcon:(NSString *)icon target:(id)target action:(SEL)selector {
//    [self.leftBarButtonView setTitle:icon forState:UIControlStateNormal];
//    [self.leftBarButtonView addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (void)setRightNavWithIcon:(NSString *)icon target:(id)target action:(SEL)selector {
//    [self.rightBarButtonView setTitle:icon forState:UIControlStateNormal];
//    [self.rightBarButtonView addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
//}

- (void)setNavTitle:(NavTitleObject *)navTitle {
    _navTitle = navTitle;
    _navTitleView.navTitle = _navTitle;
}

- (void)didReceiveMemoryWarning {
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

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
@property (nonatomic, strong) UIBarButtonItem *leftNavButton;
@property (nonatomic, strong) UIBarButtonItem *rightNavButton;
@property (nonatomic, strong) UIButton *rightBarButtonView;
@property (nonatomic, strong) UIButton *leftBarButtonView;
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
        self.navigationItem.titleView = _navTitleView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _rightBarButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBarButtonView withText:@"" fontSize:kGeomIconSize width:40 height:40 backgroundColor:kColorClear target:nil selector:nil];
    [_rightBarButtonView setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
    _rightBarButtonView.titleLabel.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
    
    _rightNavButton = [[UIBarButtonItem alloc] initWithCustomView:_rightBarButtonView];
    self.navigationItem.rightBarButtonItem = _rightNavButton;

    _leftBarButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftBarButtonView withText:@"" fontSize:kGeomIconSize width:40 height:40 backgroundColor:kColorClear target:nil selector:nil];
    [_leftBarButtonView setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
    _leftBarButtonView.titleLabel.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
    
    _leftNavButton = [[UIBarButtonItem alloc] initWithCustomView:_leftBarButtonView];
    self.navigationItem.leftBarButtonItem = _leftNavButton;

    self.uploadProgressBar = [UIProgressView new];
    [self.view addSubview:self.uploadProgressBar];
    self.uploadProgressBar.hidden = YES;

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

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

- (void)setLeftNavWithIcon:(NSString *)icon target:(id)target action:(SEL)selector {
    [self.leftBarButtonView setTitle:icon forState:UIControlStateNormal];
    [self.leftBarButtonView addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setRightNavWithIcon:(NSString *)icon target:(id)target action:(SEL)selector {
    [self.rightBarButtonView setTitle:icon forState:UIControlStateNormal];
    [self.rightBarButtonView addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

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

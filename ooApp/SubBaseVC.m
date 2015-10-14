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

@end

@implementation SubBaseVC

- (id)init {
    self = [super init];
    if (self) {
        _navTitleView = [[NavTitleView alloc] init];

        self.navigationItem.titleView = _navTitleView;
        
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
        
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] init];
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moreButton.frame = CGRectMake(0, 0, kGeomWidthMenuButton, kGeomWidthMenuButton);
    [_moreButton withIcon:kFontIconMore fontSize:kGeomIconSize width:kGeomWidthMenuButton height:kGeomWidthMenuButton backgroundColor:kColorClear target:nil selector:nil];
    
    bbi.customView = _moreButton;
    self.navigationItem.rightBarButtonItems = @[bbi];
    
//    [DebugUtilities addBorderToViews:@[_moreButton, self.navTitleView]];
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

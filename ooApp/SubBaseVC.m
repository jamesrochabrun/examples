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
    
    _rightNavButton = [[UIBarButtonItem alloc] init];
    self.navigationItem.rightBarButtonItem = _rightNavButton;
    [self.rightNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont fontWithName:kFontIcons size:kGeomIconSize], NSFontAttributeName, UIColorRGB(kColorYellow), NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    _leftNavButton = [[UIBarButtonItem alloc] init];
    self.navigationItem.leftBarButtonItem = _leftNavButton;
    [self.leftNavButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont fontWithName:kFontIcons size:kGeomIconSize], NSFontAttributeName,
                                                UIColorRGB(kColorYellow), NSForegroundColorAttributeName,
                                                nil] forState:UIControlStateNormal];


    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

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

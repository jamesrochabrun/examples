//
//  SubBaseVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/15/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "SubBaseVC.h"
#import "NavTitleView.h"

@interface SubBaseVC ()

@property (nonatomic, strong) NavTitleView *navTitleView;

@end

@implementation SubBaseVC

- (id)init {
    self = [super init];
    if (self) {
        _navTitleView = [[NavTitleView alloc] init];
        self.navigationItem.titleView = _navTitleView;    
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setNavTitle:(NavTitleObject *)navTitle {
    _navTitle = navTitle;
    _navTitleView.navTitle = _navTitle;
    _navTitleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame)-100 , 44);
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

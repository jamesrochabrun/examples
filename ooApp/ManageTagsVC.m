//
//  ManageTagsVC.m
//  ooApp
//
//  Created by Anuj Gujar on 11/21/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ManageTagsVC.h"

@interface ManageTagsVC ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ManageTagsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView = [[UITableView alloc] init];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
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

//
//  ListsVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListsVC.h"
#import "ListTVCell.h"
#import "RestaurantListVC.h"
#import "OOAPI.h"
#import "LocationManager.h"
#import "UIImageView+AFNetworking.h"
#import "ListObject.h"
#import "RestaurantVC.h"

@interface ListsVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *lists;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

static NSString * const cellIdentifier = @"listCell";

@implementation ListsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [_tableView registerClass:[ListTVCell class] forCellReuseIdentifier:cellIdentifier];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.rowHeight = kGeomHeightHorizontalListRow;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.layoutMargins = UIEdgeInsetsZero;
    
    _requestOperation = nil;
    
    [self layout];
}

- (void)layout
{
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};

    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);

    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getLists
{
    OOAPI *api = [[OOAPI alloc] init];
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Lists" subHeader:nil];
    self.navTitle = nto;
    
    __weak ListsVC *weakSelf = self;
    self.requestOperation = [api getListsOfUser:0 withRestaurant:0 success:^(NSArray *lists) {
        weakSelf.lists = lists;
        ON_MAIN_THREAD( ^{
            [self gotLists];
        });
    } failure:^(NSError *error) {
        ;
    }];
}

- (void)gotLists
{
    NSLog(@"Got %tu lists.", [_lists count]);
    [_tableView reloadData];
//    [DebugUtilities addBorderToViews:@[self.collectionView] withColors:kColorNavyBlue];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListTVCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    
    if (_restaurant) {
        cell.restaurant = _restaurant;
    }
    ListObject *list = [_lists objectAtIndex:indexPath.row];
    cell.list = list;

    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListObject *list = [_lists objectAtIndex:indexPath.row];
    
    RestaurantListVC *vc = [[RestaurantListVC alloc] init];
    vc.listItem = list;
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

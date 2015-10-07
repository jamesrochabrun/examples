//
//  HorizontalListVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "HorizontalListVC.h"
#import "RestaurantHTVCell.h"
#import "RestaurantObject.h"
#import "OOAPI.h"
#import "LocationManager.h"
#import "UIImageView+AFNetworking.h"
#import "ListObject.h"
#import "RestaurantVC.h"

@interface HorizontalListVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

static NSString * const cellIdentifier = @"horizontalCell";

@implementation HorizontalListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [_tableView registerClass:[RestaurantHTVCell class] forCellReuseIdentifier:cellIdentifier];
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

- (void)setListItem:(ListObject *)listItem {
    if (_listItem == listItem) return;
    _listItem = listItem;

    if (_listItem) {
        [self getRestaurants];
    }
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:listItem.name subHeader:nil];
    self.navTitle = nto;
}

- (void)getRestaurants
{
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak HorizontalListVC *weakSelf = self;
    if (_listItem.type == kOOAPIListTypeFavorites) {
        self.requestOperation = [api getRestaurantsWithListID:[_listItem.listID integerValue] success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(NSError *err) {
            ;
        }];
    } else {
        self.requestOperation = [api getRestaurantsWithKeyword:_listItem.name
                                                   andLocation:[[LocationManager sharedInstance]currentUserLocation]
                                                   andOpenOnly:NO success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(NSError *err) {
            ;
        }];
    }
}

- (void)gotRestaurants
{
    NSLog(@"%@: %tu", _listItem.name, [_restaurants count]);
    [_tableView reloadData];

//    [DebugUtilities addBorderToViews:@[self.collectionView] withColors:kColorNavyBlue];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_restaurants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantHTVCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
    cell.restaurant = restaurant;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
    
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    vc.restaurant = restaurant;
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

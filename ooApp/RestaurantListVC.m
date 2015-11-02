//
//  RestaurantListVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantListVC.h"
#import "RestaurantTVCell.h"
#import "RestaurantObject.h"
#import "OOAPI.h"
#import "LocationManager.h"
#import "UIImageView+AFNetworking.h"
#import "ListObject.h"
#import "RestaurantVC.h"
#import "ListsVC.h"
#import "DiscoverVC.h"

@interface RestaurantListVC ()

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

static NSString * const cellIdentifier = @"horizontalCell";

@implementation RestaurantListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [_tableView registerClass:[RestaurantTVCell class] forCellReuseIdentifier:cellIdentifier];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.rowHeight = kGeomHeightHorizontalListRow;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.layoutMargins = UIEdgeInsetsZero;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _requestOperation = nil;
    
    if (_listItem.type == kListTypeUser) {
        [self setupAlertController];
    }
    
//    [self layout];
}

//- (void)layout
//{
- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};

    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);

    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)setupAlertController {
    _alertController = [UIAlertController alertControllerWithTitle:@"List Options"
                                                           message:@"What would you like to do with this list."
                                                    preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    _alertController.view.tintColor = [UIColor blackColor];

    UIAlertAction *addRestaurantsFromDiscover = [UIAlertAction actionWithTitle:@"Add Restaurants from Discover"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           [self addRestaurantsFromDiscover];
                                                                       }];

    UIAlertAction *addRestaurantsFromList = [UIAlertAction actionWithTitle:@"Add Restaurants from List"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       [self addRestaurantsFromList];
                                                                   }];

    UIAlertAction *deleteList = [UIAlertAction actionWithTitle:@"Delete List"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * action) {
                                                           [self deleteList];
                                                       }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                         NSLog(@"Cancel");
                                                     }]; // 3
    

    [_alertController addAction:addRestaurantsFromDiscover];
    [_alertController addAction:addRestaurantsFromList];
    [_alertController addAction:deleteList];
    [_alertController addAction:cancel];
    
    [self.moreButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)moreButtonPressed:(id)sender {
    [self presentViewController:_alertController animated:YES completion:nil]; // 6
}

- (void)deleteList {
    OOAPI *api = [[OOAPI alloc] init];
    [api deleteList:_listItem.listID success:^(NSArray *lists) {
        [self.navigationController popViewControllerAnimated:YES];

    } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
        ;
    }];
}

- (void)addRestaurantsFromDiscover {
    DiscoverVC *vc = [[DiscoverVC alloc] init];
    vc.listToAddTo = _listItem;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addRestaurantsFromList {
    ListsVC *vc = [[ListsVC alloc] init];
    [vc getLists];
    vc.listToAddTo = _listItem;
    [self.navigationController pushViewController:vc animated:YES];
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
    
    __weak RestaurantListVC *weakSelf = self;
    if (_listItem.type == kListTypeToTry ||
        _listItem.type == kListTypeFavorites ||
        _listItem.type == kListTypeUser) {
        self.requestOperation = [api getRestaurantsWithListID:_listItem.listID success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation* operation, NSError *err) {
            ;
        }];
    } else {
        self.requestOperation = [api getRestaurantsWithKeyword:_listItem.name
                                                   andLocation:[[LocationManager sharedInstance] currentUserLocation]
                                                     andFilter:@""
                                                   andOpenOnly:NO
                                                       andSort:kSearchSortTypeBestMatch
                                                       success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation* operation, NSError *err) {
            ;
        }];
    }
}

- (void)gotRestaurants
{
    NSLog(@"%@: %lu", _listItem.name, [_restaurants count]);
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
    RestaurantTVCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
    cell.restaurant = restaurant;
    
    [cell updateConstraintsIfNeeded];
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
        __weak RestaurantListVC *weakSelf = self;
        OOAPI *api = [[OOAPI alloc] init];
        
        [api deleteRestaurant:restaurant.restaurantID fromList:_listItem.listID success:^(NSArray *lists) {
            [api getRestaurantsWithListID:_listItem.listID success:^(NSArray *restaurants) {
                _restaurants = restaurants;
                ON_MAIN_THREAD(^{
                    [weakSelf.tableView reloadData];
                });
            } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                ;
            }];
        } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
            ;
        }];
    }
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

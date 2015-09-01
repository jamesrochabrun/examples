//
//  DiscoverVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "DiscoverVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListTVCell.h"
#import "DebugUtilities.h"

static NSUInteger kNoRowSelected = -1;

@interface DiscoverVC ()

@property (nonatomic) NSInteger selectedRow;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *lists;

@end

@implementation DiscoverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _tableView.rowHeight = kGeomHeightListRow;
    
    [_tableView registerClass:[ListTVCell class] forCellReuseIdentifier:@"listCell"];
    _selectedRow = kNoRowSelected;
    
    _lists = [NSMutableArray array];
    ListObject *list;
    list = [[ListObject alloc] init];
    list.name = @"Thai";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Burgers";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Chinese";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Noe";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Mexican";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Peruvian";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Burgers";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Chinese";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Noe";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Mexican";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Peruvian";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Burgers";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Chinese";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Noe";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Mexican";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Peruvian";
    [_lists addObject:list];
    
    [self layout];
}

-(void)layout {
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
//    [self testAPI];
    [_tableView reloadData];
}


- (void)testAPI {
    OOAPI *api = [[OOAPI alloc] init];
    
    [api getRestaurantsWithKeyword:@"thai" andLocation:CLLocationCoordinate2DMake(37.7833,-122.4167) success:^(NSArray *r) {
        _restaurants = r;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self printRestaurants];
        });
    } failure:^(NSError *err) {
        ;
    }];
    
    [api getUsersWithIDs:nil success:^(NSArray *r) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [r enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UserObject *user =  (UserObject *)obj;
                NSLog(@"id = %@ user = %@ %@ email=%@", user.userID, user.firstName, user.lastName, user.email);
            }];
        });
    } failure:^(NSError *err) {
        ;
    }];
    
    [api getDishesWithIDs:nil success:^(NSArray *r) {
        
    } failure:^(NSError *err) {
        ;
    }];
    
    RestaurantObject *restaurant = [[RestaurantObject alloc] init];
    restaurant.name = @"Papalote";
    //    [api addRestaurant:restaurant success:^(NSArray *dishes) {
    //        ;
    //    } failure:^(NSError *error) {
    //        ;
    //    }];
}

- (void)printRestaurants {
    [_restaurants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"rest name = %@",  (RestaurantObject *)obj);
    }];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma table view delegates/datasources
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    ListObject *list = (ListObject *)[_lists objectAtIndex:indexPath.row];
    cell.listItem = list;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    height = (indexPath.row == _selectedRow) ? (kGeomHeightListRow + kGeomHeightListRowReveal + 2*kGeomSpaceInter) : kGeomHeightListRow;
    
    NSLog(@"row=%zd selectedRow=%zd height=%f", indexPath.row, _selectedRow, height);
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    _selectedRow = (row == _selectedRow) ? kNoRowSelected : row;
    if (_selectedRow != kNoRowSelected) {
        [(ListTVCell *)[tableView cellForRowAtIndexPath:indexPath] getRestaurants];;
    }
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_lists count];
}

@end

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
#import "Settings.h"
#import "LocationManager.h"

@interface DiscoverVC ()

@property (nonatomic) ListObject *selectedItem;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *lists;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
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
    _selectedItem = nil;
    
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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self verifyTrackingIsOkay];
}

- (void) verifyTrackingIsOkay
{
    if (0==self.currentLocation.longitude) {
        TrackingChoice c = [[LocationManager sharedInstance] dontTrackLocation ];
        if (TRACKING_UNKNOWN == c) {
            [[LocationManager sharedInstance] askUserWhetherToTrack];
        }
        else if (TRACKING_YES == c) {
            [self updateLocation];
        }
    }
}

- (void)updateLocation
{
    self.currentLocation= [[LocationManager sharedInstance] currentUserLocation ];
}

- (void) testAPI
{
    OOAPI *api = [[OOAPI alloc] init];
    
    [self updateLocation];

    CLLocationCoordinate2D locationToUse= self.currentLocation;
   
    if (0 == locationToUse.longitude) {
        // RULE: 
        float latitude, longitude;
        //  San Francisco
        latitude=37.7833;
        longitude= -122.4167;
        locationToUse= CLLocationCoordinate2DMake(latitude, longitude);
    }
    
    [api getRestaurantsWithKeyword:@"thai" andLocation:locationToUse success:^(NSArray *r) {
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
    
//    if ([_lists objectAtIndex:indexPath.row] == _selectedItem)
    
    cell.listItem = list;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    height = (_selectedItem && ([_lists indexOfObject:_selectedItem] == indexPath.row)) ? (kGeomHeightListRow + kGeomHeightListRowReveal + 2*kGeomSpaceInter) : kGeomHeightListRow;
    
    NSLog(@"row=%@ selectedRow=%@ height=%f", ((ListObject*)[_lists objectAtIndex:indexPath.row]).name, _selectedItem.name, height);
    
    return height;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    _selectedItem = (_selectedItem && ([_lists indexOfObject:_selectedItem] == indexPath.row)) ? nil : [_lists objectAtIndex:indexPath.row];

    if (_selectedItem) {
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

//
//  DiscoverVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "DiscoverVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "RestaurantHTVCell.h"
#import "DebugUtilities.h"
#import "Settings.h"
#import "LocationManager.h"
#import "HorizontalListVC.h"
#import "Common.h"
#import "RestaurantVC.h"
#import "TimeUtilities.h"
#import "OOMapMarker.h"

@interface DiscoverVC () <GMSMapViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSCameraPosition *camera;
@property (nonatomic, strong) NSMutableSet *mapMarkers;

@end

static NSString * const ListRowID = @"HLRCell";

@implementation DiscoverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = kGeomHeightHorizontalListRow;
    
    [_tableView registerClass:[RestaurantHTVCell class] forCellReuseIdentifier:ListRowID];
    
    _camera = [GMSCameraPosition cameraWithLatitude:_currentLocation.latitude longitude:_currentLocation.longitude zoom:19 bearing:0 viewingAngle:1];

    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:_camera];
    _mapView.mapType = kGMSTypeNormal;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    _mapView.settings.scrollGestures = YES;
    _mapView.settings.zoomGestures = YES;
    _mapView.delegate = self;

    [_mapView setMinZoom:3 maxZoom:15];
    
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_mapView];
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Discover" subHeader:nil];
    self.navTitle = nto;
        
    [self layout];
}

- (void)layout {
    [super layout];
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView, _mapView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mapView(300)]-[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self layout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self verifyTrackingIsOkay];
}

- (void)verifyTrackingIsOkay
{
    if (0==self.currentLocation.longitude) {
        TrackingChoice c = [[LocationManager sharedInstance] dontTrackLocation];
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
    self.currentLocation = [[LocationManager sharedInstance] currentUserLocation];
    _camera = [GMSCameraPosition cameraWithLatitude:_currentLocation.latitude longitude:_currentLocation.longitude zoom:_camera.zoom bearing:_camera.bearing viewingAngle:_camera.viewingAngle];
    [_mapView moveCamera:[GMSCameraUpdate setCamera:_camera]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma table view delegates/datasources
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantObject *ro = [_restaurants objectAtIndex:indexPath.row];
    
    RestaurantHTVCell *cell = [tableView dequeueReusableCellWithIdentifier:ListRowID forIndexPath:indexPath];
    
    cell.restaurant = ro;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)getRestaurants
{
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak DiscoverVC *weakSelf=self;
    
    NSString *searchTerm = [TimeUtilities categorySearchString:[NSDate date]];
    NSLog(@"category: %@", searchTerm);
    
    _requestOperation = [api getRestaurantsWithKeyword:searchTerm andLocation:[[LocationManager sharedInstance] currentUserLocation] success:^(NSArray *r) {
        weakSelf.restaurants = r;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf gotRestaurants];
        });
    } failure:^(NSError *err) {
        ;
    }];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    UIView *infoWindow = [[UIView alloc] init];
    infoWindow.backgroundColor = UIColorRGBA(kColorWhite);
    infoWindow.layer.cornerRadius = kGeomCornerRadius;

    CGRect frame;
    
    UILabel *title = [[UILabel alloc] init];
    [title withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorNavyBlue backgroundColor:kColorClear];
    title.text = marker.title;
    [title sizeToFit];
    frame = title.frame;
    frame.origin.y = kGeomSpaceEdge;
    frame.origin.x = kGeomSpaceEdge;
    title.frame = frame;
    
    UILabel *snippet = [[UILabel alloc] init];
    [snippet withFont:[UIFont fontWithName:kFontLatoThin size:kGeomFontSizeSubheader] textColor:kColorNavyBlue backgroundColor:kColorClear];
    snippet.text = marker.snippet;
    [snippet sizeToFit];
    
    frame = snippet.frame;
    frame.origin.y = CGRectGetMaxY(title.frame);
    frame.origin.x = kGeomSpaceEdge;
    snippet.frame = frame;
    
    [infoWindow addSubview:title];
    [infoWindow addSubview:snippet];
    
    infoWindow.frame = CGRectMake(0, 0, kGeomSpaceEdge + ((CGRectGetMaxX(title.frame) > CGRectGetMaxX(snippet.frame)) ? CGRectGetMaxX(title.frame) : CGRectGetMaxX(snippet.frame)), CGRectGetMaxY(snippet.frame) + kGeomSpaceEdge);
    
    return infoWindow;
}

- (void)gotRestaurants
{
    NSLog(@"%tu", [_restaurants count]);
    if (![_restaurants count]) {
        NSLog (@"Received no restaurants.");
    }
    __weak DiscoverVC *weakSelf=self;
    _mapMarkers = [NSMutableSet setWithCapacity:[_restaurants count]];
    [_restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OOMapMarker *marker = [[OOMapMarker alloc] init];
        RestaurantObject *ro = (RestaurantObject *)obj;
        marker.position = ro.location;
        marker.title = ro.name;
        marker.snippet = @"my snippet";
        marker.map = _mapView;
        [marker highLight:YES];
        [weakSelf.mapMarkers addObject:marker];
    }];
    //    [self addSubview:_collectionView];
    [_tableView reloadData];
    
    //    [DebugUtilities addBorderToViews:@[self.collectionView] withColors:kColorNavyBlue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantObject *ro = [_restaurants objectAtIndex:indexPath.row];
    
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = ro.name;
    vc.restaurant = ro;
    [vc getRestaurant];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_restaurants count];
}

@end

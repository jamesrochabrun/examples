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
#import "RestaurantTVCell.h"
#import "DebugUtilities.h"
#import "Settings.h"
#import "LocationManager.h"
#import "RestaurantListVC.h"
#import "Common.h"
#import "RestaurantVC.h"
#import "TimeUtilities.h"
#import "OOMapMarker.h"
#import "OOFilterView.h"
#import "ListObject.h"
#import "TagObject.h"

@interface DiscoverVC () <GMSMapViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) CLLocationCoordinate2D desiredLocation;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSCameraPosition *camera;
@property (nonatomic, strong) NSMutableArray *mapMarkers;
@property (nonatomic, strong) OOFilterView *filterView;
@property (nonatomic) BOOL openOnly;
@property (nonatomic, strong) ListObject *listToDisplay;
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) GMSMarker *centerMarker;
@property (nonatomic, strong) NSSet *tags;

@end

static NSString * const ListRowID = @"HLRCell";

@implementation DiscoverVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _openOnly = YES;
        _mapView = [GMSMapView mapWithFrame:CGRectZero camera:_camera];
        _mapView.translatesAutoresizingMaskIntoConstraints = NO;
        _mapView.mapType = kGMSTypeNormal;
        _mapView.myLocationEnabled = YES;
        _mapView.settings.myLocationButton = YES;
        _mapView.settings.scrollGestures = YES;
        _mapView.settings.zoomGestures = YES;
        _mapView.delegate = self;
        [_mapView setMinZoom:0 maxZoom:16];
        _mapView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        _centerMarker = [[OOMapMarker alloc] init];
    }
    return self;
}

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
    _tableView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    [_tableView registerClass:[RestaurantTVCell class] forCellReuseIdentifier:ListRowID];
    
    _camera = [GMSCameraPosition cameraWithLatitude:_currentLocation.latitude longitude:_currentLocation.longitude zoom:13 bearing:0 viewingAngle:1];
    
    [self.view addSubview:_mapView];
    
    _filterView = [[OOFilterView alloc] init];
    _filterView.translatesAutoresizingMaskIntoConstraints = NO;
    [_filterView addFilter:@"Open Now" target:self selector:@selector(selectNow)];
    [_filterView addFilter:@"All" target:self selector:@selector(selectLater)];

    [self.view addSubview:_filterView];
    
    _nto = [[NavTitleObject alloc] initWithHeader:@"Discover" subHeader:@"places around me"];
    self.navTitle = _nto;

    if (_listToAddTo || _eventBeingEdited) {
        [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
    }
    
    [self setRightNavWithIcon:kFontIconDiscover target:self action:@selector(showOptions)];
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [self populateOptions];
}

- (void)showOptions {
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    OptionsVC *vc = [[OptionsVC alloc] init];
    vc.delegate = self;
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    [nc addChildViewController:vc];
    
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorBlack)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setShadowImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)]];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = [UIColor clearColor];

    [self.navigationController presentViewController:nc animated:YES completion:^{
        ;
    }];
}

- (void)optionsVCDismiss:(OptionsVC *)optionsVC withTags:(NSMutableSet *)tags {
    _tags = [NSSet setWithSet:tags];
    [self getRestaurants];
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)populateOptions {
    __weak DiscoverVC *weakSelf = self;
    
    self.dropDownList.delegate = self;
    OOAPI *api = [[OOAPI alloc] init];
    [api getListsOfUser:[Settings sharedInstance].userObject.userID withRestaurant:0 success:^(NSArray *lists) {
        ListObject *list = [[ListObject alloc] init];
        list.listID = 0;
        list.name = @"places around me";
        NSMutableArray *theLists = [NSMutableArray arrayWithObject:list];
        [theLists addObjectsFromArray:lists];
        weakSelf.dropDownList.options = theLists;
        ON_MAIN_THREAD(^{
            [self.navTitleView setDDLState:YES];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)dropDownList:(DropDownListTVC *)dropDownList optionTapped:(id)object {
    if (![object isKindOfClass:[ListObject class]]) return;
    _listToDisplay = (ListObject *)object;
    
    if (_listToDisplay.listID) {
        _nto.subheader = [NSString stringWithFormat:@"your \"%@\" places", _listToDisplay.name];
    } else {
        _nto.subheader = _listToDisplay.name;
    }
    self.navTitle = _nto;
    
    [self displayDropDown:NO];
    [self getRestaurants];
    
}

- (void)selectNow {
    _openOnly = YES;
    [_mapMarkers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OOMapMarker *mm = (OOMapMarker *)obj;
        mm.map = nil;
    }];
    [_mapMarkers removeAllObjects];
    [self getRestaurants];
}

- (void)selectLater {
    _openOnly = NO;
    [_mapMarkers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OOMapMarker *mm = (OOMapMarker *)obj;
        mm.map = nil;
    }];
    [_mapMarkers removeAllObjects];
    [self getRestaurants];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2), @"mapWidth" : @(width(self.view))};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView, _mapView, _filterView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_filterView(heightFilters)][_mapView(mapHeight)]-[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_filterView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)setListToAddTo:(ListObject *)listToAddTo {
    if (_listToAddTo == listToAddTo) return;
    _listToAddTo = listToAddTo;
}

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));

    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationBecameAvailable:)
                                                 name:kNotificationLocationBecameAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationBecameUnavailable:)
                                                 name:kNotificationLocationBecameUnavailable object:nil];

}

- (void)locationBecameAvailable:(id)notification
{
    NSLog(@"LOCATION BECAME AVAILABLE FROM iOS");
    __weak DiscoverVC *weakSelf = self;
    ON_MAIN_THREAD(^{
        [weakSelf getRestaurants];
    });
}

- (void)locationBecameUnavailable:(id)notification
{
    NSLog(@"LOCATION IS NOT AVAILABLE FROM iOS");
    __weak DiscoverVC *weakSelf = self;
    ON_MAIN_THREAD(^{
        [weakSelf getRestaurants];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self verifyTrackingIsOkay];
    if (!_desiredLocation.longitude)
        [self updateLocation];
}

- (void)verifyTrackingIsOkay
{
    if (_currentLocation.longitude == 0) {
        TrackingChoice c = [[LocationManager sharedInstance] dontTrackLocation];
        if (TRACKING_UNKNOWN == c) {
            [[LocationManager sharedInstance] askUserWhetherToTrack];
        }
        else if (TRACKING_YES == c) {
            [self updateLocation];
        }
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
    _desiredLocation = coordinate;
    [self getRestaurants];
}

- (void)updateLocation
{
    self.currentLocation = [[LocationManager sharedInstance] currentUserLocation];
    _camera = [GMSCameraPosition cameraWithLatitude:_currentLocation.latitude longitude:_currentLocation.longitude zoom:_camera.zoom bearing:_camera.bearing viewingAngle:_camera.viewingAngle];
    [_mapView moveCamera:[GMSCameraUpdate setCamera:_camera]];
    _desiredLocation = _currentLocation;
    [self getRestaurants];
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
    
    RestaurantTVCell *cell = [tableView dequeueReusableCellWithIdentifier:ListRowID forIndexPath:indexPath];
    
    cell.restaurant = ro;
    cell.listToAddTo = _listToAddTo;
    
    [cell updateConstraintsIfNeeded];

    [(OOMapMarker *)[_mapMarkers objectAtIndex:indexPath.row] highLight:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    OOMapMarker *marker = [_mapMarkers objectAtIndex:indexPath.row];
    [marker highLight:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_mapMarkers count] > indexPath.row) {
        OOMapMarker *marker = [_mapMarkers objectAtIndex:indexPath.row];
        [marker highLight:NO];
    }
}

- (void)getRestaurants
{
    CLLocationCoordinate2D bottomLeftCoord = _mapView.projection.visibleRegion.nearLeft;
    CLLocationCoordinate2D bottomRightCoord = _mapView.projection.visibleRegion.nearRight;
    CLLocationCoordinate2D topLeftCoord = _mapView.projection.visibleRegion.farLeft;
//    CLLocationCoordinate2D topRightCoord = _mapView.projection.visibleRegion.farRight;

    CGFloat longitudeDelta = (bottomRightCoord.longitude- bottomLeftCoord.longitude)/2;
    CGFloat lattitudeDelta = (bottomLeftCoord.latitude - topLeftCoord.latitude)/2;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(topLeftCoord.latitude+lattitudeDelta, topLeftCoord.longitude+longitudeDelta);
    CLLocationCoordinate2D topEdge = CLLocationCoordinate2DMake(topLeftCoord.latitude, center.longitude);

    UILabel *locationIcon = [[UILabel alloc] init];
    [locationIcon withFont:[UIFont fontWithName:kFontIcons size:20] textColor:kColorBlack backgroundColor:kColorClear];
    locationIcon.text = kFontIconUserTag;
    locationIcon.frame = CGRectMake(0, 0, 20, 20);
    _centerMarker.position = center;
    _centerMarker.icon = [UIImage imageFromView:locationIcon];
    _centerMarker.map = _mapView;
    
//DEBUG math
//    OOMapMarker *topEdgeMarker = [[OOMapMarker alloc] init];
//    topEdgeMarker.position = topEdge;
//    topEdgeMarker.map = _mapView;
   
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:topEdge.latitude longitude:topEdge.longitude];
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];

    
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak DiscoverVC *weakSelf=self;

    if (_listToDisplay && _listToDisplay.listID) {
        [api getRestaurantsWithListID:_listToDisplay.listID success:^(NSArray *restaurants) {
            _restaurants = restaurants;
            ON_MAIN_THREAD(^ {
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    } else {
        NSMutableArray *searchTerms;
        if (_tags) {
            searchTerms = [NSMutableArray array];
            [_tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                TagObject *t = (TagObject *)obj;
                [searchTerms addObject:t.term];
            }];
        } else {
            searchTerms = (_openOnly) ? [NSMutableArray arrayWithArray:[TimeUtilities categorySearchTerms:[NSDate date]]] : [NSMutableArray arrayWithArray:@[@"restaurant", @"bar"]];
            NSLog(@"category: %@", searchTerms);
        }
        _requestOperation = [api getRestaurantsWithKeywords:searchTerms
                                               andLocation:center // _desiredLocation
                                                 andFilter:@""
                                                  andRadius:distanceInMeters
                                               andOpenOnly:_openOnly
                                                      andSort:kSearchSortTypeBestMatch
                                                   success:^(NSArray *r) {
            _restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            ;
        }];
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(OOMapMarker *)marker {
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:marker.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [_mapView setSelectedMarker:marker];
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(OOMapMarker *)marker {
//    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:marker.index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
    NSLog(@"%lu", (unsigned long)[_restaurants count]);
    if (![_restaurants count]) {
        NSLog (@"Received no restaurants.");
    }

    [_mapMarkers enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OOMapMarker *mm = (OOMapMarker *)obj;
        mm.map = nil;
    }];
    [_mapMarkers removeAllObjects];
    _mapMarkers = [NSMutableArray arrayWithCapacity:[_restaurants count]];

    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];

    [_restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OOMapMarker *marker = [[OOMapMarker alloc] init];
        RestaurantObject *ro = (RestaurantObject *)obj;
        
        CLLocation *locationB = [[CLLocation alloc] initWithLatitude:ro.location.latitude longitude:ro.location.longitude];
        CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];

        marker.objectID = ro.googleID;
        marker.index = idx;
        marker.position = ro.location;
        marker.title = ro.name;
        marker.snippet = [NSString stringWithFormat:@"%0.1f mi. | %@", metersToMiles(distanceInMeters), [ro priceRangeText]];
        marker.map = _mapView;
        [marker highLight:NO];
        [_mapMarkers addObject:marker];
    }];
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
    vc.eventBeingEdited= self.eventBeingEdited;
    vc.listToAddTo = _listToAddTo;
    [vc getRestaurant];
    ANALYTICS_EVENT_UI(@"RestaurantVC-from-Discover");
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

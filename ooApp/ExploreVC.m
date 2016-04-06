//
//  ExploreVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ExploreVC.h"
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
#import "AppDelegate.h"

@interface ExploreVC () <GMSMapViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) CLLocationCoordinate2D desiredLocation;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSCameraPosition *camera;
@property (nonatomic, strong) NSMutableArray *mapMarkers;
@property (nonatomic, strong) OOFilterView *filterView;
@property (nonatomic, assign) BOOL nearby;
@property (nonatomic, strong) ListObject *listToDisplay;
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) ListObject *defaultListObject;
@property (nonatomic, strong) NSMutableSet *tags;
@property (nonatomic) NSUInteger minPrice, maxPrice;
@property (nonatomic, strong) UIButton *changeLocationButton;

@end

static NSString * const ListRowID = @"HLRCell";

@implementation ExploreVC

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:_camera];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    _mapView.mapType = kGMSTypeNormal;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    _mapView.settings.scrollGestures = YES;
    _mapView.settings.zoomGestures = YES;
    _mapView.settings.rotateGestures = NO;
    _mapView.delegate = self;
    [_mapView setMinZoom:0 maxZoom:16];
    _mapView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = kGeomHeightHorizontalListRow;
    _tableView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    [_tableView registerClass:[RestaurantTVCell class] forCellReuseIdentifier:ListRowID];
    
    _changeLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_changeLocationButton roundButtonWithIcon:kFontIconLocation fontSize:kGeomIconSize width:30 height:30 backgroundColor:kColorClear target:self selector:@selector(userPressedChangeLocation:)];
    [_changeLocationButton setTitleColor:UIColorRGBA(kColorBlack) forState:UIControlStateNormal];
    _changeLocationButton.layer.borderColor = UIColorRGBA(kColorGrayMiddle).CGColor;
    [self.mapView addSubview: _changeLocationButton];
    
    _camera = [GMSCameraPosition cameraWithLatitude:_currentLocation.latitude longitude:_currentLocation.longitude zoom:13 bearing:0 viewingAngle:1];
    
    _tags = [NSMutableSet set];
    
    [self.view addSubview:_mapView];
    
    _filterView = [[OOFilterView alloc] init];
    _filterView.translatesAutoresizingMaskIntoConstraints = NO;
    [_filterView addFilter:@"Around Me" target:self selector:@selector(selectNearby)];
    [_filterView addFilter:@"Top Spots" target:self selector:@selector(selectTopSpots)];
    [self.view addSubview:_filterView];
    _nearby = NO;
    [_filterView setCurrent:1];
    
    _nto = [[NavTitleObject alloc] initWithHeader:@"Explore" subHeader:nil];
    self.navTitle = _nto;

    if (_listToAddTo || _eventBeingEdited) {
        [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
    } else {
        [self setLeftNavWithIcon:@"" target:nil action:nil];
    }
    
    [self setRightNavWithIcon:kFontIconDiscover target:self action:@selector(showOptions)];
    
    _minPrice = 0;
    _maxPrice = 3;
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [self populateOptions];
}

- (void)userPressedChangeLocation: (UIButton*)sender
{
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    
    ChangeLocationVC *vc = [[ChangeLocationVC alloc] init];
    vc.delegate = self;
    [nc addChildViewController:vc];
    
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController presentViewController:nc animated:YES completion:^{
        nc.topViewController.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }];

}

- (void)changeLocationVCCanceled:(ChangeLocationVC *)changeLocationVC {
    _currentLocation = [LocationManager sharedInstance].currentUserLocation;
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)changeLocationVC:(ChangeLocationVC *)changeLocationVC locationSelected:(CLPlacemark *)placemark {
    _currentLocation = placemark.location.coordinate;
    [self moveToCurrentLocation];
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    NSLog(@"The map became idle at %f,%f", position.target.latitude, position.target.longitude);
    _desiredLocation = position.target;
    [self getRestaurants];
}

- (void)showOptions {
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    OptionsVC *vc = [[OptionsVC alloc] init];
    vc.delegate = self;
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    [nc addChildViewController:vc];
    
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = [UIColor clearColor];

    vc.userTags = _tags;
    [vc setMinPrice:_minPrice maxPrice:_maxPrice];
    
    [self.navigationController presentViewController:nc animated:YES completion:^{
        ;
    }];
}

- (void)optionsVCDismiss:(OptionsVC *)optionsVC withTags:(NSMutableSet *)tags andMinPrice:(NSUInteger)minPrice andMaxPrice:(NSUInteger)maxPrice {
    _tags = [NSMutableSet setWithSet:tags];
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _listToDisplay = nil;
    [_filterView setNeedsLayout];
    _nearby = NO;
    [self getRestaurants];
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)populateOptions {
    __weak ExploreVC *weakSelf = self;
    
    self.dropDownList.delegate = self;
    OOAPI *api = [[OOAPI alloc] init];
    [api getListsOfUser:[Settings sharedInstance].userObject.userID
         withRestaurant:0
             includeAll:YES
                success:^(NSArray *lists) {
        if ([lists count]) {
            _defaultListObject = [[ListObject alloc] init];
            _defaultListObject.listID = 0;
            _defaultListObject.name = [self getFilteredListName];
            NSMutableArray *theLists = [NSMutableArray arrayWithObject:_defaultListObject];
            
            [theLists addObjectsFromArray:lists];
            weakSelf.dropDownList.options = theLists;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navTitleView setDDLState:YES];
            });
        }
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
        _defaultListObject.name = [self getFilteredListName];;
        _nto.subheader = _defaultListObject.name;
    }
    self.navTitle = _nto;
    
    [self displayDropDown:NO];
    [self getRestaurants];
}

- (void)selectNearby {
    _nearby = YES;
    [_mapMarkers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OOMapMarker *mm = (OOMapMarker *)obj;
        mm.map = nil;
    }];
    [_mapMarkers removeAllObjects];
    [self getRestaurants];
}

- (void)selectTopSpots {
    _nearby = NO;
    [_mapMarkers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OOMapMarker *mm = (OOMapMarker *)obj;
        mm.map = nil;
    }];
    [_mapMarkers removeAllObjects];
    [self getRestaurants];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)*0.4), @"mapWidth" : @(width(self.view))};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView, _mapView, _filterView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_filterView(heightFilters)][_mapView(mapHeight)]-[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_filterView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)setListToAddTo:(ListObject *)listToAddTo
{
    if (_listToAddTo == listToAddTo) return;
    _listToAddTo = listToAddTo;
    
    __weak  ExploreVC *weakSelf = self;
    if (_listToAddTo && _listToAddTo.listID) {
        OOAPI*api= [[OOAPI alloc] init];
        [api getRestaurantsWithListID: _listToAddTo.listID
                          andLocation:[LocationManager sharedInstance].currentUserLocation
                              success:^(NSArray *restaurants) {
                                  ON_MAIN_THREAD(^ {
                                      weakSelf.listToAddTo.venues= restaurants.mutableCopy;
                                      [weakSelf.tableView reloadData];
                                  });
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  ;
                              }];
    }
    
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

    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationBecameAvailable:)
                                                 name:kNotificationLocationBecameAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationBecameUnavailable:)
                                                 name:kNotificationLocationBecameUnavailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLocationIfRequired)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self.refreshControl addTarget:self action:@selector(forceRefresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:self.refreshControl];
    _tableView.alwaysBounceVertical = YES;
}

- (void)forceRefresh:(id)sender {
    [self updateLocation];
}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [super viewWillDisappear:animated];
}

- (void)updateLocationIfRequired {
    CLLocationCoordinate2D currentLocation = [LocationManager sharedInstance].currentUserLocation;
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:_desiredLocation.latitude longitude:_desiredLocation.longitude];
    
    if ([loc1 distanceFromLocation:loc2] > kMetersMovedBeforeForcedUpdate) {
        [self updateLocation];
        [self getRestaurants];
        APP.dateLeft = [NSDate date];
        return;
    }
    
    if (!APP.dateLeft || (APP.dateLeft && [[NSDate date] timeIntervalSinceDate:APP.dateLeft] > [TimeUtilities intervalFromDays:0 hours:0 minutes:45 second:00])) {
        [self updateLocation];
        APP.dateLeft = [NSDate date];
    }
}

- (void)locationBecameAvailable:(id)notification
{
    NSLog(@"LOCATION BECAME AVAILABLE FROM iOS");
    __weak ExploreVC *weakSelf = self;
    ON_MAIN_THREAD(^{
        [weakSelf updateLocation];
        [weakSelf getRestaurants];
    });
}

- (void)locationBecameUnavailable:(id)notification
{
    NSLog(@"LOCATION IS NOT AVAILABLE FROM iOS");
//    __weak DiscoverVC *weakSelf = self;
//    ON_MAIN_THREAD(^{
//        [weakSelf getRestaurants];
//    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self verifyTrackingIsOkay];
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
            [self getRestaurants];
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
    [self moveToCurrentLocation];
}

- (void)moveToCurrentLocation
{
    _camera = [GMSCameraPosition cameraWithLatitude:_currentLocation.latitude longitude:_currentLocation.longitude zoom:_camera.zoom bearing:_camera.bearing viewingAngle:_camera.viewingAngle];
    [_mapView moveCamera:[GMSCameraUpdate setCamera:_camera]];
    _desiredLocation = _currentLocation;
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
    
    cell.eventBeingEdited= self.eventBeingEdited;
    cell.listToAddTo = _listToAddTo;
    cell.restaurant = ro;
    cell.nc = self.navigationController;
    cell.index = indexPath.row + 1;
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
    [locationIcon withFont:[UIFont fontWithName:kFontIcons size:kGeomIconSizeSmall] textColor:kColorBlack backgroundColor:kColorClear];
    locationIcon.text = kFontIconPerson;
    locationIcon.frame = CGRectMake(0, 0, 30, 30);
    
//DEBUG math
//    OOMapMarker *topEdgeMarker = [[OOMapMarker alloc] init];
//    topEdgeMarker.position = topEdge;
//    topEdgeMarker.map = _mapView;
   
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:topEdge.latitude longitude:topEdge.longitude];
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];

    
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak ExploreVC *weakSelf=self;
    
    [self.view bringSubviewToFront:self.aiv];
    [self.aiv startAnimating];
    self.aiv.message = @"loading";
    [self.refreshControl endRefreshing];

    if (_listToDisplay && _listToDisplay.listID) {
        [api getRestaurantsWithListID:_listToDisplay.listID
                          andLocation:[LocationManager sharedInstance].currentUserLocation
                              success:^(NSArray *restaurants) {
            _restaurants = restaurants;
            ON_MAIN_THREAD(^ {
                [weakSelf.aiv stopAnimating];
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakSelf.aiv stopAnimating];
        }];
    } else {
        NSMutableArray *searchTerms;
        if (_tags && [_tags count]) {
            searchTerms = [NSMutableArray array];
            [_tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                TagObject *t = (TagObject *)obj;
                [searchTerms addObject:t.term];
            }];
        } else if (_nearby) {
            searchTerms = [NSMutableArray arrayWithArray:@[]];
        } else {
            searchTerms = [NSMutableArray arrayWithArray:[TimeUtilities categorySearchTerms:[NSDate date]]];
            NSLog(@"category: %@", searchTerms);
        }
        _defaultListObject.name = [self getFilteredListName];
        _nto.subheader = _defaultListObject.name;
        self.navTitle = _nto;
        
        _requestOperation = [api getRestaurantsWithKeywords:searchTerms
                                               andLocation:center // _desiredLocation
                                                 andFilter:@""
                                                  andRadius:distanceInMeters
                                               andOpenOnly:NO
                                                    andSort:(_nearby) ? kSearchSortTypeDistance : kSearchSortTypeBestMatch
                                                   minPrice:_minPrice
                                                   maxPrice:_maxPrice
                                                     isPlay:NO
                                                   success:^(NSArray *r) {
            _restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
                [weakSelf.aiv stopAnimating];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            [weakSelf.aiv stopAnimating];
        }];
    }
}

- (NSString *)getFilteredListName {
    if (_tags && [_tags count]) {
        __block NSMutableString *terms = [NSMutableString string];
        [_tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            TagObject *t = (TagObject *)obj;
            [terms appendString:[NSString stringWithFormat:@"\"%@\" ", t.term]];
        }];
        return terms;
    } else {
        return @"places around me";
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(OOMapMarker *)marker {
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:marker.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [_mapView setSelectedMarker:marker];
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(OOMapMarker *)marker {
    RestaurantObject *ro = [_restaurants objectAtIndex:marker.index];
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = ro.name;
    vc.restaurant = ro;
    vc.eventBeingEdited= self.eventBeingEdited;
    vc.listToAddTo = _listToAddTo;
    [vc getRestaurant];
    ANALYTICS_EVENT_UI(@"RestaurantVC-from-Explore-MarkerInfoWindow");
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
    ANALYTICS_EVENT_UI(@"RestaurantVC-from-Explore");
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

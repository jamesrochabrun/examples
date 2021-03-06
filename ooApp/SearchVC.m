//
//  SearchVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "SearchVC.h"
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
#import "OOFeedbackView.h"

@interface SearchVC () <GMSMapViewDelegate>

@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) OOFeedbackView *fv;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) CLLocationCoordinate2D desiredLocation;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSCameraPosition *camera;
@property (nonatomic, strong) NSMutableArray *mapMarkers;
//@property (nonatomic, strong) OOFilterView *filterView;
@property (nonatomic, assign) BOOL nearby;
@property (nonatomic, strong) ListObject *listToDisplay;
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) ListObject *defaultListObject;
@property (nonatomic, strong) NSMutableSet *tags;
@property (nonatomic) NSUInteger minPrice, maxPrice;
@property (nonatomic, strong) UIButton *resetLocation;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchBar *locationSearchBar;
@property (nonatomic, assign) BOOL showMap;
@property (nonatomic, strong) NSArray *mapConstraints;
@property (nonatomic, strong) UITableView *restaurantsTable;
@property (nonatomic, strong) UITableView *locationsTable;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) UIView *locationsBgView;
@property (nonatomic, strong) UIImageView *restaurantImage;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

static NSString *const ListRowID = @"HLRCell";
static NSString *const locationCellIdentifier = @"locationCell";
static NSUInteger const kMinCharactersForAutoSearch = 3;

@implementation SearchVC

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showMap = YES;
    
    _fv = [[OOFeedbackView alloc] initWithFrame:CGRectMake(0, 0, 110, 90) andMessage:@"oy vey" andIcon:kFontIconCheckmark];
    [self.view addSubview:_fv];

    _searchBar = [UISearchBar new];
    _searchBar.placeholder = kSearchPlaceholderPlaces;
    _searchBar.frame = CGRectMake(0, 0, 200, 60);
    _searchBar.delegate = self;
    _searchBar.enablesReturnKeyAutomatically = NO;
    
    _locationSearchBar = [UISearchBar new];
    _locationSearchBar.backgroundColor = UIColorRGBA(kColorNavBar);
    _locationSearchBar.barTintColor = UIColorRGBA(kColorNavBar);
    _locationSearchBar.placeholder = kSearchPlaceholderPlaces;
    _locationSearchBar.delegate = self;
    _locationSearchBar.placeholder = LOCAL(@"Around Here");
    _locationSearchBar.enablesReturnKeyAutomatically = NO;
    _locationSearchBar.layer.borderColor = UIColorRGBA(kColorNavBar).CGColor;
    _locationSearchBar.layer.borderWidth = 1;
    
    
    _locationsBgView = [UIView new];
    _locationsBgView.backgroundColor = UIColorRGBA(kColorNavBar);
    _locationsBgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_locationsBgView];

    UILabel *l = [UILabel new];
    [l withFont:[UIFont fontWithName:kFontIcons size:kGeomIconSize] textColor:kColorText backgroundColor:kColorClear];
    l.text = kFontIconLocation;
    [l sizeToFit];
    [_locationSearchBar setImage:[UIImage imageFromView:l] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    _locationSearchBar.keyboardAppearance = UIKeyboardAppearanceDefault;
    _locationSearchBar.keyboardType = UIKeyboardTypeAlphabet;
    _locationSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _locationSearchBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_locationsBgView addSubview:_locationSearchBar];

    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:_camera];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    _mapView.mapType = kGMSTypeNormal;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = NO;
    _mapView.settings.scrollGestures = YES;
    _mapView.settings.zoomGestures = YES;
    _mapView.settings.rotateGestures = NO;
    _mapView.delegate = self;
    [_mapView setMinZoom:0 maxZoom:20];
    _mapView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _restaurantsTable = [[UITableView alloc] init];
    [self.view addSubview:_restaurantsTable];
    _restaurantsTable.delegate = self;
    _restaurantsTable.dataSource = self;
    _restaurantsTable.translatesAutoresizingMaskIntoConstraints = NO;
    _restaurantsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _restaurantsTable.separatorInset = UIEdgeInsetsZero;
    _restaurantsTable.layoutMargins = UIEdgeInsetsZero;
    
    _restaurantsTable.rowHeight = kGeomHeightHorizontalListRow;
    _restaurantsTable.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    [_restaurantsTable registerClass:[RestaurantTVCell class] forCellReuseIdentifier:ListRowID];
    
    _locationsTable = [UITableView new];
    _locationsTable.dataSource = self;
    _locationsTable.delegate = self;
    _locationsTable.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _locationsTable.rowHeight = 44;
    _locationsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _locationsTable.separatorInset = UIEdgeInsetsZero;
    _locationsTable.layoutMargins = UIEdgeInsetsZero;

    [_locationsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:locationCellIdentifier];
    _locationsTable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_locationsTable];
    _locationsTable.alpha = 0;
    
    _resetLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resetLocation withIcon:kFontIconLocation fontSize:kGeomIconSize width:30 height:30 backgroundColor:kColorNavBar target:self selector:@selector(resetLocationToHere:)];
    [_resetLocation setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
    _resetLocation.layer.cornerRadius = 0;
    //[self.view addSubview: _resetLocation];
    _resetLocation.translatesAutoresizingMaskIntoConstraints = NO;
    [_locationsBgView addSubview:_resetLocation];
    
    _camera = [GMSCameraPosition cameraWithLatitude:_currentLocation.latitude longitude:_currentLocation.longitude zoom:14 bearing:0 viewingAngle:1];
    
    _tags = [NSMutableSet set];
    
    [self.view addSubview:_mapView];

    [self.view bringSubviewToFront:_locationsTable];
    _nearby = YES;
    
    _nto = [[NavTitleObject alloc] initWithHeader:@"Search" subHeader:nil];
    self.navTitle = _nto;
    self.navigationItem.titleView = _searchBar;

    if (_listToAddTo || _eventBeingEdited) {
        [self removeNavButtonForSide:kNavBarSideTypeLeft];
        [self addNavButtonWithIcon:kFontIconBack target:self action:@selector(done:) forSide:kNavBarSideTypeLeft isCTA:NO];
    } else {
        [self removeNavButtonForSide:kNavBarSideTypeLeft];
    }
    
    [self removeNavButtonForSide:kNavBarSideTypeRight];
    [self addNavButtonWithIcon:kFontIconMap target:self action:@selector(toggleMap) forSide:kNavBarSideTypeRight isCTA:NO];
    
    _minPrice = 0;
    _maxPrice = 3;
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
//    [self populateOptions];
    
    _currentLocation = [LocationManager sharedInstance].currentUserLocation;
    [self updateLocation];
    
    _restaurantImage = [UIImageView new];
    _restaurantImage.contentMode = UIViewContentModeScaleAspectFit;
    _restaurantImage.backgroundColor = UIColorRGBOverlay(kColorBackgroundTheme, 0.90);
    _restaurantImage.userInteractionEnabled = YES;
    _restaurantImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRestaurantPhotoFullScreen:)];
    [_tapGestureRecognizer setNumberOfTapsRequired:1];
    [_restaurantImage addGestureRecognizer:_tapGestureRecognizer];
    _restaurantImage.hidden = YES;
    
    [self.view addSubview:_restaurantImage];
    
    [self.view bringSubviewToFront:_restaurantImage];
    
    //[DebugUtilities addBorderToViews:@[_resetLocation]];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == _locationSearchBar) {
        _locationsTable.alpha = 1;
    } else {
        _locationsTable.alpha = 0;
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar == _locationSearchBar) {
        if ([_locations count] == 1) {
            _locationsTable.alpha = 0;
            CLPlacemark *placemark = [_locations objectAtIndex:0];
            _locationSearchBar.text = [Common locationString:placemark];
            _currentLocation = placemark.location.coordinate;
            [self moveToCurrentLocation];
        }
    } else {
        
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar == _locationSearchBar) {
        [self searchLocations];
    } else {
        if ([searchText length] >= kMinCharactersForAutoSearch) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getRestaurants) object:nil];
            [self performSelector:@selector(getRestaurants) withObject:nil afterDelay:1];
            //[self getRestaurants];
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    if ([searchBar.text length] < kMinCharactersForAutoSearch) {
        [self getRestaurants];
    }
    _locationsTable.alpha = 0;
}

- (void)resetLocationToHere:(id)sender {
    _currentLocation = [LocationManager sharedInstance].currentUserLocation;
    _locationSearchBar.text = @"";
    _locations = @[];
    [_locationsTable reloadData];
    [self moveToCurrentLocation];
    _locationsTable.alpha = 0;
}

- (void)searchLocations {
    __weak SearchVC *weakSelf = self;
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    CLRegion *region = [[CLRegion alloc] init];
    
    
    [geocoder geocodeAddressString:_locationSearchBar.text inRegion:region
                 completionHandler:^(NSArray* placemarks, NSError* error) {
                     _locations = placemarks;
                     if (![_locations count]) {
                         NSLog(@"Could not find a location that matched: %@", _locationSearchBar.text);
                     } else {
                         NSLog(@"Found %lu locations that matched: %@", (unsigned long)[_locations count], _locationSearchBar.text);
                         for (CLPlacemark *pm in placemarks) {
                             NSLog(@"placemark name: %@", pm.addressDictionary);
                         }
                         
                     }
                     [weakSelf.locationsTable reloadData];
                 }];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    NSLog(@"The map became idle at %f,%f", position.target.latitude, position.target.longitude);
    _desiredLocation = position.target;
   [self getRestaurants];
}


//- (void)populateOptions {
//    __weak SearchVC *weakSelf = self;
//    
//    self.dropDownList.delegate = self;
//    OOAPI *api = [[OOAPI alloc] init];
//    [api getListsOfUser:[Settings sharedInstance].userObject.userID
//         withRestaurant:0
//             includeAll:YES
//                success:^(NSArray *lists) {
//        if ([lists count]) {
//            _defaultListObject = [[ListObject alloc] init];
//            _defaultListObject.listID = 0;
//            _defaultListObject.name = [self getFilteredListName];
//            NSMutableArray *theLists = [NSMutableArray arrayWithObject:_defaultListObject];
//            
//            [theLists addObjectsFromArray:lists];
//            weakSelf.dropDownList.options = theLists;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.navTitleView setDDLState:YES];
//            });
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        ;
//    }];
//}

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
    self.navigationItem.titleView = _searchBar;
    
    [self displayDropDown:NO];
    [self getRestaurants];
}

- (void)toggleMap {
    _showMap = !_showMap;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((_showMap)?(height(self.view)-kGeomHeightNavBarStatusBar)*0.4:0), @"mapWidth" : @(width(self.view))};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_restaurantsTable, _mapView, _locationSearchBar, _locationsTable, _resetLocation, _locationsBgView, _restaurantImage);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view removeConstraints:_mapConstraints];
    _mapConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_locationsBgView(40)][_mapView(mapHeight)]-[_restaurantsTable]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
    
    [self.view addConstraints:_mapConstraints];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_restaurantImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_restaurantImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_resetLocation]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_locationSearchBar]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_locationsBgView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_locationsBgView][_locationsTable]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views] ];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_locationSearchBar(>=0)][_resetLocation(40)]-15-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_restaurantsTable]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_locationsTable]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_filterView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)setListToAddTo:(ListObject *)listToAddTo
{
    if (_listToAddTo == listToAddTo) return;
    _listToAddTo = listToAddTo;
    
    __weak SearchVC *weakSelf = self;
    if (_listToAddTo && _listToAddTo.listID) {
        OOAPI*api= [[OOAPI alloc] init];
        [api getRestaurantsWithListID: _listToAddTo.listID
                          andLocation:[LocationManager sharedInstance].currentUserLocation
                              success:^(NSArray *restaurants) {
                                  ON_MAIN_THREAD(^ {
                                      weakSelf.listToAddTo.venues= restaurants.mutableCopy;
                                      [weakSelf.restaurantsTable reloadData];
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
    ANALYTICS_SCREEN(@(object_getClassName(self)));

    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotFirstLocation:)
                                                 name:kNotificationGotFirstLocation object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(locationBecameAvailable:)
//                                                 name:kNotificationLocationBecameAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationBecameUnavailable:)
                                                 name:kNotificationLocationBecameUnavailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLocationIfRequired)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self.refreshControl addTarget:self action:@selector(forceRefresh:) forControlEvents:UIControlEventValueChanged];
    [_restaurantsTable addSubview:self.refreshControl];
    _restaurantsTable.alwaysBounceVertical = YES;
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
    
    if ([loc1 distanceFromLocation:loc2] > kMetersMovedBeforeForcedUpdate &&
        ![_locationSearchBar.text length]) {
        [self updateLocation];
        [self getRestaurants];
        APP.dateLeft = [NSDate date];
        return;
    } else if ([_locationSearchBar isFirstResponder]) {
        [_searchBar becomeFirstResponder];
    }
    
    if (!APP.dateLeft || (APP.dateLeft && [[NSDate date] timeIntervalSinceDate:APP.dateLeft] > [TimeUtilities intervalFromDays:0 hours:0 minutes:45 second:00])) {
        [self updateLocation];
        APP.dateLeft = [NSDate date];
    }
}

- (void)gotFirstLocation:(id)notification
{
    NSLog(@"LOCATION BECAME AVAILABLE FROM iOS");
    __weak SearchVC *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateLocation];
        //[weakSelf getRestaurants];
    });
}

- (void)locationBecameUnavailable:(id)notification
{
    NSLog(@"LOCATION IS NOT AVAILABLE FROM iOS");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)verifyTrackingIsOkay {
    if (_currentLocation.longitude == 0) {
        TrackingChoice c = [[LocationManager sharedInstance] dontTrackLocation];
        if (TRACKING_UNKNOWN == c) {
            [[LocationManager sharedInstance] askUserWhetherToTrack];
        } else if (TRACKING_YES == c) {
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
    if (tableView == _locationsTable) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:locationCellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setTextColor:UIColorRGBA(kColorText)];
        [cell.detailTextLabel setTextColor:UIColorRGBA(kColorText)];
        cell.backgroundColor = UIColorRGBA(kColorClear);
        cell.textLabel.backgroundColor = UIColorRGBA(kColorClear);
        [cell.textLabel setFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH3]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4]];
        cell.textLabel.numberOfLines = 2;
        CLPlacemark *placemark = [_locations objectAtIndex:indexPath.row];
        cell.textLabel.text = [Common locationString:placemark];
        return cell;
    } else {
        RestaurantObject *ro = [_restaurants objectAtIndex:indexPath.row];
        
        RestaurantTVCell *cell = [tableView dequeueReusableCellWithIdentifier:ListRowID forIndexPath:indexPath];
        
        cell.eventBeingEdited= self.eventBeingEdited;
        cell.listToAddTo = _listToAddTo;
        cell.restaurant = ro;
        cell.nc = self.navigationController;
        cell.delegate = self;
        cell.index = indexPath.row + 1;
        [cell updateConstraintsIfNeeded];
        
        [(OOMapMarker *)[_mapMarkers objectAtIndex:indexPath.row] highLight:YES];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _restaurantsTable) {
        OOMapMarker *marker = [_mapMarkers objectAtIndex:indexPath.row];
        [marker highLight:YES];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _restaurantsTable) {
        if ([_mapMarkers count] > indexPath.row) {
            OOMapMarker *marker = [_mapMarkers objectAtIndex:indexPath.row];
            [marker highLight:NO];
        }
    }
}

- (void)getRestaurants
{
    [_requestOperation cancel];
    _requestOperation = nil;
    CLLocationCoordinate2D bottomLeftCoord = _mapView.projection.visibleRegion.nearLeft;
    CLLocationCoordinate2D bottomRightCoord = _mapView.projection.visibleRegion.nearRight;
    CLLocationCoordinate2D topLeftCoord = _mapView.projection.visibleRegion.farLeft;
//    CLLocationCoordinate2D topRightCoord = _mapView.projection.visibleRegion.farRight;

    CGFloat longitudeDelta = (bottomRightCoord.longitude- bottomLeftCoord.longitude)/2;
    CGFloat lattitudeDelta = (bottomLeftCoord.latitude - topLeftCoord.latitude)/2;
    
    CLLocationCoordinate2D center;
    if (_showMap) {
        center = CLLocationCoordinate2DMake(topLeftCoord.latitude+lattitudeDelta, topLeftCoord.longitude+longitudeDelta);
    } else {
        center = _currentLocation;
    }
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
    
    __weak SearchVC *weakSelf=self;
    
    [self.view bringSubviewToFront:self.aiv];
    [self.aiv startAnimating];
    self.aiv.message = @"loading";
    [self.refreshControl endRefreshing];

    if (_listToDisplay && _listToDisplay.listID) {
        [api getRestaurantsWithListID:_listToDisplay.listID
                          andLocation:[LocationManager sharedInstance].currentUserLocation
                              success:^(NSArray *restaurants) {
            _restaurants = restaurants;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.aiv stopAnimating];
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.aiv stopAnimating];
            });
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
            searchTerms = [NSMutableArray array];
            if (_searchBar.text) {
                [searchTerms addObject:_searchBar.text];
            } else {
                searchTerms = [NSMutableArray arrayWithArray:@[]];
            }
        } else {
            searchTerms = [NSMutableArray arrayWithArray:[TimeUtilities categorySearchTerms:[NSDate date]]];
            NSLog(@"category: %@", searchTerms);
        }
        _defaultListObject.name = [self getFilteredListName];
        _nto.subheader = _defaultListObject.name;
        self.navTitle = _nto;
        self.navigationItem.titleView = _searchBar;
        
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
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
                [weakSelf.aiv stopAnimating];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.aiv stopAnimating];
            });
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
    [_restaurantsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:marker.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
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
    ANALYTICS_EVENT_UI(@"RestaurantVC-from-Search-MarkerInfoWindow");
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
    [snippet withFont:[UIFont fontWithName:kFontLatoLight size:kGeomFontSizeSubheader] textColor:kColorNavyBlue backgroundColor:kColorClear];
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

- (void)gotRestaurants {
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
    [_restaurantsTable reloadData];
    
    if ([_restaurants count]) {
        [_restaurantsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (tableView == _locationsTable) {
        CLPlacemark *placemark = [_locations objectAtIndex:indexPath.row];
        _locationSearchBar.text = [Common locationString:placemark];
        _currentLocation = placemark.location.coordinate;
        [self moveToCurrentLocation];
        _locationsTable.alpha = 0;
    } else {
        RestaurantObject *ro = [_restaurants objectAtIndex:indexPath.row];
        
        RestaurantVC *vc = [[RestaurantVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        vc.title = ro.name;
        vc.restaurant = ro;
        vc.eventBeingEdited= self.eventBeingEdited;
        vc.listToAddTo = _listToAddTo;
        [vc getRestaurant];
        ANALYTICS_EVENT_UI(@"RestaurantVC-from-Search");
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    } else if ([_locationSearchBar isFirstResponder]) {
        [_locationSearchBar resignFirstResponder];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _locationsTable) {
        return [_locations count];
    } else {
        return [_restaurants count];
    }
}

- (void)objectTVCellThumbnailTapped:(ObjectTVCell *)objectTVCell {
    if (![objectTVCell isKindOfClass:[RestaurantTVCell class]]) return;
    
    RestaurantObject *restaurant = ((RestaurantTVCell *)objectTVCell).restaurant;
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    vc.restaurant = restaurant;
    [self.navigationController pushViewController:vc animated:YES];
    return; //can pop up a message to tell the user to upload a photo
}

- (void)showRestaurantPhotoFullScreen:(id)sender {
    if (!_restaurantImage.hidden) {
        _restaurantImage.hidden = YES;
    } else {
        __weak SearchVC *weakSelf = self;
        if (!sender || ![sender isKindOfClass:[MediaItemObject class]]) return;
        MediaItemObject *mediaItem = (MediaItemObject *)sender;
        
        OOAPI *api = [[OOAPI alloc] init];
        [api getRestaurantImageWithMediaItem:mediaItem maxWidth:200 maxHeight:0 success:^(NSString *link) {
            [weakSelf.restaurantImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                            placeholderImage:nil
                                                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             weakSelf.restaurantImage.image = image;
                                                             [weakSelf.restaurantImage setAlpha:1.0];
                                                             weakSelf.restaurantImage.hidden = NO;
                                                             [weakSelf.view setNeedsUpdateConstraints];
                                                         });
                                                     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             
                                                         });
                                                     }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }];
    }
}

@end

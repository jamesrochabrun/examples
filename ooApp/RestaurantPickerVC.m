//
//  RestaurantPickerVC.m
//  ooApp
//
//  Created by Anuj Gujar on 12/20/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantPickerVC.h"
#import "OOAPI.h"
#import "LocationManager.h"
#import "DebugUtilities.h"
#import "NavTitleObject.h"
#import "iRate.h"

@interface RestaurantPickerVC ()
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) NSArray *searchRestaurants;
@property (nonatomic, strong) NSArray *nearbyRestaurants;
@property (nonatomic, strong) NSArray *autoCompleteRestaurants;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchBar *locationSearchBar;
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) UISearchBar *currentSearchBar;
@property (nonatomic) CLLocationCoordinate2D selectedLocation;
@end

@implementation RestaurantPickerVC

static NSString * const cellIdentifier = @"restaurantPickerCell";

- (instancetype)init {
    self = [super init];
    if (self) {
        _iv = [[UIImageView alloc] init];
        _iv.translatesAutoresizingMaskIntoConstraints = NO;
        _iv.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        _iv.contentMode = UIViewContentModeScaleAspectFill;
        _iv.alpha = 1;
                
        _tableView = [[UITableView alloc] init];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        _tableView.backgroundColor = UIColorRGBA(kColorDarkImageOverlay);
        _tableView.rowHeight = 44;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
//        _tableView.layer.borderColor = UIColorRGBA(kColorOffBlack).CGColor;
//        _tableView.layer.borderWidth = 1;
        
        _nto = [[NavTitleObject alloc] initWithHeader:@"Place" subHeader:@"Where did you take the photo?"];
        
        _searchBar = [[UISearchBar alloc] init];
        //_searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.placeholder = LOCAL(@"Search for the restaurant, bar, etc");
        _searchBar.backgroundColor = UIColorRGBA(kColorNavBar);
        _searchBar.barTintColor = UIColorRGBA(kColorNavBar);
        _searchBar.keyboardType = UIKeyboardTypeAlphabet;
        _searchBar.delegate = self;
        _searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
        _searchBar.keyboardType = UIKeyboardTypeAlphabet;
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;

        _locationSearchBar = [[UISearchBar alloc] init];
        //_locationSearchBar.searchBarStyle = UISearchBarStyleMinimal;
        _locationSearchBar.placeholder = LOCAL( @"Around Here");
        _locationSearchBar.backgroundColor = UIColorRGBA(kColorNavBar);
        _locationSearchBar.barTintColor = UIColorRGBA(kColorNavBar);
        UILabel *l = [UILabel new];
        [l withFont:[UIFont fontWithName:kFontIcons size:kGeomIconSize] textColor:kColorText backgroundColor:kColorClear];
        l.text = kFontIconLocation;
        [l sizeToFit];
        [_locationSearchBar setImage:[UIImage imageFromView:l] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        _locationSearchBar.delegate = self;
        _locationSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
        _locationSearchBar.keyboardType = UIKeyboardTypeAlphabet;
        _locationSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _locationSearchBar.translatesAutoresizingMaskIntoConstraints = NO;
                
        _currentSearchBar = _searchBar;
        
        self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self removeNavButtonForSide:kNavBarSideTypeRight];
    [self addNavButtonWithIcon:kFontIconRemove target:self action:@selector(pickerCanceled) forSide:kNavBarSideTypeRight isCTA:NO];

    [self.view addSubview:_iv];
    [self.view addSubview:_tableView];
    [self.view addSubview:_searchBar];
    [self.view addSubview:_locationSearchBar];
    [self.view sendSubviewToBack:_iv];
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    
    self.navTitle = _nto;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN(@(object_getClassName(self)));
}

- (void)searchLocations {
//    __weak  RestaurantPickerVC *weakSelf = self;
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    CLRegion *region = [[CLRegion alloc] init];


    [geocoder geocodeAddressString:_locationSearchBar.text inRegion:region
                 completionHandler:^(NSArray* placemarks, NSError* error) {
                     _locations = placemarks;
                     if (![_locations count]) {
                         NSLog(@"Could find a location that matched: %@", _locationSearchBar.text);
                     } else {
                         NSLog(@"Found %lu locations that matched: %@", (unsigned long)[_locations count], _locationSearchBar.text);
                         for (CLPlacemark *pm in placemarks) {
                             NSLog(@"placemark name: %@", pm.addressDictionary);
                         }
                        
                     }
                     [_tableView reloadData];
                 }];
}

- (void)cancelSearch {
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    _restaurants = _nearbyRestaurants;
    [_tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _currentSearchBar = searchBar;
    if (searchBar == _searchBar) {
//        _searchRestaurants = nil;
//        _restaurants = _searchRestaurants;
//        [_tableView reloadData];
        
        if (_locations && [_locations count] == 1) {
            CLPlacemark *placemark = (CLPlacemark *)[_locations objectAtIndex:0];
            _locationSearchBar.text = [Common locationString:placemark];
            _selectedLocation = placemark.location.coordinate;
            //if ([searchBar.text length]) {
                [self searchForRestaurants];
            //}
        }
    } else if (searchBar == _locationSearchBar) {
        _locations = nil;
        [self searchLocations];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar == _searchBar) {
        if ([searchText length] > 0) {
            _restaurants = _searchRestaurants;
            [self searchForRestaurants];
        } else if ([searchText length] == 0) {
            _restaurants = _nearbyRestaurants;
            [_tableView reloadData];
        }
    } else if (searchBar == _locationSearchBar) {
        if ([searchText length] > 0) {
            [self searchLocations];
        } else if ([searchText length] == 0) {
            _selectedLocation = _location;
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
}

- (void)setLocation:(CLLocationCoordinate2D)location {
    _location = location;
    _selectedLocation = location;
    
    [self getNearbyRestaurants];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2), @"mapWidth" : @(width(self.view)), @"buttonWidth" : @(kGeomWidthButton), @"buttonHeight" : @(kGeomHeightButton)};
    
    NSDictionary *views;

    views = NSDictionaryOfVariableBindings(_tableView, _iv, _searchBar, _locationSearchBar);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_searchBar]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_locationSearchBar]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_searchBar(buttonHeight)][_locationSearchBar(buttonHeight)][_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_iv]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_locationSearchBar][_iv]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    }

- (void)getNearbyRestaurants {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantPickerVC *weakSelf = self;
    _requestOperation = [api getRestaurantsWithKeywords:[NSMutableArray arrayWithArray:@[]]
                                            andLocation: _location
                                              andFilter:@""
                                              andRadius:20
                                            andOpenOnly:NO
                                                andSort:kSearchSortTypeDistance
                                               minPrice:0
                                               maxPrice:0
                                                 isPlay:NO
                                                success:^(NSArray *r) {
                                                    _nearbyRestaurants = r;
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [weakSelf gotNearbyRestaurants];
                                                    });
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
                                                    ;
                                                }];
}

- (void)gotNearbyRestaurants {
    _restaurants = _nearbyRestaurants;
    [self.tableView reloadData];
}

- (void)searchForRestaurants {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantPickerVC *weakSelf = self;
    _requestOperation = [api getRestaurantsWithKeywords:@[_searchBar.text]
                                            andLocation:_selectedLocation
                                              andFilter:@""
                                              andRadius:kMaxSearchRadius
                                            andOpenOnly:NO
                                                andSort:kSearchSortTypeDistance
                                               minPrice:0
                                               maxPrice:0
                                                 isPlay:NO
                                                success:^(NSArray *r) {
                                                    _searchRestaurants = r;
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [weakSelf gotRestaurantsFromSearch];
                                                    });
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
                                                    ;
                                                }];
}

- (void)gotRestaurantsFromSearch {
    _restaurants = _searchRestaurants;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImageToUpload:(UIImage *)imageToUpload {
    if (_imageToUpload == imageToUpload) return;
    _imageToUpload = imageToUpload;
    _iv.image = _imageToUpload;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_currentSearchBar == _searchBar) {
        return [_restaurants count];
    } else if (_currentSearchBar == _locationSearchBar) {
        return [_locations count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.textLabel setTextColor:UIColorRGBA(kColorText)];
    [cell.detailTextLabel setTextColor:UIColorRGBA(kColorText)];
    cell.backgroundColor = UIColorRGBA(kColorClear);
    cell.textLabel.backgroundColor = UIColorRGBA(kColorClear);
    [cell.textLabel setFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4]];

    if (_currentSearchBar == _searchBar) {
        RestaurantObject *r = [_restaurants objectAtIndex:indexPath.row];
        // Configure the cell...
        CLLocation *l1 = [[CLLocation alloc] initWithLatitude:_selectedLocation.latitude longitude:_selectedLocation.longitude];
        CLLocation *l2 = [[CLLocation alloc] initWithLatitude:r.location.latitude longitude:r.location.longitude];
        CLLocationDistance distanceInMeters = [l1 distanceFromLocation:l2];

        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %0.1f mi.", r.name, metersToMiles(distanceInMeters)];
        cell.textLabel.numberOfLines = 1;
    } else if (_currentSearchBar == _locationSearchBar) {
        CLPlacemark *placemark = [_locations objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.text = [Common locationString:placemark];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_currentSearchBar == _searchBar) {
        RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
        [_delegate restaurantPickerVC:self restaurantSelected:restaurant];
        [[iRate sharedInstance] logEvent:YES];
    } else if (_currentSearchBar == _locationSearchBar) {
        CLPlacemark *placemark = [_locations objectAtIndex:indexPath.row];
        _locationSearchBar.text = [Common locationString:placemark];
        _selectedLocation = placemark.location.coordinate;
        if ([_searchBar.text length] > 3) {
            [_searchBar becomeFirstResponder];
        }
    }
}

- (void)pickerCanceled {
    [_searchBar resignFirstResponder];
    [_delegate restaurantPickerVCCanceled:self];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

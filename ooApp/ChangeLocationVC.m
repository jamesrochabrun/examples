//
//  ChangeLocationVC.m
//  ooApp
//
//  Created by Anuj Gujar on 2/5/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ChangeLocationVC.h"

@interface ChangeLocationVC ()
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchBar *locationSearchBar;
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic) CLLocationCoordinate2D selectedLocation;
@end

static NSString * const cellIdentifier = @"locationCell";

@implementation ChangeLocationVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _iv = [[UIImageView alloc] init];
        _iv.translatesAutoresizingMaskIntoConstraints = NO;
        _iv.backgroundColor = UIColorRGBA(kColorClear);
        _iv.contentMode = UIViewContentModeScaleAspectFill;
        _iv.alpha = 0.20;
        
        _tableView = [[UITableView alloc] init];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        _tableView.backgroundColor = UIColorRGBA(kColorOverlay20);
        _tableView.rowHeight = 44;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.layer.borderColor = UIColorRGBA(kColorOffBlack).CGColor;
        _tableView.layer.borderWidth = 1;
        
        _nto = [[NavTitleObject alloc] initWithHeader:@"Change Location" subHeader:@"Enter a ZIP Code, City or Address"];
        
        _locationSearchBar = [[UISearchBar alloc] init];
        _locationSearchBar.searchBarStyle = UISearchBarStyleMinimal;
        _locationSearchBar.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        _locationSearchBar.placeholder = LOCAL( @"Current Location");
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:UIColorRGBA(kColorWhite)}];
        _locationSearchBar.barTintColor = UIColorRGBA(kColorBlack);
        _locationSearchBar.keyboardType = UIKeyboardTypeAlphabet;
        _locationSearchBar.delegate = self;
        _locationSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
        _locationSearchBar.keyboardType = UIKeyboardTypeAlphabet;
        _locationSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _locationSearchBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [self setRightNavWithIcon:kFontIconRemove target:self action:@selector(pickerCanceled)];
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_locationSearchBar];
    
    self.navTitle = _nto;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchLocations {
    __weak  ChangeLocationVC *weakSelf = self;
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
                     [_tableView reloadData];
                 }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _locations = nil;
    [self searchLocations];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        _selectedLocation = _location;
    } else {
        [self searchLocations];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
}

- (void)setLocation:(CLLocationCoordinate2D)location {
    _location = location;
    _selectedLocation = location;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2), @"mapWidth" : @(width(self.view))};
    
    NSDictionary *views;
    
    views = NSDictionaryOfVariableBindings(_tableView, _iv, _locationSearchBar);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_locationSearchBar]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_locationSearchBar(40)][_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.textLabel setTextColor:UIColorRGBA(kColorWhite)];
    [cell.detailTextLabel setTextColor:UIColorRGBA(kColorWhite)];
    cell.backgroundColor = UIColorRGBA(kColorClear);
    cell.textLabel.backgroundColor = UIColorRGBA(kColorClear);
    [cell.textLabel setFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH3]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4]];
    cell.textLabel.numberOfLines = 2;
    CLPlacemark *placemark = [_locations objectAtIndex:indexPath.row];
    cell.textLabel.text = [Common locationString:placemark];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLPlacemark *placemark = [_locations objectAtIndex:indexPath.row];
    _locationSearchBar.text = [Common locationString:placemark];
    _selectedLocation = placemark.location.coordinate;
    [_delegate changeLocationVC:self locationSelected:placemark];
}

- (void)pickerCanceled {
    [_locationSearchBar resignFirstResponder];
    [_delegate changeLocationVCCanceled:self];
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

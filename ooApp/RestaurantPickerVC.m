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

@interface RestaurantPickerVC ()
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *iv;
@end

@implementation RestaurantPickerVC

static NSString * const cellIdentifier = @"restaurantPickerCell";

- (instancetype)init {
    self = [super init];
    if (self) {
        _iv = [[UIImageView alloc] init];
        _iv.translatesAutoresizingMaskIntoConstraints = NO;
        _iv.backgroundColor = UIColorRGBA(kColorClear);
        _iv.contentMode = UIViewContentModeScaleAspectFill;
        _iv.alpha = 0.45;
        [self.view addSubview:_iv];
        
        _tableView = [[UITableView alloc] init];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        _tableView.backgroundColor = UIColorRGBA(kColorOverlay35);
        _tableView.rowHeight = 35;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        self.view.layer.cornerRadius = kGeomCornerRadius;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.layer.borderColor = UIColorRGBA(kColorOffBlack).CGColor;
        _tableView.layer.borderWidth = 1;
        [self.view addSubview:_tableView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setLocation:(CLLocationCoordinate2D)location {
    _location = location;
    [self getNearbyRestaurants];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2), @"mapWidth" : @(width(self.view))};
    
    NSDictionary *views;

    views = NSDictionaryOfVariableBindings(_tableView, _iv);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_tableView(270)]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_tableView(200)]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_iv]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_iv]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

- (void)getNearbyRestaurants {
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak RestaurantPickerVC *weakSelf = self;
    
    _requestOperation = [api getRestaurantsWithKeywords:[NSMutableArray arrayWithArray:@[]]
                                            andLocation:_location
                                              andFilter:@""
                                              andRadius:20
                                            andOpenOnly:NO
                                                andSort:kSearchSortTypeDistance
                                               minPrice:0
                                               maxPrice:0
                                                 isPlay:NO
                                                success:^(NSArray *r) {
                                                    _restaurants = r;
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [weakSelf gotRestaurants];
                                                    });
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
                                                    ;
                                                }];
}

- (void)gotRestaurants {
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
    return [_restaurants count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    RestaurantObject *r = [_restaurants objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = r.name;
    [cell.textLabel setTextColor:UIColorRGBA(kColorWhite)];
    cell.backgroundColor = UIColorRGBA(kColorClear);
    cell.textLabel.backgroundColor = UIColorRGBA(kColorClear);
    [cell.textLabel setFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
    [_delegate restaurantPickerVC:self restaurantSelected:restaurant];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Which restaurant";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = UIColorRGBA(kColorBlack);
    
    CGRect frame = header.frame;
    frame.size.width = width(tableView);
    header.frame = frame;
    
    UILabel *headerLabel = [[UILabel alloc] init];
    [headerLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2] textColor:kColorWhite backgroundColor:kColorClear];
    headerLabel.text = @"Where did you take this photo?";
    [headerLabel sizeToFit];
    frame = headerLabel.frame;
    frame.origin.x = 10;
    frame.origin.y = 0;//(height(header) - height(headerLabel))/2;
    frame.size.height = [self tableView:tableView heightForHeaderInSection:0];
    headerLabel.frame = frame;
    [header addSubview:headerLabel];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel withIcon:kFontIconRemove fontSize:kGeomIconSizeSmall width:30 height:30 backgroundColor:kColorClear target:self selector:@selector(pickerCanceled)];
    [cancel setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
    frame = cancel.frame;
    frame.size.height = [self tableView:tableView heightForHeaderInSection:0];
    frame.origin.y = 0;
    frame.origin.x = width(header) - width(cancel) - kGeomSpaceEdge;
    cancel.frame = frame;
    [header addSubview:cancel];
    
    return header;
}

- (void)pickerCanceled {
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

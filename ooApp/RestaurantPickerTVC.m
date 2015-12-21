//
//  RestaurantPickerTVC.m
//  ooApp
//
//  Created by Anuj Gujar on 12/20/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantPickerTVC.h"
#import "OOAPI.h"
#import "LocationManager.h"
#import "DebugUtilities.h"

@interface RestaurantPickerTVC ()
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) NSArray *restaurants;
@end

@implementation RestaurantPickerTVC

static NSString * const cellIdentifier = @"restaurantPickerCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView.rowHeight = 30;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.layer.cornerRadius = kGeomCornerRadius;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self getNearbyRestaurants];
}

- (void)getNearbyRestaurants {
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak RestaurantPickerTVC *weakSelf = self;
    
    _requestOperation = [api getRestaurantsWithKeywords:[NSMutableArray arrayWithArray:@[@"restaurant", @"bar"]]
                                            andLocation:[[LocationManager sharedInstance] currentUserLocation]
                                              andFilter:@""
                                              andRadius:20
                                            andOpenOnly:NO
                                                andSort:kSearchSortTypeDistance
                                               minPrice:0
                                               maxPrice:3
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
    [cell.textLabel setFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
    [_delegate restaurantPickerTVC:self restaurantSelected:restaurant];
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
    [headerLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeStripHeader] textColor:kColorWhite backgroundColor:kColorClear];
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
    [_delegate restaurantPickerTVCCanceled:self];
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

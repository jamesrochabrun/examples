//
//  WhatsNewVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "WhatsNewVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListStripTVCell.h"
#import "DebugUtilities.h"
#import "Settings.h"
#import "LocationManager.h"
#import "RestaurantListVC.h"
#import "UserObject.h"

@interface WhatsNewVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *lists;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@end

static NSString * const ListRowID = @"ListRowCell";
static NSString * const FeaturedRowID = @"FeaturedRowCell";

@implementation WhatsNewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColorRGBA(kColorClear);
    
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = UIColorRGBA(kColorClear);
    
    [_tableView registerClass:[ListStripTVCell class] forCellReuseIdentifier:ListRowID];
    [_tableView registerClass:[ListStripTVCell class] forCellReuseIdentifier:FeaturedRowID];
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"What's New" subHeader:nil];
    self.navTitle = nto;
    
    _lists = [NSMutableArray array];
    [self addLists];
}

- (void)addLists {

    ListObject *list;
    list = [[ListObject alloc] init];
    list.name = @"Party";
    list.listDisplayType = kListDisplayTypeFeatured;
    [_lists addObject:list];
    
//    list = [[ListObject alloc] init];
//    list.name = @"Trending";
//    list.type = kListTypeTrending;
//    list.listDisplayType = KListDisplayTypeStrip;
//    [_lists addObject:list];
//    
//    list = [[ListObject alloc] init];
//    list.name = @"Popular";
//    list.type = kListTypePopular;
//    list.listDisplayType = KListDisplayTypeStrip;
//    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Thai";
    list.listDisplayType = KListDisplayTypeStrip;
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Vegetarian";
    list.listDisplayType = KListDisplayTypeStrip;
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Delivery";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Mediterranean";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Steak";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Indian";
    [_lists addObject:list];
    
    [_tableView reloadData];
}

- (void)locationBecameAvailable:(id)notification
{
    NSLog (@"LOCATION BECAME AVAILABLE FROM iOS");
    __weak  WhatsNewVC *weakSelf = self;
    ON_MAIN_THREAD(^{
        [weakSelf.tableView  reloadData];
    });
}

- (void)locationBecameUnavailable:(id)notification
{
    NSLog  (@"LOCATION IS NOT AVAILABLE FROM iOS");
    __weak  WhatsNewVC *weakSelf = self;
    ON_MAIN_THREAD(^{
        [weakSelf.tableView  reloadData];
    });
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
//    [super layout];
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
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
    
    [[LocationManager sharedInstance] askUserWhetherToTrack];

}

- (void)viewWillDisappear :(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self verifyTrackingIsOkay];
}

- (void)verifyTrackingIsOkay
{
    if (0 == self.currentLocation.longitude) {
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma table view delegates/datasources
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListObject *list = [_lists objectAtIndex:indexPath.row];
    
    ListStripTVCell *cell;
    
    if (list.listDisplayType == kListDisplayTypeFeatured) {
        cell = [tableView dequeueReusableCellWithIdentifier:FeaturedRowID forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:ListRowID forIndexPath:indexPath];
    }
    
    cell.navigationController = self.navigationController;
    cell.listItem = list;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    ListObject *lo = [_lists objectAtIndex:indexPath.row];
    
    if (lo.listDisplayType == kListDisplayTypeFeatured) {
        height = kGeomHeightFeaturedRow;
    } else {
        height = kGeomHeightStripListRow;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListObject *item = [_lists objectAtIndex:indexPath.row];
    
    RestaurantListVC *vc = [[RestaurantListVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = item.name;
    vc.listItem = item;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lists count];
}

@end

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
    
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[ListStripTVCell class] forCellReuseIdentifier:ListRowID];
    [_tableView registerClass:[ListStripTVCell class] forCellReuseIdentifier:FeaturedRowID];
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"What's New" subHeader:@"what"];
    self.navTitle = nto;
    
    _lists = [NSMutableArray array];
    ListObject *list;
    
    list = [[ListObject alloc] init];
    list.name = @"Drinks";
    list.listDisplayType = kListDisplayTypeFeatured;
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Thai";
    list.listDisplayType = KListDisplayTypeStrip;
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Chinese";
    list.listDisplayType = KListDisplayTypeStrip;
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Vegetarian";
    list.listDisplayType = kListDisplayTypeFeatured;
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Burgers";
    list.listDisplayType = KListDisplayTypeStrip;
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Vietnamese";
    list.listDisplayType = KListDisplayTypeStrip;
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"New";
    list.listDisplayType = kListDisplayTypeFeatured;
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Mexican";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Peruvian";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Delivery";
    [_lists addObject:list];
    
    list = [[ListObject alloc] init];
    list.name = @"Party";
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
    
    list = [[ListObject alloc] init];
    list.name = @"Tandoor";
    [_lists addObject:list];
}

-(void)layout {
    [super layout];
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)viewWillAppear:(BOOL)animated
{
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

//
//  FeedVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "FeedVC.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "EventTVCell.h"

@interface FeedVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *feedItems;

@end

static NSString * const FeedCellID = @"FeedCell";

@implementation FeedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[EventTVCell class] forCellReuseIdentifier:FeedCellID];
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Feed" subHeader:@"me"];
    self.navTitle = nto;
    [self getEvents];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEvents {
    __weak FeedVC *weakSelf = self;
    [OOAPI getFeed:^(NSArray *feedItems) {
        weakSelf.feedItems = feedItems;
        ON_MAIN_THREAD(^ {
            [weakSelf.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         ;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_feedItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTVCell *cell = (EventTVCell*)[tableView dequeueReusableCellWithIdentifier:FeedCellID forIndexPath:indexPath];
    EventObject *eo = [_feedItems objectAtIndex:indexPath.row];
    [cell setEvent:eo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kGeomHeightEventWhoTableCellHeight;
}



@end

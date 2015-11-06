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

@interface FeedVC ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FeedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Feed" subHeader:@"me"];
    self.navTitle = nto;
    [self getEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEvents {
    [OOAPI getFeed:^(NSArray *feedItems) {
        ;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
        
    }];
    
}

@end

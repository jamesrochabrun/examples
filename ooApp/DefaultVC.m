//
//  DefaultVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "TimeUtilities.h"

@interface DefaultVC ()

@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DefaultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
        
    UILabel *l;
    NSInteger fontSize = 9;
    
    for (int i=0; i<7;i++) {
        l = [[UILabel alloc] initWithFrame:CGRectMake(20, 70+i*20, width(self.view), 20)];
        [l withFont:[UIFont fontWithName:kFontLatoRegular size:fontSize+i] textColor:kColorWhite backgroundColor:kColorBlack];
        l.text = [NSString stringWithFormat:@"Oomami...font size %ld, %@",(long) fontSize+i, l.font.fontName] ;
        [self.view addSubview:l];
    }
    
    l = [[UILabel alloc] initWithFrame:CGRectMake(kGeomSpaceIcon, 40+9*20, width(self.view), 45)];
    l.font = [UIFont fontWithName:kFontIcons size:45];
    l.backgroundColor = UIColorRGBA(kColorBlack);
    l.textColor = UIColorRGBA(kColorWhite);
    l.text = [NSString stringWithFormat:@"abcdefghi"] ;
    [self.view addSubview:l];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

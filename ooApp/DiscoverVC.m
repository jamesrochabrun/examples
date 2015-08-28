//
//  DiscoverVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "DiscoverVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"

@interface DiscoverVC ()

@property (nonatomic, strong) NSArray *restaurants;


@end

@implementation DiscoverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
        
    UILabel *l;
    NSInteger fontSize = 9;
    
    for (int i=0; i<7;i++) {
        l = [[UILabel alloc] initWithFrame:CGRectMake(20, 70+i*20, width(self.view), 20)];
        [l withFont:[UIFont fontWithName:kFontLatoRegular size:fontSize+i] textColor:kColorWhite backgroundColor:kColorBlack];
        l.text = [NSString stringWithFormat:@"Oomami...font size %ld, %@", fontSize+i, l.font.fontName] ;
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
    [self testAPI];
}

- (void)testAPI {
    OOAPI *api = [[OOAPI alloc] init];
    
    [api getRestaurantsWithIDs:nil success:^(NSArray *r) {
        _restaurants = r;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self printRestaurants];
        });
    } failure:^(NSError *err) {
        ;
    }];
    
    [api getUsersWithIDs:nil success:^(NSArray *r) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [r enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UserObject *user =  (UserObject *)obj;
                NSLog(@"id = %@ user = %@ %@ email=%@", user.userID, user.firstName, user.lastName, user.email);
            }];
        });
    } failure:^(NSError *err) {
        ;
    }];
    
    [api getDishesWithIDs:nil success:^(NSArray *r) {
        
    } failure:^(NSError *err) {
        ;
    }];
    
    RestaurantObject *restaurant = [[RestaurantObject alloc] init];
    restaurant.name = @"Papalote";
    //    [api addRestaurant:restaurant success:^(NSArray *dishes) {
    //        ;
    //    } failure:^(NSError *error) {
    //        ;
    //    }];
}

- (void)printRestaurants {
    [_restaurants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"rest name = %@",  (RestaurantObject *)obj);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

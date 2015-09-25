//
//  RestaurantVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/14/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantVC.h"

@interface RestaurantVC ()

@end

@implementation RestaurantVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:restaurant.name subHeader:nil];
    self.navTitle = nto;
}

- (void)getRestaurant {
    
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

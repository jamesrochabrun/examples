//
//  RestaurantVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/14/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantVC.h"
#import "OOAPI.h"

@interface RestaurantVC ()

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation RestaurantVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColorRGBA(kColorWhite);
    
    _alertController = [UIAlertController alertControllerWithTitle:@"Restaurant Options"
                                                                   message:@"What would you like to do with this restaurant."
                                                        preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"Add to Favorites"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              NSLog(@"You pressed button one");
                                                              [self addToFavorites];
                                                          }]; // 2
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"Add to List"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed button two");
                                                           }]; // 3
    UIAlertAction *a3 = [UIAlertAction actionWithTitle:@"Add to Event"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed button two");
                                                           }]; // 3
    UIAlertAction *a4 = [UIAlertAction actionWithTitle:@"New Event at..."
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              NSLog(@"You pressed button two");
                                                          }]; // 3
    UIAlertAction *a5 = [UIAlertAction actionWithTitle:@"New List..."
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              NSLog(@"You pressed button two");
                                                          }]; // 3
    
    [_alertController addAction:a1];
    [_alertController addAction:a2];
    [_alertController addAction:a3];
    [_alertController addAction:a4];
    [_alertController addAction:a5];
    
    [self.moreButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)moreButtonPressed:(id)sender {
    [self presentViewController:_alertController animated:YES completion:nil]; // 6
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
    
    [self getRestaurant];
}

- (void)getRestaurant {
    OOAPI *api = [[OOAPI alloc] init];
    [api getRestaurantsWithID:_restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
        _restaurant = restaurant;
    } failure:^(NSError *error) {
        ;
    }];
    
}

- (void)addToFavorites {
    OOAPI *api = [[OOAPI alloc] init];
    [api addRestaurantsToFavorites:@[_restaurant] success:^(id response) {
        ;
    } failure:^(NSError *error) {
        ;
    }];
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

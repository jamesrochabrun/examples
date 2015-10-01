//
//  RestaurantVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/14/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "Settings.h"
#import "OORemoveButton.h"

@interface RestaurantVC ()

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSArray *lists;
@property (nonatomic, strong) UserObject* userInfo;
@property (nonatomic, strong) NSMutableArray *removeButtons;

@end

@implementation RestaurantVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userInfo= [Settings sharedInstance].userObject;
    
    self.view.backgroundColor = UIColorRGBA(kColorWhite);
    
    _alertController = [UIAlertController alertControllerWithTitle:@"Restaurant Options"
                                                                   message:@"What would you like to do with this restaurant."
                                                        preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    _alertController.view.tintColor = [UIColor blackColor];
    
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
    
    _removeButtons = [NSMutableArray array];
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
    __weak RestaurantVC *weakSelf= self;
    OOAPI *api = [[OOAPI alloc] init];
    [api getRestaurantWithID:_restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
        _restaurant = restaurant;
        [weakSelf getListsForRestaurant];
    } failure:^(NSError *error) {
        ;
    }];
}

- (void)getListsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    [api getListsOfUser:[_userInfo.userID integerValue] withRestaurant:[_restaurant.restaurantID integerValue]
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user:  %ld", ( long) foundLists.count);
                    _lists = foundLists;
                    [_removeButtons removeAllObjects];
                    [_lists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        ListObject *lo = (ListObject *)obj;
                        OORemoveButton *b = [[OORemoveButton alloc] init];
                        b.name.text = lo.name;
                        b.identifier = [lo.listID integerValue];
                        [b addTarget:self action:@selector(removeFromList:) forControlEvents:UIControlEventTouchUpInside];
                        [b setNeedsLayout];
                        [_removeButtons addObject:b];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf displayRemoveButtons];
                            });
                    }];
                }
                failure:^(NSError *e) {
                    NSLog  (@" error while getting lists for user:  %@",e);
                }];
}

- (void)displayRemoveButtons {
    [_removeButtons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OORemoveButton *b = (OORemoveButton *)obj;
        CGRect frame = b.frame;
        frame.size = [b getSuggestedSize];
        frame.origin.x = 10;
        frame.origin.y = 10;
        b.frame = frame;
        [self.view addSubview:b];
    }];
}

- (void)removeFromList:(id)sender {
    OORemoveButton  *b = (OORemoveButton *)sender;
    OOAPI *api = [[OOAPI alloc] init];
    [api deleteRestaurant:[_restaurant.restaurantID integerValue] fromList:b.identifier success:^(NSArray *lists) {
        ;
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

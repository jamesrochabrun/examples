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
#import "ListsVC.h"

@interface RestaurantVC ()

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSArray *lists;
@property (nonatomic, strong) UserObject* userInfo;
@property (nonatomic, strong) NSMutableSet *removeButtons;

@end

@implementation RestaurantVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userInfo= [Settings sharedInstance].userObject;
    
    self.view.backgroundColor = UIColorRGBA(kColorWhite);
    
    [self setupAlertController];
    
    _removeButtons = [NSMutableSet set];
}

- (void)setupAlertController {
    _alertController = [UIAlertController alertControllerWithTitle:@"Restaurant Options"
                                                           message:@"What would you like to do with this restaurant."
                                                    preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    _alertController.view.tintColor = [UIColor blackColor];
    
    UIAlertAction *addToFavorites = [UIAlertAction actionWithTitle:@"Add to Favorites"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [self addToFavorites];
                                                 }];
    
    UIAlertAction *addToList = [UIAlertAction actionWithTitle:@"Add to List"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [self showLists];
                                                 }];
    UIAlertAction *addToEvent = [UIAlertAction actionWithTitle:@"Add to Event"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSLog(@"Add to Event");
                                                 }];
    UIAlertAction *addToNewEvent = [UIAlertAction actionWithTitle:@"New Event at..."
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSLog(@"Add to New Event");
                                                 }]; // 3
    UIAlertAction *addToNewList = [UIAlertAction actionWithTitle:@"New List..."
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSLog(@"Add the NewList");
                                                 }]; // 3
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                 style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                     NSLog(@"Cancel");
                                                 }]; // 3
    
    
    [_alertController addAction:addToFavorites];
    [_alertController addAction:addToList];
    [_alertController addAction:addToNewList];
    [_alertController addAction:addToEvent];
    [_alertController addAction:addToNewEvent];
    [_alertController addAction:cancel];
    
    
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
    __weak RestaurantVC *weakSelf= self;
    OOAPI *api = [[OOAPI alloc] init];
    [api getRestaurantWithID:_restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
        _restaurant = restaurant;
        [weakSelf getListsForRestaurant];
        [weakSelf getMediaItemsForRestaurant];
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

- (void)getMediaItemsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    [api getMediaItemsForRestaurant:_restaurant success:^(NSArray *mediaItems) {
        ;
    } failure:^(NSError *error) {
        ;
    }];

}

- (void)displayRemoveButtons {
    __block CGPoint origin = CGPointMake(kGeomSpaceEdge, kGeomSpaceEdge);
    NSArray *removeButtons = [_removeButtons allObjects];
    [removeButtons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OORemoveButton *b = (OORemoveButton *)obj;
        CGRect frame = b.frame;
        frame.size = [b getSuggestedSize];
        frame.origin.x = origin.x;
        frame.origin.y = origin.y;
        
        if (CGRectGetMaxX(frame) > (CGRectGetMaxX(self.view.frame)-kGeomSpaceEdge)) {
            frame.origin.y = origin.y = CGRectGetMaxY(frame) + kGeomSpaceEdge;
            frame.origin.x = kGeomSpaceEdge;
        }

        b.frame = frame;
        
        origin.x = CGRectGetMaxX(frame) + kGeomSpaceEdge;

        [self.view addSubview:b];
    }];
}

- (void)removeFromList:(id)sender {
    OORemoveButton  *b = (OORemoveButton *)sender;
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak RestaurantVC *weakSelf = self;
    [api deleteRestaurant:[_restaurant.restaurantID integerValue] fromList:b.identifier success:^(NSArray *lists) {
        ON_MAIN_THREAD(^{
            [b removeFromSuperview];
            [_removeButtons removeObject:b];
            [weakSelf getListsForRestaurant];
        });
        
    } failure:^(NSError *error) {
        ;
    }];
}

- (void)addToFavorites {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    
    [api addRestaurantsToFavorites:@[_restaurant] success:^(id response) {
        [weakSelf getListsForRestaurant];
    } failure:^(NSError *error) {
        ;
    }];
}

- (void)showLists {
    ListsVC *vc = [[ListsVC alloc] init];
    vc.restaurant = _restaurant;
    [vc getLists];
    [self.navigationController pushViewController:vc animated:YES];
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

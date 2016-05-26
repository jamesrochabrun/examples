//
//  RestaurantListVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantListVC.h"
#import "RestaurantTVCell.h"
#import "RestaurantObject.h"
#import "OOAPI.h"
#import "LocationManager.h"
#import "UIImageView+AFNetworking.h"
#import "ListObject.h"
#import "RestaurantVC.h"
#import "ListsVC.h"
#import "SearchVC.h"
#import "OOFeedbackView.h"

@interface RestaurantListVC ()

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UIAlertController *editListNameAC;
@property (nonatomic, strong) OOFeedbackView *fv;

@end

static NSString * const cellIdentifier = @"horizontalCell";

@implementation RestaurantListVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self removeNavButtonForSide:kNavBarSideTypeLeft];
    [self addNavButtonWithIcon:kFontIconBack target:self action:@selector(done:) forSide:kNavBarSideTypeLeft isCTA:NO];

    [self.view bringSubviewToFront:_fv];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _fv = [[OOFeedbackView alloc] initWithFrame:CGRectMake(0, 0, 110, 90) andMessage:@"oy vey" andIcon:kFontIconCheckmark];
    _fv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_fv];
    
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [_tableView registerClass:[RestaurantTVCell class] forCellReuseIdentifier:cellIdentifier];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.rowHeight = kGeomHeightHorizontalListRow;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.layoutMargins = UIEdgeInsetsZero;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self registerForNotification: kNotificationListAltered
                          calling:@selector(handleListAltered:)
     ];
    
    _requestOperation = nil;
    
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;
    
    if (_listItem.type == kListTypeUser &&
        [_listItem isListOwner:userID]) {
        [self setupAlertController];

        [self removeNavButtonForSide:kNavBarSideTypeRight];
        [self addNavButtonWithIcon:kFontIconMoreSolid target:self action:@selector(moreButtonPressed:) forSide:kNavBarSideTypeRight isCTA:NO];
    } else {
        [self removeNavButtonForSide:kNavBarSideTypeRight];
        [self addNavButtonWithIcon:@"" target:nil action:nil forSide:kNavBarSideTypeRight isCTA:NO];
    }
    self.tableView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [self setupEditListAC];
}

- (void)setupEditListAC {
    _editListNameAC = [UIAlertController alertControllerWithTitle:@"Edit List Name"
                                                        message:nil
                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    __weak RestaurantListVC *weakSelf = self;
    [_editListNameAC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter new list name";
        textField.text = weakSelf.listItem.name;
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Modify"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSString *name = [_editListNameAC.textFields[0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                     
                                                     if ([name length]) {
                                                         [weakSelf updateList:name];
                                                     } else {
                                                         _editListNameAC.textFields[0].text = weakSelf.listItem.name;
                                                         _fv.icon = kFontIconRemove;
                                                         _fv.message = [NSString stringWithFormat:@"Could not change list name"];
                                                         [_fv show];
                                                     }
                                                 }];
    
    [_editListNameAC addAction:cancel];
    [_editListNameAC addAction:ok];
}

- (void)updateList:(NSString *)name {
    _listItem.name = name;
    __weak RestaurantListVC *weakSelf = self;
    
    [OOAPI updateList:_listItem success:^(ListObject *listObject) {
        NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:listObject.listName subHeader:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.navTitle = nto;
            _fv.icon = kFontIconCheckmark;
            _fv.message = [NSString stringWithFormat:@"Modified list name"];
            [_fv show];
            NOTIFY_WITH(kNotificationListAltered, listObject);
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _fv.icon = kFontIconRemove;
            _fv.message = [NSString stringWithFormat:@"Could not change list name"];
            [_fv show];
        });
    }];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};

    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView, _fv);

    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_fv(110)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_fv(90)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_fv attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:1]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_fv attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:1]];
}

- (void)setupAlertController {
    _alertController = [UIAlertController alertControllerWithTitle:@"List Options"
                                                           message:@"What would you like to do with this list."
                                                    preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    _alertController.view.tintColor = UIColorRGBA(kColorBlack);

    __weak  RestaurantListVC *weakSelf = self;
    UIAlertAction *addRestaurantsFromExplore = [UIAlertAction actionWithTitle:@"Add Restaurants from Search"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           [weakSelf addRestaurantsFromExplore];
                                                                       }];

//remove for now...this seems like a corner case when one wants to manage lists
//    UIAlertAction *addRestaurantsFromList = [UIAlertAction actionWithTitle:@"Add Restaurants from List"
//                                                                     style:UIAlertActionStyleDefault
//                                                                   handler:^(UIAlertAction * action) {
//                                                                       [weakSelf addRestaurantsFromList];
//                                                                   }];

    UIAlertAction *editName = [UIAlertAction actionWithTitle:@"Edit Name"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [weakSelf presentViewController:weakSelf.editListNameAC animated:YES completion:nil];
                                                       }];

    UIAlertAction *deleteList = [UIAlertAction actionWithTitle:@"Delete List"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * action) {
                                                           [weakSelf deleteList];
                                                       }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style: UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                         NSLog(@"Cancel");
                                                     }]; // 3
    

    [_alertController addAction:editName];
    [_alertController addAction:addRestaurantsFromExplore];
//    [_alertController addAction:addRestaurantsFromList];
    [_alertController addAction:deleteList];
    [_alertController addAction:cancel];
    
 //   [self.moreButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)moreButtonPressed:(id)sender {
    
    _alertController.popoverPresentationController.sourceView = sender;
    _alertController.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;

    [self presentViewController:_alertController animated:YES completion:nil]; // 6
}

//------------------------------------------------------------------------------
// Name:    handleListAltered
// Purpose: If one of our list objects was deleted then update our UI.
//------------------------------------------------------------------------------
- (void)handleListAltered: (NSNotification*)not
{
    id object = not.object;
    if ([object isKindOfClass:[ListObject class]]) {
        ListObject *l = (ListObject *)object;
        if (l.listID ==_listItem.listID ) {
            NSLog (@"LIST ALTERED");
            [self fetchRestaurants];
        }
    }
}

- (void)deleteList
{
    __weak  RestaurantListVC *weakSelf = self;
    OOAPI *api = [[OOAPI alloc] init];
    [api deleteList:_listItem.listID success:^(NSArray *lists) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
            NOTIFY_WITH(kNotificationListDeleted, _listItem);
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)addRestaurantsFromExplore {
    SearchVC *vc = [[SearchVC alloc] init];
    vc.listToAddTo = _listItem;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addRestaurantsFromList {
    ListsVC *vc = [[ListsVC alloc] init];
    [vc getLists];
    vc.listToAddTo = _listItem;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fetchRestaurants
{
    if (_listItem) {
        [self getRestaurants];
    }
    
}

- (void)setListItem:(ListObject *)listItem {
    if (_listItem == listItem) return;
    _listItem = listItem;

    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:listItem.listName subHeader:nil];
    self.navTitle = nto;
    
    [self.view bringSubviewToFront:self.aiv];
    self.aiv.message = @"loading";
    [self.aiv startAnimating];
    
    [self fetchRestaurants];
}

- (void)getRestaurants
{
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak RestaurantListVC *weakSelf = self;
    if (_listItem.type == kListTypeToTry ||
        _listItem.type == kListTypeFavorites ||
        _listItem.type == kListTypeYumList ||
        _listItem.type == kListTypePlaceIveBeen ||
        _listItem.type == kListTypeUser) {
        self.requestOperation = [api getRestaurantsWithListID:_listItem.listID
                                                  andLocation:[LocationManager sharedInstance].currentUserLocation
                                                      success:^(NSArray *r)
                                 {
                                     weakSelf.restaurants = r;
                                     weakSelf.listItem.venues= r.mutableCopy;
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [weakSelf gotRestaurants];
                                     });
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
                                     [self.aiv stopAnimating];
                                 }];
    } else if (_listItem.type == kListTypeTrending||
               _listItem.type == kListTypePopular) {
        
        self.requestOperation = [api getRestaurantsFromSystemList:_listItem.type success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            [self.aiv stopAnimating];
        }];
    } else {
        self.requestOperation = [api getRestaurantsWithKeywords:(_listItem.type == kListTypeJustForYou) ? @[@"restaurants"]: @[_listItem.name]
                                                   andLocation:[[LocationManager sharedInstance] currentUserLocation]
                                                     andFilter:@""
                                                    andRadius:7500
                                                   andOpenOnly:NO
                                                       andSort:kSearchSortTypeDistance
                                                       minPrice:0
                                                       maxPrice:3
                                                         isPlay:(_listItem.type == kListTypeJustForYou) ? YES : NO
                                                        success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            [self.aiv stopAnimating];
        }];
    }
}

- (void)gotRestaurants
{
    NSLog(@"%@: %lu", _listItem.name, (unsigned long)[_restaurants count]);
    [_tableView reloadData];
    [self.aiv stopAnimating];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_restaurants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantTVCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
    cell.useModalForListedVenues= YES;
    cell.restaurant = restaurant;
    //cell.listToAddTo= self.listItem;  WTF!
    cell.nc = self.navigationController;
    cell.eventBeingEdited=self.eventBeingEdited;
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
    
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    ANALYTICS_EVENT_UI(@"RestaurantVC-from-RestaurantListVC");
    vc.eventBeingEdited= self.eventBeingEdited;
    vc.listToAddTo= self.listItem;
    vc.restaurant = restaurant;
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_listItem.type == kListTypeUser &&
        [_listItem isListOwner:[Settings sharedInstance].userObject.userID]) {
        return YES;
    } else {
        return NO;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
        __weak RestaurantListVC *weakSelf = self;
        OOAPI *api = [[OOAPI alloc] init];
        
        [api deleteRestaurant:restaurant.restaurantID fromList:_listItem.listID
                      success:^(NSArray *lists) {
                          NOTIFY_WITH(kNotificationListAltered, _listItem);
                          [api getRestaurantsWithListID:_listItem.listID
                                            andLocation:[LocationManager sharedInstance].currentUserLocation
                                                success:^(NSArray *restaurants) {
                                                    _restaurants = restaurants;
                                                    weakSelf.listItem.venues = restaurants.mutableCopy;
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [weakSelf.tableView reloadData];
                                                    });
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    ;
                                                }];
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          ;
        }];
    }
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

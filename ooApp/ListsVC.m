//
//  ListsVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListsVC.h"
#import "RestaurantListVC.h"
#import "OOAPI.h"
#import "LocationManager.h"
#import "UIImageView+AFNetworking.h"
#import "ListObject.h"
#import "RestaurantListVC.h"

@interface ListsVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *lists;
@property (nonatomic, strong) NSArray *listsWithRestaurant;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) AFHTTPRequestOperation *operationToFetchAll;
@property (nonatomic, strong) AFHTTPRequestOperation *operationToAddAll;
@property (nonatomic, strong) UIButton *addToFavoritesButton;
@property (nonatomic, strong) UIButton *addToWishlistButton;
@property (nonatomic, strong) UIButton *createListButton;
@property (nonatomic) NSUInteger favoritesListID;
@property (nonatomic) NSUInteger wishListID;
@property (nonatomic, strong) UIAlertController *createListAC;
@end

static NSString * const cellIdentifier = @"listCell";
static NSString * const buttonsCellIdentifier = @"buttonCell";

typedef enum {
    kListsVCSectionButtons = 0,
    kListsVCSectionLists = 1
} kListsVCSection;


@implementation ListsVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [_tableView registerClass:[ListTVCell class] forCellReuseIdentifier:cellIdentifier];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:buttonsCellIdentifier];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.layoutMargins = UIEdgeInsetsZero;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    _requestOperation = nil;
    _tableView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};

    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);

    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
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

- (void)getLists
{
    OOAPI *api = [[OOAPI alloc] init];
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"My Lists" subHeader:nil];
    self.navTitle = nto;
    
    [self.view bringSubviewToFront:self.aiv];
    [self.aiv startAnimating];
    self.aiv.message = @"loading";
    
    __weak ListsVC *weakSelf = self;
    UserObject *userInfo = [Settings sharedInstance].userObject;
    
    self.requestOperation = [api getListsOfUser:userInfo.userID withRestaurant:0 success:^(NSArray *lists) {
        weakSelf.lists = lists;
        ON_MAIN_THREAD( ^{
            [weakSelf.aiv stopAnimating];
            [weakSelf gotLists];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf.aiv stopAnimating];
    }];
}

- (void)gotLists
{
    NSLog(@"Got %lu lists.", (unsigned long)[_lists count]);
    [_tableView reloadData];
//    [DebugUtilities addBorderToViews:@[self.collectionView] withColors:kColorNavyBlue];
}

- (void)setupCreateListAC {
    _createListAC = [UIAlertController alertControllerWithTitle:@"Create List"
                                                        message:nil
                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [_createListAC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter new list name";
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Create"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSString *name = [_createListAC.textFields[0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                     
                                                     if ([name length]) {
                                                         [self createListNamed:name];
                                                     }
                                                 }];
    
    [_createListAC addAction:cancel];
    [_createListAC addAction:ok];
}

- (void)createListPressed {
    [self presentViewController:_createListAC animated:YES completion:nil];
}

- (void)createListNamed:(NSString *)name {
    OOAPI *api = [[OOAPI alloc] init];
    __weak ListsVC *weakSelf = self;
    [api addList:name success:^(ListObject *listObject) {
        if (listObject.listID) {
            [weakSelf addRestaurantToList:listObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Could not create list: %@", error);
    }];
}

- (void)addRestaurantToList:(ListObject *)list {
    OOAPI *api = [[OOAPI alloc] init];
    __weak ListsVC *weakSelf = self;
    [api addRestaurants:@[_restaurantToAdd] toList:list.listID success:^(id response) {
        ON_MAIN_THREAD(^{
            [weakSelf getListsForRestaurant];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Could add restaurant to list: %@", error);
    }];
}

- (void)userPressedAddAllForList:(ListObject *)list
{
    if  (!list) {
        return;
    }
    
    if  (_operationToFetchAll ) {
        return;
    }
    
    OOAPI *api= [[OOAPI alloc] init];
    __weak ListsVC *weakSelf = self;
    _operationToFetchAll = [api getRestaurantsWithListID:list.listID
                          andLocation:[LocationManager sharedInstance].currentUserLocation                            
                                                 success:^(NSArray *restaurants) {
                                                     if (!restaurants || !restaurants.count) {
                                                         return;
                                                     }
                                                   
                                                     weakSelf.operationToAddAll = [OOAPI addRestaurants:restaurants
                                                                 toEvent:weakSelf.eventBeingEdited
                                                                 success:^(id response) {
                                                                     NSLog (@"ADDED RESTAURANTS TO EVENT.");
                                                                     weakSelf.operationToAddAll= nil;
                                                                     weakSelf.eventBeingEdited.hasBeenAltered= YES;
                                                                     message(@"Added restaurants to event.");
                                                                     
                                                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                     message(@"There was a problem adding the restaurants of that list to the event.");
                                                                     NSLog(@"CANNOT ADD RESTAURANTS TO EVENT.");
                                                                     weakSelf.operationToAddAll= nil;
                                                                 }];
                                                   
                                                   weakSelf.operationToFetchAll= nil;
                                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   NSLog(@"CANNOT GET RESTAURANT WITH LIST ID");
                                                   weakSelf.operationToFetchAll= nil;
                                               }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == kListsVCSectionLists) ? kGeomHeightHorizontalListRow : 40+2*kGeomSpaceEdge;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kListsVCSectionLists:
            return [_lists count];
            break;
        case kListsVCSectionButtons:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kListsVCSectionLists) {
        ListTVCell *cell = (ListTVCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (_restaurantToAdd) {
            cell.restaurantToAdd = _restaurantToAdd;
        } else if (_listToAddTo) {
            cell.listToAddTo = _listToAddTo;
        }
        
        ListObject *list = [_lists objectAtIndex:indexPath.row];
        cell.lists = _listsWithRestaurant;
        cell.list = list;
        
        [cell updateConstraintsIfNeeded];
        return cell;
    } else {
        UITableViewCell *cell = (UITableViewCell *)[_tableView dequeueReusableCellWithIdentifier:buttonsCellIdentifier];
        _addToFavoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addToFavoritesButton withText:@"Add to Favorites" fontSize:kGeomFontSizeH3 width:0 height:40 backgroundColor:kColorOffBlack textColor:kColorWhite borderColor:kColorClear target:self selector:@selector(addToFavorites)];
        
        _addToWishlistButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addToWishlistButton withText:@"Add to Wishlist" fontSize:kGeomFontSizeH3 width:0 height:40 backgroundColor:kColorOffBlack textColor:kColorWhite borderColor:kColorClear target:self selector:@selector(addToWishlist)];

        _createListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setupCreateListAC];
        [_createListButton withText:@"Add to New List" fontSize:kGeomFontSizeH3 width:0 height:40 backgroundColor:kColorOffBlack textColor:kColorWhite borderColor:kColorClear target:self selector:@selector(createList)];
        
        NSMutableArray *buttons = [NSMutableArray array];
        [buttons addObjectsFromArray:@[_addToFavoritesButton, _addToWishlistButton, _createListButton]];
        
        [_addToFavoritesButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        if (_favoritesListID) {
            [_addToFavoritesButton setTitle:@"Remove from Favorites" forState:UIControlStateNormal];
            [_addToFavoritesButton addTarget:self action:@selector(removeFromList:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [_addToFavoritesButton setTitle:@"Add fo Favorites" forState:UIControlStateNormal];
            [_addToFavoritesButton addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [_addToWishlistButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        if (_wishListID) {
            [_addToWishlistButton setTitle:@"Remove from Wishlist" forState:UIControlStateNormal];
            [_addToWishlistButton addTarget:self action:@selector(removeFromList:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [_addToWishlistButton setTitle:@"Add to Wishlist" forState:UIControlStateNormal];
            [_addToWishlistButton addTarget:self action:@selector(addToWishlist) forControlEvents:UIControlEventTouchUpInside];
        }
        
        CGFloat x = kGeomSpaceEdge;
        for (UIButton *b in buttons) {
            b.frame = CGRectMake(x, kGeomSpaceEdge, (width(self.tableView) - kGeomSpaceEdge*([buttons count] +1))/[buttons count], 40);
            cell.contentView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
            [cell.contentView addSubview:b];
            x = CGRectGetMaxX(b.frame) + kGeomSpaceEdge;
        }
        
        return cell;
    }
    
//    if ( self.eventBeingEdited  &&  list.numRestaurants) {
//        [cell addTheAddAllButton];
//        cell.delegate= self;
//        cell.listToAddTo=list;
//    }
}

- (void)removeFromList:(id)sender {
    NSUInteger listID = 0;
    if (sender == _addToFavoritesButton) {
        listID = _favoritesListID;
    } else if (sender == _addToWishlistButton) {
        listID = _wishListID;
    } else {
        return; //can't handle this and it should not happen
    }
    
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak ListsVC *weakSelf = self;
    [api deleteRestaurant:_restaurantToAdd.restaurantID fromList:listID success:^(NSArray *lists) {
        ON_MAIN_THREAD(^{
            [weakSelf getListsForRestaurant];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRestaurantListsNeedsUpdate object:nil];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListObject *list = [_lists objectAtIndex:indexPath.row];
    
    RestaurantListVC *vc = [[RestaurantListVC alloc] init];
    vc.listItem = list;
    vc.eventBeingEdited= self.eventBeingEdited;
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)addToFavorites {
    OOAPI *api = [[OOAPI alloc] init];
    __weak ListsVC *weakSelf = self;
    
    [api addRestaurantsToSpecialList:@[_restaurantToAdd] listType:kListTypeFavorites success:^(id response) {
        [weakSelf getListsForRestaurant];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRestaurantListsNeedsUpdate object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)addToWishlist {
    OOAPI *api = [[OOAPI alloc] init];
    __weak ListsVC *weakSelf = self;
    
    [api addRestaurantsToSpecialList:@[_restaurantToAdd] listType:kListTypeToTry success:^(id response) {
        [weakSelf getListsForRestaurant];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRestaurantListsNeedsUpdate object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)createList {
    [self presentViewController:_createListAC animated:YES completion:nil];
}

- (void)userPressedAddAllForList
{
    
    
}

- (void)setRestaurantToAdd:(RestaurantObject *)restaurantToAdd {
    if (_restaurantToAdd == restaurantToAdd) return;
    _restaurantToAdd = restaurantToAdd;
    [self getListsForRestaurant];
    
}

- (void)getListsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak ListsVC *weakSelf = self;
    
    UserObject *userInfo = [Settings sharedInstance].userObject;
    
    [api getListsOfUser:userInfo.userID withRestaurant:_restaurantToAdd.restaurantID
                success:^(NSArray *foundLists) {
                    NSLog (@"number of lists with this restaurant: %ld", ( long) foundLists.count);
                    _listsWithRestaurant = foundLists;
                    ON_MAIN_THREAD( ^{
                        [weakSelf updateButtonsSection];
                    });
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                    NSLog  (@"error while getting lists with restaurant:  %@",e);
                }];
}

- (void)updateButtonsSection {
    _favoritesListID = _wishListID = 0;
    for (ListObject *lo in _listsWithRestaurant) {
        if (lo.type == kListTypeFavorites) _favoritesListID = lo.listID;
        if (lo.type == kListTypeToTry) _wishListID = lo.listID;
        if (_wishListID && _favoritesListID) break;
    }

    [_tableView reloadData];
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

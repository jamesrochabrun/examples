//
//  RestaurantVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/14/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "RestaurantVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "Settings.h"
#import "MediaItemObject.h"
#import "OORemoveButton.h"
#import "ListsVC.h"
#import "PhotoCVCell.h"
#import "RestaurantMainCVCell.h"

#import "DebugUtilities.h"

@interface RestaurantVC ()

@property (nonatomic, strong) UIAlertController *styleSheetAC;
@property (nonatomic, strong) UIAlertController *createListAC;
@property (nonatomic, strong) NSArray *lists;
@property (nonatomic, strong) UserObject* userInfo;
@property (nonatomic, strong) NSMutableSet *removeButtons;
@property (nonatomic, strong) UIView *removeButtonsContainer;
@property (nonatomic) CGFloat removeButtonsContainerHeight;
@property (nonatomic, strong) NSArray *verticalLayoutContraints;
@property (nonatomic, strong) NSArray *mediaItems;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

static NSString * const kRestaurantMainCellIdentifier = @"RestaurantMainCell";
static NSString * const kRestaurantListsCellIdentifier = @"RestaurantListsCell";
static NSString * const kRestaurantPhotoCellIdentifier = @"RestaurantPhotoCell";

@implementation RestaurantVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userInfo = [Settings sharedInstance].userObject;

    _removeButtonsContainer = [[UIView alloc] init];
    _removeButtonsContainer.backgroundColor = UIColorRGBA(kColorOffBlack);
    
    self.view.backgroundColor = UIColorRGBA(kColorWhite);
    
    [self setupStyleSheetAC];
    [self setupCreateListAC];
    
    RestaurantVCCVL *cvl = [[RestaurantVCCVL alloc] init];
    cvl.delegate = self;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:cvl];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [_collectionView registerClass:[RestaurantMainCVCell class] forCellWithReuseIdentifier:kRestaurantMainCellIdentifier];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kRestaurantListsCellIdentifier];
    [_collectionView registerClass:[PhotoCVCell class] forCellWithReuseIdentifier:kRestaurantPhotoCellIdentifier];
    
    [self.view addSubview:_collectionView];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.backgroundColor = UIColorRGBA(kColorWhite);
    
    _removeButtons = [NSMutableSet set];
    
//    [DebugUtilities addBorderToViews:@[_collectionView]];
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"removeContainerHeight":@(_removeButtonsContainerHeight)};
    
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _removeButtonsContainer, _collectionView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view removeConstraints:_verticalLayoutContraints];
    _verticalLayoutContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
    [self.view addConstraints:_verticalLayoutContraints];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)setupCreateListAC {
    _createListAC = [UIAlertController alertControllerWithTitle:@"Create List"
                                                        message:nil
                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [_createListAC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter new list name";
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                        }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Create"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [self createListNamed:_createListAC.textFields[0].text];
                                                 }];
    
    [_createListAC addAction:cancel];
    [_createListAC addAction:ok];
}

- (void)createListPressed {
    [self presentViewController:_createListAC animated:YES completion:nil];
}

- (void)createListNamed:(NSString *)name {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    [api addList:name success:^(ListObject *listObject) {
        if (listObject.listID) {
            [weakSelf addRestaurantToList:listObject];
        }
    } failure:^(NSError *error) {
        NSLog(@"Could not create list: %@", error);
    }];
}

- (void)addRestaurantToList:(ListObject *)list {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    [api addRestaurants:@[_restaurant] toList:list.listID success:^(id response) {
        ON_MAIN_THREAD(^{
            [weakSelf getListsForRestaurant];
        });
    } failure:^(NSError *error) {
        NSLog(@"Could add restaurant to list: %@", error);
    }];
}

- (void)setupStyleSheetAC {
    _styleSheetAC = [UIAlertController alertControllerWithTitle:@"Restaurant Options"
                                                           message:@"What would you like to do with this restaurant."
                                                    preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    _styleSheetAC.view.tintColor = [UIColor blackColor];
    
    __weak RestaurantVC *weakSelf = self;
    UIAlertAction *addToFavorites = [UIAlertAction actionWithTitle:@"Add to Favorites"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [self addToFavorites];
                                                 }];
    
    UIAlertAction *addToTryList = [UIAlertAction actionWithTitle:@"Add to Try List"
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 [self addToTryList];
                                                             }];

    UIAlertAction *addToList = [UIAlertAction actionWithTitle:@"Add to List"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [self showLists];
                                                 }];
    UIAlertAction *addToEvent = [UIAlertAction actionWithTitle: LOCAL(@"Add to Event")
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSLog(@"Add to Event");
                                                     [weakSelf addToEvent];
                                                 }];
    UIAlertAction *addToNewEvent = [UIAlertAction actionWithTitle:@"New Event at..."
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSLog(@"Add to New Event");
                                                 }];
    UIAlertAction *addToNewList = [UIAlertAction actionWithTitle:@"New List..."
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSLog(@"Add to New List");
                                                     [weakSelf createListPressed];
                                                 }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                 style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                     NSLog(@"Cancel");
                                                 }];
    
    
    [_styleSheetAC addAction:addToFavorites];
    [_styleSheetAC addAction:addToTryList];
    [_styleSheetAC addAction:addToList];
    [_styleSheetAC addAction:addToNewList];
    [_styleSheetAC addAction:addToEvent];
    [_styleSheetAC addAction:addToNewEvent];
    [_styleSheetAC addAction:cancel];
    
    [self.moreButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addToEvent
{
    [APP.eventBeingEdited addVenue: _restaurant];
}

- (void)removeFromEvent
{
    [APP.eventBeingEdited removeVenue:  _restaurant];
}

- (void)moreButtonPressed:(id)sender {
    [self presentViewController:_styleSheetAC animated:YES completion:nil]; // 6
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
    [api getListsOfUser:[_userInfo.userID integerValue] withRestaurant:_restaurant.restaurantID
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user:  %ld", ( long) foundLists.count);
                    _lists = foundLists;
                    [_lists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        ListObject *lo = (ListObject *)obj;
                        OORemoveButton *b = [[OORemoveButton alloc] init];
                        b.name.text = lo.name;
                        b.theId = lo.listID;// (NSUInteger)[lo.listID integerValue];
                        [b addTarget:self action:@selector(removeFromList:) forControlEvents:UIControlEventTouchUpInside];
                        [_removeButtons addObject:b];
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf displayRemoveButtons];
                    });
                }
                failure:^(NSError *e) {
                    NSLog  (@" error while getting lists for user:  %@",e);
                }];
}

- (void)getMediaItemsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    [api getMediaItemsForRestaurant:_restaurant success:^(NSArray *mediaItems) {
        _mediaItems = mediaItems;
        ON_MAIN_THREAD(^{
            [weakSelf gotMediaItems];
        });
    } failure:^(NSError *error) {
        ;
    }];

}
     
- (void)gotMediaItems {
    [_collectionView reloadData];
}

- (void)displayRemoveButtons {
    __block CGPoint origin = CGPointMake(kGeomSpaceInter, kGeomSpaceInter);
    NSArray *removeButtonsArray = [_removeButtons allObjects];
    [removeButtonsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OORemoveButton *b = (OORemoveButton *)obj;
        [_removeButtonsContainer addSubview:b];
        CGRect frame = b.frame;
        frame.size = [b getSuggestedSize];
        frame.origin.x = origin.x;
        frame.origin.y = origin.y;
        
        if (CGRectGetMaxX(frame) > (CGRectGetMaxX(self.view.frame)-kGeomSpaceInter)) {
            frame.origin.y = origin.y = CGRectGetMaxY(frame) + kGeomSpaceInter;
            frame.origin.x = kGeomSpaceInter;
        }

        b.frame = frame;
        
        origin.x = CGRectGetMaxX(frame) + kGeomSpaceEdge;
        _removeButtonsContainerHeight = CGRectGetMaxY(b.frame);
    }];
    _removeButtonsContainerHeight += (_removeButtonsContainerHeight) ? kGeomSpaceInter : 0;
    [_collectionView reloadData];
}

- (void)viewDidLayoutSubviews {
    _removeButtonsContainer.frame = CGRectMake(kGeomSpaceEdge, 0, width(self.view)-2*kGeomSpaceEdge, _removeButtonsContainerHeight);
//    NSLog(@"_removeButtonsContainer=%@", _removeButtonsContainer);
}

- (void)removeFromList:(id)sender {
    OORemoveButton  *b = (OORemoveButton *)sender;
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak RestaurantVC *weakSelf = self;
    [api deleteRestaurant:_restaurant.restaurantID fromList:b.theId success:^(NSArray *lists) {
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
    [api addRestaurantsToSpecialList:@[_restaurant] listType:kListTypeFavorites success:^(id response) {
        [weakSelf getListsForRestaurant];
    } failure:^(NSError *error) {
        ;
    }];
}

- (void)addToTryList {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    
    [api addRestaurantsToSpecialList:@[_restaurant] listType:kListTypeToTry success:^(id response) {
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

#pragma mark - Collection View stuff

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case kSectionTypeMain:
            return 1;
            break;
        case kSectionTypeLists:
            return 1;
            break;
        case kSectionTypeMediaItems:
            return [_mediaItems count];
            break;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    
    switch (indexPath.section) {
        case kSectionTypeMain: {
            RestaurantMainCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kRestaurantMainCellIdentifier forIndexPath:indexPath];
            //cvc.backgroundColor = UIColorRGBA(kColorGrayMiddle);
            cvc.restaurant = _restaurant;
            if ([_mediaItems count]) {
                cvc.mediaItemObject = [_mediaItems objectAtIndex:0];
            }
            return cvc;
            break;
        }
        case kSectionTypeLists: {
            UICollectionViewCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kRestaurantListsCellIdentifier forIndexPath:indexPath];
            cvc.backgroundColor = UIColorRGBA(kColorWhite);
            [cvc addSubview:_removeButtonsContainer];
            return cvc;
            break;
        }
        case kSectionTypeMediaItems: {
            PhotoCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kRestaurantPhotoCellIdentifier forIndexPath:indexPath];
            cvc.backgroundColor = UIColorRGBA(kColorWhite);
            cvc.mediaItemObject = [_mediaItems objectAtIndex:indexPath.row];
//            [DebugUtilities addBorderToViews:@[cvc]];
            return cvc;
            break;
        }
        default:
            break;
    }

    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kSectionTypeNumberOfSections;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RestaurantVCCVL *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case kSectionTypeLists:
            return _removeButtonsContainerHeight;
            break;
        case kSectionTypeMain:
            return 140;
            break;
        case kSectionTypeMediaItems: {
            MediaItemObject *mio = [_mediaItems objectAtIndex:indexPath.row];
            if (!mio.width || !mio.height) return width(collectionView)/kNumColumnsForMediaItems; //NOTE: this should not happen
            return floorf((width(self.collectionView) - (kNumColumnsForMediaItems-1) - 2*kGeomSpaceEdge)/kNumColumnsForMediaItems  /*width(_collectionView)- 5*kGeomSpaceEdge)/kNumColumnsForMediaItems*/*mio.height/mio.width);
            break;
        }
        default:
            return 0;
            break;
    }
    return 0;
}

// supplementatry views
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
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

//
//  FoodFeedVC.m
//  ooApp
//
//  Created by Anuj Gujar on 12/16/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "FoodFeedVC.h"
#import "NavTitleObject.h"
#import "OOFilterView.h"
#import "PhotoCVCell.h"
#import "RestaurantObject.h"
#import "Settings.h"
#import "OOAPI.h"
#import "RestaurantVC.h"
#import "ProfileVC.h"
#import "LocationManager.h"

typedef enum {
    kFoodFeedTypeFriends = 1,
    kFoodFeedTypeAll = 2
} FoodFeedType;

static NSString * const kPhotoCellIdentifier = @"PhotoCell";

@interface FoodFeedVC ()
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) OOFilterView *filterView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) UIAlertController *showPhotoOptions;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@end

@implementation FoodFeedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _nto = [[NavTitleObject alloc] initWithHeader:@"Food Feed" subHeader:nil];
    self.navTitle = _nto;
    
    _filterView = [[OOFilterView alloc] init];
    _filterView.translatesAutoresizingMaskIntoConstraints = NO;
    [_filterView addFilter:@"All" target:self selector:@selector(selectAll)];
    [_filterView addFilter:@"Friends" target:self selector:@selector(selectFriends)];
    [_filterView setCurrent:0];
    [self.view addSubview:_filterView];
    
    FoodFeedVCCVL *cvl = [[FoodFeedVCCVL alloc] init];
    cvl.delegate = self;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:cvl];
    [_collectionView scrollsToTop];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [_collectionView registerClass:[PhotoCVCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
    
    [self.view addSubview:_collectionView];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);

    [self setRightNavWithIcon:kFontIconPhoto target:self action:@selector(showCameraUI)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCameraUI {
    NSLog(@"Show camera UI");
}

- (void)selectAll {
    [self getFoodFeed:kFoodFeedTypeAll];
}

- (void)selectFriends {
    [self getFoodFeed:kFoodFeedTypeFriends];
}

- (void)getNearbyRestaurants {
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak FoodFeedVC *weakSelf = self;
    
    _requestOperation = [api getRestaurantsWithKeywords:[NSMutableArray arrayWithArray:@[@"restaurant", @"bar"]]
                                            andLocation:[[LocationManager sharedInstance] currentUserLocation]
                                              andFilter:@""
                                              andRadius:20
                                            andOpenOnly:NO
                                                andSort:kSearchSortTypeDistance
                                               minPrice:0
                                               maxPrice:3
                                                 isPlay:NO
                                                success:^(NSArray *r) {
                                                    _restaurants = r;
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [weakSelf gotRestaurants];
                                                    });
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
                                                    ;
                                                }];
}

- (void)gotRestaurants {
    
}

- (void)getFoodFeed:(FoodFeedType)type {
    __weak FoodFeedVC *weakSelf = self;
    
    [OOAPI getFoodFeedType:type success:^(NSArray *restaurants) {
        _restaurants = restaurants;
        ON_MAIN_THREAD(^{
            [weakSelf.collectionView reloadData];
            [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _restaurants = [NSArray array];
    }];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FoodFeedVCCVL *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantObject *r =[_restaurants objectAtIndex:indexPath.row];
    MediaItemObject *mio = ([r.mediaItems count]) ? [r.mediaItems objectAtIndex:0] : [[MediaItemObject alloc] init];
    if (!mio.width || !mio.height) return width(collectionView)/kFoodFeedNumColumnsForMediaItems; //NOTE: this should not happen
    CGFloat height = floorf(((width(self.collectionView) - (kFoodFeedNumColumnsForMediaItems-1) - 2*kGeomSpaceEdge)/kFoodFeedNumColumnsForMediaItems)*mio.height/mio.width);
    return height;
    return 0;
}


- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2), @"mapWidth" : @(width(self.view))};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_filterView, _collectionView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_filterView(heightFilters)][_collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_filterView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_restaurants count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
    RestaurantObject *r = [_restaurants objectAtIndex:indexPath.row];
    cvc.delegate = self;
    cvc.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    cvc.mediaItemObject = ([r.mediaItems count]) ? [r.mediaItems objectAtIndex:0] : nil;
//    [cvc showActionButton:(cvc.mediaItemObject.source == kMediaItemTypeOomami) ? YES : NO];
    [cvc showActionButton:NO];
    //[DebugUtilities addBorderToViews:@[cvc]];
    return cvc;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantObject *r = [_restaurants objectAtIndex:indexPath.row];
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    vc.restaurant = r;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)photoCell:(PhotoCVCell *)photoCell showProfile:(UserObject *)userObject {
    ProfileVC *vc = [[ProfileVC alloc] init];
    vc.userInfo = userObject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)photoCell:(PhotoCVCell *)photoCell showPhotoOptions:(MediaItemObject *)mio {
    _showPhotoOptions = [UIAlertController alertControllerWithTitle:@"" message:@"What would you like to do with this photo?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    UIAlertAction *deletePhoto = [UIAlertAction actionWithTitle:@"Delete"
                                                          style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                                                              __weak FoodFeedVC *weakSelf = self;
                                                              ON_MAIN_THREAD(^{
                                                                  [weakSelf deletePhoto:mio];
                                                              });
                                                              
                                                          }];
    UIAlertAction *tagPhoto = [UIAlertAction actionWithTitle:@"Tag"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           [self tagPhoto:mio];
                                                       }];
    UIAlertAction *flagPhoto = [UIAlertAction actionWithTitle:@"Flag"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            [self flagPhoto:mio];
                                                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                         NSLog(@"Cancel");
                                                     }];
    
    UserObject *uo = [Settings sharedInstance].userObject;
    
    if (mio.sourceUserID == uo.userID) {
        [_showPhotoOptions addAction:tagPhoto];
        [_showPhotoOptions addAction:deletePhoto];
    }
    [_showPhotoOptions addAction:flagPhoto];
    [_showPhotoOptions addAction:cancel];
    
    [self presentViewController:_showPhotoOptions animated:YES completion:^{
        ;
    }];
}

- (void)tagPhoto:(MediaItemObject *)mio {
    
}

- (void)flagPhoto:(MediaItemObject *)mio {
    [OOAPI flagMediaItem:mio.mediaItemId success:^(NSArray *names) {
        NSLog(@"photo flagged: %lu", (unsigned long)mio.mediaItemId);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"could not flag the photo: %@", error);
    }];
}

- (void)deletePhoto:(MediaItemObject *)mio {
    NSUInteger userID = [Settings sharedInstance].userObject.userID;
    __weak FoodFeedVC *weakSelf = self;
    
    if (mio.sourceUserID == userID) {
        [OOAPI deletePhoto:mio success:^{
            ON_MAIN_THREAD(^{
                [weakSelf.filterView selectCurrent];
            });
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

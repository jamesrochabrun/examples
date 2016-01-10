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
@property (nonatomic, strong) UIImage *imageToUpload;
@property (nonatomic, strong) RestaurantPickerVC *restaurantPicker;
@property (nonatomic) BOOL needsUpdate;
@end

@implementation FoodFeedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
	ANALYTICS_SCREEN( @( object_getClassName(self)));

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setUpdateNeeded)
                                                 name:kNotificationFoodFeedNeedsUpdate object:nil];
    _needsUpdate = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationFoodFeedNeedsUpdate object:nil];
}

- (void)setUpdateNeeded {
    _needsUpdate = YES;
}

- (void)updateIfNeeded {
    if (_needsUpdate) {
        [_filterView selectCurrent];
        _needsUpdate = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCameraUI {
    
    BOOL haveCamera  = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if (!haveCamera) {
        [self showRestaurantPicker];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera ;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    if (!image) {
        image = info[@"UIImagePickerControllerOriginalImage"];
    }
    CGSize s = image.size;
    _imageToUpload = [UIImage imageWithImage:image scaledToSize:CGSizeMake(750, 750*s.height/s.width)];
    
    __weak FoodFeedVC *weakSelf = self;
    
    [weakSelf dismissViewControllerAnimated:YES completion:nil];
    
    [self showRestaurantPicker];
}

- (void)showRestaurantPicker {
    if (_restaurantPicker) return;
    _restaurantPicker = [[RestaurantPickerVC alloc] init];
    _restaurantPicker.view.backgroundColor = UIColorRGBA(kColorBlack);
    _restaurantPicker.delegate = self;
    _restaurantPicker.imageToUpload = _imageToUpload;
    _restaurantPicker.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_restaurantPicker.view];
    [self.view setNeedsUpdateConstraints];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectAll {
    [self getFoodFeed:kFoodFeedTypeAll];
}

- (void)selectFriends {
    [self getFoodFeed:kFoodFeedTypeFriends];
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
    
    NSDictionary *views;
    
    if (_restaurantPicker) {
        UIView *restaurantPickerView = _restaurantPicker.view;
        views = NSDictionaryOfVariableBindings(_filterView, _collectionView, restaurantPickerView);
    } else {
        views = NSDictionaryOfVariableBindings(_filterView, _collectionView);
    }
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_filterView(heightFilters)][_collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_filterView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    if (_restaurantPicker) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[restaurantPickerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[restaurantPickerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    }
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

    MediaItemObject *mio = ([r.mediaItems count]) ? [r.mediaItems objectAtIndex:0] : nil;
    
    
    ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];
    vc.mio = mio;
    vc.restaurant = r;
    vc.delegate = self;
    //[self.navigationController pushViewController:vc animated:NO];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:vc animated:NO completion:^{
    }];
}

- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showRestaurant:(RestaurantObject *)restaurant {
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    vc.restaurant = restaurant;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showProfile:(UserObject *)user {
    ProfileVC *vc = [[ProfileVC alloc] init];
    vc.userInfo = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)photoCell:(PhotoCVCell *)photoCell likePhoto:(MediaItemObject *)mio {
    
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
    UIAlertAction *tagPhoto = [UIAlertAction actionWithTitle:@"Add Caption"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           [self tagPhoto:mio];
                                                       }];
    UIAlertAction *flagPhoto = [UIAlertAction actionWithTitle:@"Flag"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            [self flagPhoto:mio];
                                                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
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

- (void)restaurantPickerVC:(RestaurantPickerVC *)restaurantPickerVC restaurantSelected:(RestaurantObject *)restaurant {
    NSLog(@"restaurant selected %@", restaurant.name);
    [_restaurantPicker.view removeFromSuperview];
    _restaurantPicker = nil;
    [self.view setNeedsUpdateConstraints];
    
    __weak FoodFeedVC *weakSelf = self;
    
    if (restaurant.restaurantID) {
        [OOAPI uploadPhoto:_imageToUpload forObject:restaurant
               success:^{
                   [weakSelf.filterView selectCurrent];
               } failure:^(NSError *error) {
                   NSLog(@"Failed to upload photo");
               }];
    } else  {
        OOAPI *api = [[OOAPI alloc] init];
        [api getRestaurantWithID:restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
            if (restaurant && [restaurant isKindOfClass:[RestaurantObject class]]) {
                [OOAPI uploadPhoto:_imageToUpload forObject:restaurant
                           success:^{
                               [weakSelf.filterView selectCurrent];
                           } failure:^(NSError *error) {
                               NSLog(@"Failed to upload photo");
                           }];
            
            } else {
                NSLog(@"Failed to upload photo because didn't get back a restaurant object");    
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to upload photo because the google ID was not found");
        }];
    }
}

- (void)restaurantPickerVCCanceled:(RestaurantPickerVC *)restaurantPickerTVC {
    NSLog(@"restaurant picker canceled");
    [_restaurantPicker.view removeFromSuperview];
    _restaurantPicker = nil;
    [self.view setNeedsUpdateConstraints];
    _imageToUpload = nil;
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

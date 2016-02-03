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
#import "UIImage+Additions.h"
#import <AssetsLibrary/AssetsLibrary.h>

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
@property (nonatomic) BOOL needsUpdate;
@property (nonatomic) NSUInteger numColumns;
@property (nonatomic) NSUInteger selectedItem;
@property (nonatomic, strong) UIButton *toggleNumColumnsButton;
@property (nonatomic, strong) FoodFeedVCCVL *cvl;
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
    [_filterView addFilter:@"Following" target:self selector:@selector(selectFriends)];
    [_filterView setCurrent:0];
    [self.view addSubview:_filterView];
    
    _cvl = [[FoodFeedVCCVL alloc] init];
    _cvl.delegate = self;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_cvl];
    [_collectionView scrollsToTop];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [_collectionView registerClass:[PhotoCVCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
    
    [self.view addSubview:_collectionView];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _toggleNumColumnsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_toggleNumColumnsButton withIcon:kFontIconFoodFeed fontSize:40 width:40 height:40 backgroundColor:kColorClear target:self selector:@selector(toggleNumColumns)];
//    [self.view addSubview:_toggleNumColumnsButton];
    _toggleNumColumnsButton.hidden = YES;

    [self setRightNavWithIcon:kFontIconPhoto target:self action:@selector(showPickPhotoUI)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setUpdateNeeded)
                                                 name:kNotificationFoodFeedNeedsUpdate object:nil];
    [self.view bringSubviewToFront:self.uploadProgressBar];
    _needsUpdate = YES;
    _numColumns = 2;
    _selectedItem = -1;
}

- (void)viewWillLayoutSubviews {
    CGFloat w = width(self.view);
    self.uploadProgressBar.frame = CGRectMake(0, 0, w, 2);
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

- (void)showPickPhotoUI
{
    BOOL haveCamera = NO, havePhotoLibrary = NO;
    haveCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? YES : NO;
    havePhotoLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ? YES : NO;
    UIAlertController *addPhoto = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Add Photo to the Food Feed"]
                                                                      message:[NSString stringWithFormat:@"Take a photo with your camera or add one from your photo library."]
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cameraUI = [UIAlertAction actionWithTitle:@"Camera"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           [self showCameraUI];
                                                       }];
    
    UIAlertAction *libraryUI = [UIAlertAction actionWithTitle:@"Library"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            [self showPhotoLibraryUI];
                                                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       NSLog(@"Cancel");
                                                   }];
    
    
    if (haveCamera) [addPhoto addAction:cameraUI];
    if (havePhotoLibrary) [addPhoto addAction:libraryUI];
    [addPhoto addAction:cancel];
    
    if (havePhotoLibrary && haveCamera ) {
        [self presentViewController:addPhoto animated:YES completion:nil];
    } else {
        [self showRestaurantPickerAtCoordinate:[LocationManager sharedInstance].currentUserLocation];
    }
}

- (void)showCameraUI {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera ;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)showPhotoLibraryUI {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];

    CGSize s = image.size;
    _imageToUpload = [UIImage imageWithImage:image scaledToSize:CGSizeMake(kGeomUploadWidth, kGeomUploadWidth*s.height/s.width)];

    NSURL *url = info[@"UIImagePickerControllerReferenceURL"];

    __weak FoodFeedVC *weakSelf = self;

    if (url) {
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:url resultBlock:^(ALAsset *asset) {
            NSDictionary *metadata = asset.defaultRepresentation.metadata;
            if (metadata) {
                NSString *longitudeRef = metadata[@"{GPS}"][@"LongitudeRef"];
                NSNumber *longitude = metadata[@"{GPS}"][@"Longitude"];
                NSString *latitudeRef = metadata[@"{GPS}"][@"LatitudeRef"];
                NSNumber *latitude = metadata[@"{GPS}"][@"Latitude"];
                
                
                if ([longitudeRef isEqualToString:@"W"]) longitude = [NSNumber numberWithDouble:-[longitude doubleValue]];
                
                if ([latitudeRef isEqualToString:@"S"]) latitude = [NSNumber numberWithDouble:-[latitude doubleValue]];
                
                if (longitude && latitude) {
                    CLLocationCoordinate2D photoLocation = CLLocationCoordinate2DMake([latitude doubleValue],
                                                       [longitude doubleValue]);
//                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    [weakSelf showRestaurantPickerAtCoordinate:photoLocation];
                } else {
                    [weakSelf showMissinGPSMessage];
                }
            } else {
                [weakSelf showMissinGPSMessage];
            }
        } failureBlock:^(NSError *error) {
            //User denied access
            NSLog(@"Unable to access image: %@", error);
            [weakSelf showMissinGPSMessage];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self showRestaurantPickerAtCoordinate:[LocationManager sharedInstance].currentUserLocation];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMissinGPSMessage {
    [self showRestaurantPickerAtCoordinate:[LocationManager sharedInstance].currentUserLocation];
}

- (void)showRestaurantPickerAtCoordinate:(CLLocationCoordinate2D)location {
    RestaurantPickerVC *restaurantPicker = [[RestaurantPickerVC alloc] init];
    restaurantPicker.location = location;
    restaurantPicker.view.backgroundColor = UIColorRGBA(kColorBlack);
    restaurantPicker.delegate = self;
    restaurantPicker.imageToUpload = _imageToUpload;

    UINavigationController *nc = [[UINavigationController alloc] init];
    
    [nc addChildViewController:restaurantPicker];
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorBlack)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setShadowImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)]];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController presentViewController:nc animated:YES completion:^{
        [restaurantPicker.view setNeedsUpdateConstraints];
    }];
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
    
    [self.view bringSubviewToFront:self.aiv];
    [self.aiv startAnimating];
    self.aiv.message = @"loading";

    
    [OOAPI getFoodFeedType:type success:^(NSArray *restaurants) {
        weakSelf.restaurants = restaurants;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
            [weakSelf.aiv stopAnimating];
            if ([weakSelf.restaurants count]) {
                [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        weakSelf.restaurants = @[ ];
        [weakSelf.aiv stopAnimating];
    }];
}

- (void)toggleNumColumns {
    _numColumns = (_numColumns == 1) ? 2 : 1;
    UICollectionViewCell *cell = [_collectionView.visibleCells objectAtIndex:0];
    if (!cell) return;
//    NSIndexPath *ip = [_collectionView indexPathForCell:cell];
    [_cvl invalidateLayout];
//    [_collectionView reloadItemsAtIndexPaths:@[ip]];
//    [_collectionView reloadData];
//    [_collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (NSUInteger)collectionView:(UICollectionView *)collectionView layout:(FoodFeedVCCVL *)collectionViewLayout numberOfColumnsInSection:(NSUInteger)section {
    
    return _numColumns;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FoodFeedVCCVL *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_numColumns == 1) {
        if (_selectedItem != indexPath.row) return 150;
//        return height(_collectionView);
    }
    
    RestaurantObject *r =[_restaurants objectAtIndex:indexPath.row];
    MediaItemObject *mio = ([r.mediaItems count]) ? [r.mediaItems objectAtIndex:0] : [[MediaItemObject alloc] init];
    if (!mio.width || !mio.height) return width(collectionView)/_numColumns; //NOTE: this should not happen
    CGFloat height = floorf(((width(self.collectionView) - (_numColumns-1) - 2*kGeomSpaceEdge)/_numColumns)*mio.height/mio.width);
    return height;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2), @"mapWidth" : @(width(self.view))};
    
    NSDictionary *views;
    views = NSDictionaryOfVariableBindings(_filterView, _collectionView);

    
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
    _selectedItem = (_selectedItem == indexPath.row) ? -1 : indexPath.row;
    
    if (_numColumns == 1) {
        
        [_collectionView performBatchUpdates:^{
           [_cvl invalidateLayout];
        } completion:^(BOOL finished) {
            
        }];

        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        return;
    }
    RestaurantObject *r = [_restaurants objectAtIndex:indexPath.row];

    MediaItemObject *mio = ([r.mediaItems count]) ? [r.mediaItems objectAtIndex:0] : nil;

    PhotoCVCell *cell = (PhotoCVCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CGRect frame = [self.view convertRect:cell.frame fromView:_collectionView];
    frame.origin.y += kGeomHeightNavBarStatusBar;
    
    [self showExpandedPhoto:mio forRestaurant:r fromRect:frame];
}

- (void)showExpandedPhoto:(MediaItemObject *)mio {
    if (!(mio.restaurantID)) return;

    __weak FoodFeedVC *weakSelf = self;
    OOAPI *api = [[OOAPI alloc] init];
    CGRect originRect = CGRectMake(self.view.center.x, self.view.center.y, 20, 20);

    
    [api getRestaurantWithID:stringFromUnsigned(mio.restaurantID)
                      source:kRestaurantSourceTypeOomami
                     success:^(RestaurantObject *restaurant) {
                             if (restaurant) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [weakSelf showExpandedPhoto:mio forRestaurant:restaurant fromRect:originRect];
                                 });
                             } else {
                                 NSLog(@"Did not get a restaurant.");
                             }
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             NSLog(@"Could not find the restaurant.");
                         });
                     }];
}

- (void)showExpandedPhoto:(MediaItemObject *)mio forRestaurant:(RestaurantObject *)restautant fromRect:(CGRect)originRect {
    ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];
    vc.originRect = originRect;
    vc.mio = mio;
    vc.restaurant = restautant;
    vc.delegate = self;
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([toVC isKindOfClass:[ViewPhotoVC class]] && operation == UINavigationControllerOperationPush) {
        ViewPhotoVC *vc = (ViewPhotoVC *)toVC;
        ShowMediaItemAnimator *animator = [[ShowMediaItemAnimator alloc] init];
        animator.presenting = YES;
        animator.originRect = vc.originRect;
        animator.duration = 0.8;
        animationController = animator;
    } else if ([fromVC isKindOfClass:[ViewPhotoVC class]] && operation == UINavigationControllerOperationPop) {
        ShowMediaItemAnimator *animator = [[ShowMediaItemAnimator alloc] init];
        ViewPhotoVC *vc = (ViewPhotoVC *)fromVC;
        animator.presenting = NO;
        animator.originRect = vc.originRect;
        animator.duration = 0.6;
        animationController = animator;
    } else {
        
    }
    
    return animationController;
}

- (void)viewPhotoVCClosed:(ViewPhotoVC *)viewPhotoVC {
    [self updateIfNeeded];
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
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
    
    self.uploading = YES;
    self.uploadProgressBar.hidden = NO;
    
    [self.view setNeedsUpdateConstraints];
    
    __weak FoodFeedVC *weakSelf = self;

    if (restaurant.restaurantID) {
        [OOAPI uploadPhoto:_imageToUpload forObject:restaurant
               success:^(MediaItemObject *mio){
                   weakSelf.uploading = NO;
                   dispatch_async(dispatch_get_main_queue(), ^{
                       weakSelf.uploadProgressBar.hidden = YES;
                       [weakSelf showExpandedPhoto:mio];
                       [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFoodFeedNeedsUpdate object:nil];
                   });
               } failure:^(NSError *error) {
                   weakSelf.uploading = NO;
                   dispatch_async(dispatch_get_main_queue(), ^{
                       weakSelf.uploadProgressBar.hidden = YES;
                   });
                   NSLog(@"Failed to upload photo");
               } progress:^(NSUInteger __unused bytesWritten,
                            long long totalBytesWritten,
                            long long totalBytesExpectedToWrite) {
                   long double d= totalBytesWritten;
                   d/=totalBytesExpectedToWrite;
                   dispatch_async(dispatch_get_main_queue(), ^{
                       weakSelf.uploadProgressBar.progress = (float)d;
                   });
               }];
    } else  {
        OOAPI *api = [[OOAPI alloc] init];
        [api getRestaurantWithID:restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
            if (restaurant && [restaurant isKindOfClass:[RestaurantObject class]]) {
                [OOAPI uploadPhoto:_imageToUpload forObject:restaurant
                           success:^(MediaItemObject *mio){
                               weakSelf.uploading = NO;
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   weakSelf.uploadProgressBar.hidden = YES;
                                   [weakSelf showExpandedPhoto:mio];
                                   [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFoodFeedNeedsUpdate object:nil];
                               });
                           } failure:^(NSError *error) {
                               weakSelf.uploading = NO;
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   weakSelf.uploadProgressBar.hidden = YES;
                               });
                               NSLog(@"Failed to upload photo");
                           } progress:^(NSUInteger __unused bytesWritten,
                                       long long totalBytesWritten,
                                       long long totalBytesExpectedToWrite) {
                               long double d= totalBytesWritten;
                               d/=totalBytesExpectedToWrite;
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   weakSelf.uploadProgressBar.progress = (float)d;
                               });
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
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
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

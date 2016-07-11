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
#import "AppDelegate.h"
#import "DebugUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

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
@property (nonatomic) FoodFeedType feedType;
@property (nonatomic, strong) UIButton *noPhotosMessage;
@end

@implementation FoodFeedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _nto = [[NavTitleObject alloc] initWithHeader:@"Food Feed" subHeader:nil];
    
    _filterView = [[OOFilterView alloc] init];
    _filterView.translatesAutoresizingMaskIntoConstraints = NO;
    [_filterView addFilter:@"Newest" target:self selector:@selector(selectAll)];
    [_filterView addFilter:@"Around Me" target:self selector:@selector(selectAroundMe)];
    [_filterView addFilter:@"Following" target:self selector:@selector(selectFriends)];
    [_filterView setCurrent:1];
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
    [self.view addSubview:_toggleNumColumnsButton];
    _toggleNumColumnsButton.hidden = YES;
    
    [self.view bringSubviewToFront:self.uploadProgressBar];
    _needsUpdate = YES;
    _numColumns = 2;
    _selectedItem = -1;
    
    _noPhotosMessage = [UIButton buttonWithType:UIButtonTypeCustom];
    _noPhotosMessage.translatesAutoresizingMaskIntoConstraints = NO;
    [_noPhotosMessage withText:@"" fontSize:kGeomFontSizeH2 width:40 height:40 backgroundColor:kColorTextActive textColor:kColorTextReverse borderColor:kColorClear target:self selector:@selector(goToConnect)];
    _noPhotosMessage.titleLabel.numberOfLines = 0;
    _noPhotosMessage.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_collectionView addSubview:_noPhotosMessage];
    
    //[DebugUtilities addBorderToViews:@[_noPhotosMessage]];
}

- (void)gotFirstLocation:(id)notification
{
    NSLog(@"LOCATION BECAME AVAILABLE FROM iOS");
    __weak FoodFeedVC *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_feedType == kFoodFeedTypeAroundMe) {
            [weakSelf refreshFeed];
        }
        //[weakSelf getRestaurants];
    });
}

- (void)goToConnect {
    [APP.tabBar setSelectedIndex:kTabIndexConnect];
}

- (void)viewWillLayoutSubviews {
    CGFloat w = width(self.view);
    self.uploadProgressBar.frame = CGRectMake(0, 0, w, 2);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationFoodFeedNeedsUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appBecameActive {
    if (!APP.dateLeft || (APP.dateLeft && [[NSDate date] timeIntervalSinceDate:APP.dateLeft] > [TimeUtilities intervalFromDays:0 hours:0 minutes:3 second:00])) {
        [self setUpdateNeeded];
        [self updateIfNeeded];
        APP.dateLeft = [NSDate date];
    }
}

- (void)forceRefresh:(id)sender {
    [self setUpdateNeeded];
    [self updateIfNeeded];
}

- (void)setUpdateNeeded {
    _needsUpdate = YES;
}

- (void)updateIfNeeded {
    if (_needsUpdate) {
        [self refreshFeed];
        _needsUpdate = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN(@(object_getClassName(self)));

    self.navTitle = _nto;
    
    [self removeNavButtonForSide:kNavBarSideTypeLeft];
    [self removeNavButtonForSide:kNavBarSideTypeRight];
    [self addNavButtonWithIcon:kFontIconPhotoThick target:self action:@selector(showPickPhotoUI) forSide:kNavBarSideTypeRight isCTA:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self updateIfNeeded];
    
    [self.refreshControl addTarget:self action:@selector(forceRefresh:) forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:self.refreshControl];
    _collectionView.alwaysBounceVertical = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setUpdateNeeded)
                                                 name:kNotificationFoodFeedNeedsUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appBecameActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotFirstLocation:)
                                                 name:kNotificationGotFirstLocation object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [APP openLink];
    
//    [self.navigationController setNavigationBarHidden:NO animated:animated];

    //    [APP processNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPickPhotoUI {
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!result) {
            UnverifiedUserVC *vc = [[UnverifiedUserVC alloc] initWithSize:CGSizeMake(250, 200)];
            vc.delegate = self;
            vc.action = @"To upload photos you will need to verify your email.\n\nCheck your email for a verification link.";
            vc.modalPresentationStyle = UIModalPresentationCurrentContext;
            vc.transitioningDelegate = vc;
            self.navigationController.delegate = vc;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController presentViewController:vc animated:YES completion:^{
                }];
            });
        } else {
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
            
            if (havePhotoLibrary && haveCamera) {
                [self presentViewController:addPhoto animated:YES completion:nil];
            } else { // just for test purposes
                [self showRestaurantPickerAtCoordinate:[LocationManager sharedInstance].currentUserLocation];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"*** Problem verifying user");
        if (error.code == kCFURLErrorNotConnectedToInternet) {
            message(@"You do not appear to be connected to the internet.");
        } else {
            message(@"There was a problem verifying your account.");
        }
        return;
    }];
}

- (void)unverifiedUserVCDismiss:(UnverifiedUserVC *)unverifiedUserVC {
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)showCameraUI {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera ;
        
        [self presentViewController:picker animated:YES completion:NULL];
    } else if(authStatus == AVAuthorizationStatusDenied) {
        [self getAccessToCamera];
    } else if(authStatus == AVAuthorizationStatusRestricted) {
        [self getAccessToCamera];
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", AVMediaTypeVideo);
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = NO;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera ;
                
                [self presentViewController:picker animated:YES completion:NULL];
            } else {
                NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                [self getAccessToCamera];
            }
        }];
    } else {
        // impossible, unknown authorization status
    }
}

- (void)getAccessToCamera {
    UIAlertController *cameraAccess = [UIAlertController alertControllerWithTitle:@"Access Required" message:@"You will need to give Oomami access to your camera from settings in order to take a photo that you can upload." preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction *gotoSettings = [UIAlertAction actionWithTitle:@"Give Access"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [Common goToSettings:kAppSettingsCamera];
                                                           }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     }];
    [cameraAccess addAction:gotoSettings];
    [cameraAccess addAction:cancel];
    [self presentViewController:cameraAccess animated:YES completion:^{
        ;
    }];
}

- (void)showPhotoLibraryUI {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    // check the status for ALAuthorizationStatusAuthorized or ALAuthorizationStatusDenied e.g
    
    if (status == ALAuthorizationStatusDenied) {
        //show alert for asking the user to give permission

        UIAlertController *photosAccess = [UIAlertController alertControllerWithTitle:@"Access Required" message:@"You will need to give Oomami access to your photos from settings in order to pick a photo to upload." preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction *gotoSettings = [UIAlertAction actionWithTitle:@"Give Access"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  [Common goToSettings:kAppSettingsPhotos];
                                                              }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
        [photosAccess addAction:gotoSettings];
        [photosAccess addAction:cancel];
        [self presentViewController:photosAccess animated:YES completion:^{
            ;
        }];

    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    if (!image) {
        image = info[@"UIImagePickerControllerOriginalImage"];
    }
    if (!image || ![image isKindOfClass:[UIImage class]])
        return;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }

    CGSize s = image.size;
    _imageToUpload = [UIImage imageWithImage:image scaledToSize:CGSizeMake(kGeomUploadWidth, kGeomUploadWidth*s.height/s.width)];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum ||
        picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {

        ConfirmPhotoVC *vc = [ConfirmPhotoVC new];
        vc.photoInfo = info;
        vc.iv.image = _imageToUpload;
        vc.delegate = self;
        
        UINavigationController *nc = [[UINavigationController alloc] init];
        
        [nc addChildViewController:vc];
        [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
        [nc.navigationBar setTranslucent:YES];
        nc.view.backgroundColor = [UIColor clearColor];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self.navigationController presentViewController:nc animated:YES completion:^{
                [vc.view setNeedsUpdateConstraints];
            }];
        }];
    } else {
        [self imageConfirmedWithMediaWithInfo:info];
    }
}

- (void)confirmPhotoVCCancelled:(ConfirmPhotoVC *)confirmPhotoVC getNewPhoto:(BOOL)getNewPhoto {
    [self dismissViewControllerAnimated:YES completion:^{
        if (getNewPhoto) {
            [self showPhotoLibraryUI];
        }
    }];
}

- (void)confirmPhotoVCAccepted:(ConfirmPhotoVC *)confirmPhotoVC photoInfo:(NSDictionary *)photoInfo image:(UIImage *)image {
    [self dismissViewControllerAnimated:YES completion:^{
        [self imageConfirmedWithMediaWithInfo:photoInfo];
    }];
}

- (void)imageConfirmedWithMediaWithInfo:(NSDictionary<NSString *,id> *)info {
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
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    [weakSelf showRestaurantPickerAtCoordinate:photoLocation];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [weakSelf showMissinGPSMessage];
                }
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
                [weakSelf showMissinGPSMessage];
            }
        } failureBlock:^(NSError *error) {
            //User denied access
            NSLog(@"Unable to access image: %@", error);
            [self dismissViewControllerAnimated:YES completion:nil];
            [weakSelf showMissinGPSMessage];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [weakSelf showMissinGPSMessage];
    }
}

- (void)showMissinGPSMessage {
    [self showRestaurantPickerAtCoordinate:[LocationManager sharedInstance].currentUserLocation];
}

- (void)showRestaurantPickerAtCoordinate:(CLLocationCoordinate2D)location {
    RestaurantPickerVC *restaurantPicker = [[RestaurantPickerVC alloc] init];
    restaurantPicker.location = location;
    restaurantPicker.delegate = self;
    restaurantPicker.imageToUpload = _imageToUpload;

    UINavigationController *nc = [[UINavigationController alloc] init];
    
    [nc addChildViewController:restaurantPicker];
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
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

- (void)selectAroundMe {
    _feedType = kFoodFeedTypeAroundMe;
    _noPhotosMessage.hidden = YES;
    [self getFoodFeed:kFoodFeedTypeAroundMe];
}

- (void)selectAll {
    _feedType = kFoodFeedTypeAll;
    _noPhotosMessage.hidden = YES;
    [self getFoodFeed:kFoodFeedTypeAll];
}

- (void)selectFriends {
    _feedType = kFoodFeedTypeFriends;
    _noPhotosMessage.hidden = YES;
    [self getFoodFeed:kFoodFeedTypeFriends];
}

- (void)getFoodFeed:(FoodFeedType)type {
    [self.refreshControl endRefreshing];
    
    if (type == kFoodFeedTypeAroundMe) {
        CLLocationCoordinate2D l = [LocationManager sharedInstance].currentUserLocation;
        if (l.longitude == 0 && l.latitude == 0) {
            [self setNoPhotosMessage:@"Tap here to give access to your location. Then come back to see amazing food & drinks around you." target:self selector:@selector(goToLocationSettings) show:YES];
            self.restaurants = @[ ];
            [self.collectionView reloadData];
            return;
        }
    }

    __weak FoodFeedVC *weakSelf = self;
    [self.view bringSubviewToFront:self.aiv];
    [self.aiv startAnimating];
    self.aiv.message = @"loading";
    
    [OOAPI getFoodFeedType:type success:^(NSArray *restaurants) {
        weakSelf.restaurants = restaurants;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
            [weakSelf.aiv stopAnimating];
            //weakSelf.restaurants = @[]; //Uncomment to test no results
            if ([weakSelf.restaurants count]) {
                [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                [self hideNoPhotosMessage];
            } else {
                if (weakSelf.feedType == kFoodFeedTypeFriends) {
                    [weakSelf setNoPhotosMessage:@"Tap here to follow people you trust. Then come back to see dishes and drinks they recommend." target:self selector:@selector(goToConnect) show:YES];
                } else if (weakSelf.feedType == kFoodFeedTypeAroundMe) {
                    [weakSelf setNoPhotosMessage:@"People haven't yet uploaded photos around you. Opportunity? Tap here to add photos from restaurants or bars." target:self selector:@selector(showPickPhotoUI) show:YES];
                } else {
                    [self hideNoPhotosMessage];
                }
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf setNoPhotosMessage:@"There was a problem getting food feed items. Make sure you are connected to the internet and then give it another shot." target:self selector:@selector(refreshFeed) show:YES];
        weakSelf.restaurants = @[ ];
        [weakSelf.collectionView reloadData];
        [weakSelf.aiv stopAnimating];
    }];
}

- (void)goToLocationSettings {
    [Common goToSettings:kAppSettingsLocation];
}

- (void)refreshFeed {
    [_filterView selectCurrent];
}

- (void)hideNoPhotosMessage {
    [self setNoPhotosMessage:@"" target:nil selector:nil show:NO];
}

- (void)setNoPhotosMessage:(NSString *)message target:(id)target selector:(SEL)selector show:(BOOL)show {
    [_noPhotosMessage removeTarget:nil action:nil forControlEvents:UIControlEventAllTouchEvents];
    _noPhotosMessage.hidden = !show;
    [_noPhotosMessage setTitle:message forState:UIControlStateNormal];
    _noPhotosMessage.titleLabel.numberOfLines = 0;
    [_noPhotosMessage addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_noPhotosMessage sizeToFit];
    [_noPhotosMessage setNeedsLayout];
    [_noPhotosMessage setNeedsDisplay];
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
        if (_selectedItem != indexPath.row) return (width(self.view)*4/3)/2;
//        return height(_collectionView);
    }
    
    RestaurantObject *r =[_restaurants objectAtIndex:indexPath.row];
    MediaItemObject *mio = ([r.mediaItems count]) ? [r.mediaItems objectAtIndex:0] : [[MediaItemObject alloc] init];
    if (!mio.width || !mio.height) return width(collectionView)/_numColumns; //NOTE: this should not happen
    CGFloat height = floorf(((width(self.collectionView) - (_numColumns-1) - 2*kGeomSpaceEdge)/_numColumns)*mio.height/mio.width);
    return height + ((mio.source == kMediaItemTypeOomami)? 30:0);
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2), @"mapWidth" : @(width(self.view)),  @"buttonHeight":@(kGeomHeightButton)};
    
    NSDictionary *views;
    views = NSDictionaryOfVariableBindings(_filterView, _collectionView, _noPhotosMessage);

    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_filterView(heightFilters)][_collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_noPhotosMessage(60)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_filterView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_noPhotosMessage]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noPhotosMessage
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_collectionView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noPhotosMessage
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_collectionView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_restaurants count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
    NSUInteger row = indexPath.row;

    RestaurantObject *r = [_restaurants objectAtIndex:row];

    cvc.delegate = self;
    cvc.backgroundColor = UIColorRGBA(kColorTileBackground);
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
    
    [self showExpandedPhoto:mio forRestaurant:r fromRect:frame fromIndexPath:indexPath];
}

- (void)addCaption:(MediaItemObject *)mio {
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    AddCaptionToMIOVC *vc = [[AddCaptionToMIOVC alloc] init];
    vc.delegate = self;
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    vc.mio = mio;
    [vc overrideIsFoodWith:YES];
    
    
    [nc addChildViewController:vc];
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController presentViewController:nc animated:YES completion:^{
        nc.topViewController.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }];
}

- (void)textEntryFinished:(NSString *)text {
//    [_captionButton setTitle:text forState:UIControlStateNormal];
//    [self.view setNeedsLayout];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)showExpandedPhoto:(MediaItemObject *)mio forRestaurant:(RestaurantObject *)restaurant fromRect:(CGRect)originRect fromIndexPath:(NSIndexPath *)indexPath {
    ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];
    vc.originRect = originRect;
    vc.mio = mio;
    vc.restaurant = restaurant;
    vc.delegate = self;
    vc.items = _restaurants;
    vc.currentIndex = indexPath.row;
    //vc.rootViewController = self;
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    self.navigationController.delegate = self;
    vc.dismissTransitionDelegate = self;
    vc.dismissNCDelegate = self;
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
        animator.duration = 0.8;
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
    self.transitioningDelegate = nil;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showProfile:(UserObject *)user {
    ProfileVC *vc = [[ProfileVC alloc] init];
    vc.userInfo = user;
    self.transitioningDelegate = nil;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)photoCell:(PhotoCVCell *)photoCell userNotVerified:(MediaItemObject *)mio {
    UnverifiedUserVC *vc = [[UnverifiedUserVC alloc] initWithSize:CGSizeMake(250, 200)];
    vc.delegate = self;
    vc.action = @"To yum the photo you will need to verify your email.\n\nCheck your email for a verification link.";
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.transitioningDelegate = vc;
    self.navigationController.delegate = vc;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:vc animated:YES completion:^{
        }];
    });
}

- (void)photoCell:(PhotoCVCell *)photoCell likePhoto:(MediaItemObject *)mio {
    
}

- (void)photoCell:(PhotoCVCell *)photoCell showProfile:(UserObject *)userObject {
    ProfileVC *vc = [[ProfileVC alloc] init];
    vc.userInfo = userObject;
    
    self.transitioningDelegate = nil;
    self.navigationController.delegate = nil;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)photoCell:(PhotoCVCell *)photoCell showPhotoOptions:(MediaItemObject *)mio {
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
                [weakSelf refreshFeed];
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
                       [weakSelf.filterView setCurrent:2];
                       [weakSelf addCaption:mio];
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
                                   [weakSelf.filterView setCurrent:2];
                                   [weakSelf addCaption:mio];
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

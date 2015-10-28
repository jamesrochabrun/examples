//
//  RestaurantVC.m
//  ooApp
//
//  Created by Anuj Gujar on 9/14/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <SafariServices/SafariServices.h>
#import "AppDelegate.h"
#import "RestaurantVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "Settings.h"
#import "MediaItemObject.h"
#import "OOTagButton.h"
#import "ListsVC.h"
#import "PhotoCVCell.h"
#import "OOStripHeader.h"
#import "RestaurantListVC.h"
#import "HoursOpen.h"
#import "OOActivityItemProvider.h"
#import <MapKit/MapKit.h>

#import "DebugUtilities.h"

@interface RestaurantVC ()

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UIAlertController *styleSheetAC;
@property (nonatomic, strong) UIAlertController *createListAC;
@property (nonatomic, strong) NSArray *lists;
@property (nonatomic, strong) UserObject* userInfo;
@property (nonatomic, strong) NSMutableSet *listButtons;
@property (nonatomic, strong) UIView *listButtonsContainer;
@property (nonatomic) CGFloat listButtonsContainerHeight;
@property (nonatomic, strong) NSArray *verticalLayoutContraints;
@property (nonatomic, strong) NSArray *mediaItems;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) NSUInteger favoriteID;
@property (nonatomic) NSUInteger toTryID;

@end

static NSString * const kRestaurantMainCellIdentifier = @"RestaurantMainCell";
static NSString * const kRestaurantListsCellIdentifier = @"RestaurantListsCell";
static NSString * const kRestaurantPhotoCellIdentifier = @"RestaurantPhotoCell";
static NSString * const kRestaurantPhotosHeaderIdentifier = @"RestaurantPhotosHeader";

@implementation RestaurantVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _toTryID = 0;
    _favoriteID = 0;
    
    _userInfo = [Settings sharedInstance].userObject;

    _listButtonsContainer = [[UIView alloc] init];
    _listButtonsContainer.backgroundColor = UIColorRGBA(kColorWhite);
    
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
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:@"header" withReuseIdentifier:kRestaurantPhotosHeaderIdentifier];
    
    [self.view addSubview:_collectionView];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.backgroundColor = UIColorRGBA(kColorWhite);
    
    _listButtons = [NSMutableSet set];
    
//    [DebugUtilities addBorderToViews:@[_listButtonsContainer]];
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"listContainerHeight":@(_listButtonsContainerHeight)};
    
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _listButtonsContainer, _collectionView);
    
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
    } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
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
    } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
        NSLog(@"Could add restaurant to list: %@", error);
    }];
}

- (void)setupStyleSheetAC {
    _styleSheetAC = [UIAlertController alertControllerWithTitle:@"Restaurant Options"
                                                           message:@"What would you like to do with this restaurant."
                                                    preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    _styleSheetAC.view.tintColor = [UIColor blackColor];
    
    __weak RestaurantVC *weakSelf = self;
//    UIAlertAction *addToFavorites = [UIAlertAction actionWithTitle:@"Add to Favorites"
//                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//                                                     [self addToFavorites];
//                                                 }];
//    
    UIAlertAction *shareRestaurant = [UIAlertAction actionWithTitle:@"Share Restaurant"
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 [self sharePressed];
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
    
    
//    [_styleSheetAC addAction:addToFavorites];
    [_styleSheetAC addAction:shareRestaurant];
    [_styleSheetAC addAction:addToList];
    [_styleSheetAC addAction:addToNewList];
    [_styleSheetAC addAction:addToEvent];
    [_styleSheetAC addAction:addToNewEvent];
    [_styleSheetAC addAction:cancel];
    
    [self.moreButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sharePressed {
    MediaItemObject *mio;
    if ([_mediaItems count]) {
        mio = [_mediaItems objectAtIndex:0];
        
        OOAPI *api = [[OOAPI alloc] init];
        
        NSString *imageRef = mio.reference;
        
        if (imageRef) {
            _requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:150 maxHeight:0 success:^(NSString *link) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showShare:link];
                });
            } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                ;
            }];
        } else {
            
        }
    }
}

- (void)showShare:(NSString *)url {
    NSURL *nsURL = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:nsURL];
    UIImage *img = [UIImage imageWithData:data];

    OOActivityItemProvider *aip = [[OOActivityItemProvider alloc] initWithPlaceholderItem:@""];
    aip.restaurant = _restaurant;
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:aip, img, nil];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    [avc setValue:[NSString stringWithFormat:@"Take a look at %@", _restaurant.name] forKey:@"subject"];
    [avc setExcludedActivityTypes:
     @[UIActivityTypeAssignToContact,
       UIActivityTypeCopyToPasteboard,
       UIActivityTypePrint,
       UIActivityTypeSaveToCameraRoll,
       UIActivityTypePostToWeibo]];
    [self.navigationController presentViewController:avc animated:YES completion:^{
        ;
    }];
    
    avc.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
    };

}

- (void)addToEvent
{
    [APP.eventBeingEdited addVenue:_restaurant];
}

- (void)removeFromEvent
{
    [APP.eventBeingEdited removeVenue:_restaurant];
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
    } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
        ;
    }];
}

- (void)getListsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    [api getListsOfUser:_userInfo.userID  withRestaurant:_restaurant.restaurantID
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user:  %ld", ( long) foundLists.count);
                    _lists = foundLists;
                    _toTryID = _favoriteID = 0;
                    [_lists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        ListObject *lo = (ListObject *)obj;
                        if (lo.type == kListTypeFavorites) {
                            _favoriteID = lo.listID;
                        } else if (lo.type == kListTypeToTry) {
                            _toTryID = lo.listID;
                        }
                        OOTagButton *b = [[OOTagButton alloc] init];
                        b.icon = kFontIconList;
                        b.name = [lo.name uppercaseString];
                        b.theId = lo.listID;
                        [_listButtons addObject:b];
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf displayListButtons];
                    });
                }
                failure:^(AFHTTPRequestOperation* operation, NSError *e) {
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
    } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
        ;
    }];

}
     
- (void)gotMediaItems {
    [_collectionView reloadData];
}

- (void)displayListButtons {
    __block CGPoint origin = CGPointMake(kGeomSpaceInter, kGeomSpaceInter);
    NSArray *listButtonsArray = [_listButtons allObjects];
    _listButtonsContainerHeight = 0;
    [listButtonsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OOTagButton *b = (OOTagButton *)obj;
        [b addTarget:self action:@selector(showList:) forControlEvents:UIControlEventTouchUpInside];
        [_listButtonsContainer addSubview:b];
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
        _listButtonsContainerHeight = CGRectGetMaxY(b.frame);
    }];
    _listButtonsContainerHeight += (_listButtonsContainerHeight) ? kGeomSpaceInter : 0;
    [self.view setNeedsUpdateConstraints];
    [_collectionView reloadData];
}

- (void)viewDidLayoutSubviews {
    _listButtonsContainer.frame = CGRectMake(kGeomSpaceEdge, 0, width(self.view)-2*kGeomSpaceEdge, _listButtonsContainerHeight);
//    NSLog(@"_listButtonsContainer=%@", _listButtonsContainer);
}

- (void)showList:(id)sender {
    OOTagButton *rb = (OOTagButton *)sender;
    RestaurantListVC *vc = [[RestaurantListVC alloc] init];
    [_lists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ListObject *lo = (ListObject *)obj;
        if (lo.listID == rb.theId) {
            vc.listItem = lo;
            *stop = YES;
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)removeFromList:(NSUInteger)listID {
    OOAPI *api = [[OOAPI alloc] init];
    
    OOTagButton *buttonToRemove;
    for (OOTagButton *b in [_listButtons allObjects]) {
        if (b.theId == listID) buttonToRemove = b;
    }
    
    if (buttonToRemove) {
        [buttonToRemove removeFromSuperview];
        [_listButtons removeObject:buttonToRemove];
    }
    
    __weak RestaurantVC *weakSelf = self;
    [api deleteRestaurant:_restaurant.restaurantID fromList:listID success:^(NSArray *lists) {
        ON_MAIN_THREAD(^{
            [weakSelf getListsForRestaurant];
        });
    } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
        ;
    }];
}

- (void)addToFavorites {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    
    [api addRestaurantsToSpecialList:@[_restaurant] listType:kListTypeFavorites success:^(id response) {
        [weakSelf getListsForRestaurant];
    } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
        ;
    }];
}

- (void)addToTryList {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    
    [api addRestaurantsToSpecialList:@[_restaurant] listType:kListTypeToTry success:^(id response) {
        [weakSelf getListsForRestaurant];
    } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
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
            cvc.restaurant = _restaurant;
            cvc.delegate = self;
            [cvc setToTry:(_toTryID) ? YES: NO];
            [cvc setFavorite:(_favoriteID) ? YES: NO];
            if ([_mediaItems count]) {
                cvc.mediaItemObject = [_mediaItems objectAtIndex:0];
            }
            return cvc;
            break;
        }
        case kSectionTypeLists: {
            UICollectionViewCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kRestaurantListsCellIdentifier forIndexPath:indexPath];
            cvc.backgroundColor = UIColorRGBA(kColorWhite);
            [cvc addSubview:_listButtonsContainer];
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
            return _listButtonsContainerHeight;
            break;
        case kSectionTypeMain:
            return 160;
            break;
        case kSectionTypeMediaItems: {
            MediaItemObject *mio = [_mediaItems objectAtIndex:indexPath.row];
            if (!mio.width || !mio.height) return width(collectionView)/kNumColumnsForMediaItems; //NOTE: this should not happen
            return floorf((width(self.collectionView) - (kNumColumnsForMediaItems-1) - 2*kGeomSpaceEdge)/kNumColumnsForMediaItems*mio.height/mio.width);
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
    UICollectionReusableView *reuseView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kRestaurantPhotosHeaderIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == kSectionTypeMediaItems) {
        OOStripHeader *header = [[OOStripHeader alloc] init];
        header.frame = CGRectMake(0, 0, width(self.view), 27);
        header.name = @"PHOTOS";
        [header enableAddButtonWithTarget:self action:@selector(addPhoto)];
        [reuseView addSubview:header];
        [collectionView bringSubviewToFront:reuseView];
     }
    return reuseView;
}

- (void)addPhoto {
    
    OOAPI *api = [[OOAPI alloc] init];
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

#pragma mark -
- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell gotoURL:(NSURL *)url {
    SFSafariViewController *svc  = [[SFSafariViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell listButtonTapped:(ListType)listType {
    if (listType == kListTypeFavorites) {
        if (_favoriteID) {
            [self removeFromList:_favoriteID];
        } else {
            [self addToFavorites];
        }
    } else if (listType == kListTypeToTry) {
        if (_toTryID) {
            [self removeFromList:_toTryID];
        } else {
            [self addToTryList];
        }
    }
}

- (void)showOnMap:(CLLocationCoordinate2D)location {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f",location.latitude, location.longitude]];
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        NSLog(@"Google Maps app is not installed");
        //Apple Maps, using the MKMapItem class
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = @"ReignDesign Office";
        [item openInMapsWithLaunchOptions:nil];
        //left as an exercise for the reader: open the Google Maps mobile website instead!
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end

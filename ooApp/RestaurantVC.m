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
//#import "MWPhotoBrowser.h"
#import "MediaItemObject.h"
#import "OOUserView.h"
#import "ProfileVC.h"
#import "EventSelectionVC.h"
#import <MapKit/MapKit.h>
#import "ShowMediaItemAnimator.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

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
@property (nonatomic, strong) NSArray *followees;
@property (nonatomic) BOOL listsNeedUpdate;
@property (nonatomic, strong) UINavigationController *aNC;
@end

static NSString *const kRestaurantMainCellIdentifier = @"RestaurantMainCell";
static NSString *const kRestaurantListsCellIdentifier = @"RestaurantListsCell";
static NSString *const kRestaurantPhotoCellIdentifier = @"RestaurantPhotoCell";
static NSString *const kRestaurantPhotosHeaderIdentifier = @"RestaurantPhotosHeader";

@implementation RestaurantVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
    [self updateIfNeeded];
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _toTryID = 0;
    _favoriteID = 0;
    
    _userInfo = [Settings sharedInstance].userObject;
    
    _listButtonsContainer = [[UIView alloc] init];
    _listButtonsContainer.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
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
    _collectionView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _listButtons = [NSMutableSet set];
    
    _listsNeedUpdate = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setListsUpdateNeeded)
                                                 name:kNotificationRestaurantListsNeedsUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePhotoDeleted:)
                                                 name:kNotificationPhotoDeleted object:nil];
    [self.view bringSubviewToFront:self.uploadProgressBar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRestaurantListsNeedsUpdate object:nil];
}

- (void)setListsUpdateNeeded {
    _listsNeedUpdate = YES;
}

- (void)handlePhotoDeleted:(NSNotification*)not {
    [self getMediaItemsForRestaurant];
}

- (void)updateIfNeeded {
    if (_listsNeedUpdate) {
        [self removeAllButtons];
        [self getListsForRestaurant];
        _listsNeedUpdate = NO;
    }
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"listContainerHeight":@(_listButtonsContainerHeight), @"buttonDimensions":@(kGeomDimensionsIconButton)};
    
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
    __weak RestaurantVC *weakSelf = self;
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
    __weak RestaurantVC *weakSelf = self;
    [api addRestaurants:@[_restaurant] toList:list.listID success:^(id response) {
        ON_MAIN_THREAD(^{
            [weakSelf getListsForRestaurant];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Could add restaurant to list: %@", error);
    }];
}

- (void)setupStyleSheetAC {
    _styleSheetAC = [UIAlertController alertControllerWithTitle:@"Restaurant Options"
                                                        message:@"What would you like to do with this restaurant."
                                                 preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    _styleSheetAC.view.tintColor = UIColorRGBA(kColorBlack);
    
    __weak RestaurantVC *weakSelf = self;
    
    //    UIAlertAction *shareRestaurant = [UIAlertAction actionWithTitle:@"Share Restaurant"
    //                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
    //                                                                  [self sharePressed];
    //                                                              }];
    
    UIAlertAction *addToList = [UIAlertAction actionWithTitle:(_listToAddTo) ? [NSString stringWithFormat:@"Add to \"%@\"", _listToAddTo.name] : @"Add/Remove from List"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            [self addToList];
                                                        }];
    UIAlertAction *addToEvent = nil;
    UIAlertAction *removeFromEvent = nil;
    if ( self.eventBeingEdited) {
        NSString* name= self.eventBeingEdited.name ?: @"";
        name=[name substringToIndex: MIN(5,[name length])];
        name=concatenateStrings(name, @"…");
        
        if (  ![self.eventBeingEdited alreadyHasVenue: _restaurant ] ) {
            NSString* message = concatenateStrings(LOCAL(@"Add to "), name);
            addToEvent= [UIAlertAction actionWithTitle: message
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   NSLog(@"Add to Event");
                                                   [weakSelf addToEvent];
                                               }];
        } else {
            NSString* message=concatenateStrings(LOCAL(@"Remove from "), name);
            
            // XX:  need ability to remove a restaurant from an event
            removeFromEvent= [UIAlertAction actionWithTitle: message
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        NSLog(@"Remove from Event");
                                                        [weakSelf removeFromEvent];
                                                    }];
            
        }
    } else {
        addToEvent= [UIAlertAction actionWithTitle: LOCAL(@"Add to Existing Event")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               NSLog(@"Add to Existing Event");
                                               [weakSelf addToExistingEvent];
                                           }];
        
    }
    
//    UIAlertAction *addToNewEvent = [UIAlertAction actionWithTitle:@"New Event at..."
//                                                            style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                              NSLog(@"Add to New Event");
//                                                              [weakSelf addToNewEvent];
//                                                          }];
    UIAlertAction *addToNewList = [UIAlertAction actionWithTitle:@"Add to New List..."
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             NSLog(@"Add to New List");
                                                             [weakSelf createListPressed];
                                                         }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       NSLog(@"Cancel");
                                                   }];
    
    //    [_styleSheetAC addAction:shareRestaurant];
    [_styleSheetAC addAction:addToList];
    [_styleSheetAC addAction:addToNewList];
#if 0
    if (addToEvent) {
        [_styleSheetAC addAction:addToEvent];
    }
    if ( removeFromEvent) {
        [_styleSheetAC addAction:removeFromEvent];
    }
    [_styleSheetAC addAction:addToNewEvent];
#endif
    [_styleSheetAC addAction:cancel];
    [self setRightNavWithIcon:kFontIconPhoto target:self action:@selector(showPickPhotoUI)];
}

- (void)sharePressed:(id)sender {
    MediaItemObject *mio;
    if ([_mediaItems count]) {
        mio = [_mediaItems objectAtIndex:0];
        
        OOAPI *api = [[OOAPI alloc] init];
        
        if (mio) {
            _requestOperation = [api getRestaurantImageWithMediaItem:mio maxWidth:150 maxHeight:0 success:^(NSString *link) {
                [self showShare:link fromView:sender];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self showShare:nil fromView:sender];
            }];
        } else {
            [self showShare:nil fromView:sender];
        }
    } else {
        [self showShare:nil fromView:sender];
    }
}

- (void)showShare:(NSString *)url fromView:(id)sender {
    NSURL *nsURL = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:nsURL];
    UIImage *img = [UIImage imageWithData:data];
    
    OOActivityItemProvider *aip = [[OOActivityItemProvider alloc] initWithPlaceholderItem:@""];
    aip.restaurant = _restaurant;
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:aip, img, nil];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    avc.popoverPresentationController.sourceView = sender;
    avc.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
    
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

-(void)addToExistingEvent
{
    EventSelectionVC *vc=[[EventSelectionVC alloc]init];
    vc.restaurantBeingAdded = _restaurant;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) addToNewEvent
{
    __weak RestaurantVC* weakSelf= self;

    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"New Event")
                                                              message:LOCAL(@"Enter a name for the new event")
                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    [a addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder=@"Event Name";
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style: UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Create"
                                                 style: UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action)
                         {
                             UITextField *textField = a.textFields.firstObject;
                             
                             [textField resignFirstResponder];
                             
                             NSString *string = trimString(textField.text);
                             if  (string.length ) {
                                 string = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] uppercaseString]];
                             }
                             
                             NSUInteger userid= [Settings sharedInstance].userObject.userID;
                             EventObject *e= [[EventObject alloc] init];
                             e.name=  string;
                             e.numberOfPeople= 1;
                             e.createdAt= [NSDate date];
                             e.creatorID= userid;
                             e.updatedAt= [NSDate date];
                             e.eventType= EVENT_TYPE_USER;
                             self.eventBeingEdited= e;
                             
                             __weak EventObject *weakEvent = e;
                             [OOAPI addEvent: e
                                     success:^(NSInteger eventID) {
                                         NSLog  (@"EVENT %lu CREATED FOR USER %lu", (unsigned long)eventID, ( unsigned long)userid);
                                         self.eventBeingEdited= weakEvent;
                                         weakEvent.eventID= eventID;
                                         
                                         [weakEvent addVenue: weakSelf.restaurant completionBlock:^(BOOL success) {
                                             EventCoordinatorVC *vc= [[EventCoordinatorVC alloc] init];
                                             vc.eventBeingEdited= weakEvent;
                                             [weakSelf.navigationController pushViewController:vc animated:YES];
                                         }];
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog  (@"%@", error);
                                         message( @"backend was unable to create a new event");
                                     }];
                         }];
    
    [a addAction:cancel];
    [a addAction:ok];
    
    [self presentViewController:a animated:YES completion:nil];
}

- (void)addToEvent
{
    NSInteger remaining=kMaximumRestaurantsPerEvent-[self.eventBeingEdited numberOfVenues ];
    
    if  ([self.eventBeingEdited alreadyHasVenue: _restaurant ] ) {
        NSString*string= [NSString   stringWithFormat:  @"You've added this restaurant to %@. You can add %ld more restaurants to this event.", self.eventBeingEdited.name,
                          (long)remaining
                          ];
        message(string );
    }
    if ( self.eventBeingEdited.numberOfVenues >= kMaximumRestaurantsPerEvent) {
        message( @"Cannot add more restaurants to event, maximum reached.");
        return;
    }
    
    EventObject* e= self.eventBeingEdited;
    [e addVenue:_restaurant];
    
    [self.navigationController  popViewControllerAnimated:YES];
}

- (void)removeFromEvent
{
    [self.eventBeingEdited removeVenue:_restaurant];
    [self.navigationController  popViewControllerAnimated:YES];
}

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreButtonPressed:(id)sender
{
    _styleSheetAC.popoverPresentationController.sourceView = sender;
    _styleSheetAC.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
    [self presentViewController:_styleSheetAC animated:YES completion:nil];
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
    __weak RestaurantVC *weakSelf = self;
    OOAPI *api = [[OOAPI alloc] init];
    
    [api getRestaurantWithID:_restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
        _restaurant = restaurant;
        ON_MAIN_THREAD(^{
            [_collectionView reloadData];// Sections:is];
            [weakSelf getListsForRestaurant];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)getFolloweesWithRestaurantOnList {
    __weak RestaurantVC *weakSelf = self;
    
    [OOAPI getFolloweesForRestaurant:_restaurant success:^(NSArray *users) {
        weakSelf.followees = users;
        ON_MAIN_THREAD(^{
            [_collectionView reloadData];// Sections:is];
            [weakSelf getMediaItemsForRestaurant];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ON_MAIN_THREAD(^{
            [weakSelf getMediaItemsForRestaurant];;
        });
    }];
}

- (void)getListsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    [api getListsOfUser:_userInfo.userID
         withRestaurant:_restaurant.restaurantID
             includeAll:YES
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
                        switch (lo.type) {
                            case kListTypeFavorites:
                                b.icon = kFontIconFavoriteFilled;
                                break;
                            case kListTypeToTry:
                                b.icon = kFontIconToTryFilled;
                                break;
                            default:
                                b.icon = kFontIconList;
                                break;
                        }

                        b.name = [lo.listName uppercaseString];
                        b.theId = lo.listID;
                        [_listButtons addObject:b];
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf displayListButtons];
                    });
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                    NSLog  (@" error while getting lists for user:  %@",e);
                    ON_MAIN_THREAD(^{
                        [self getFolloweesWithRestaurantOnList];
                    });
                }];
}

- (void)getMediaItemsForRestaurant {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    [api getMediaItemsForRestaurant:_restaurant success:^(NSArray *mediaItems) {
        _mediaItems = mediaItems;
        ON_MAIN_THREAD(^{
            [weakSelf gotMediaItems];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)gotMediaItems {
    NSMutableIndexSet *is = [NSMutableIndexSet indexSetWithIndex:kRestaurantSectionTypeMediaItems];
    [is addIndex:kRestaurantSectionTypeMain];
    [_collectionView reloadSections:is];
}

- (void)displayListButtons {
    __block CGPoint origin = CGPointMake(0/*kGeomSpaceInter*/, 0 /*kGeomSpaceInter*/);
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
            frame.origin.x =0;// kGeomSpaceInter;
        }
        
        b.frame = frame;
        
        origin.x = CGRectGetMaxX(frame) + kGeomSpaceEdge;
        _listButtonsContainerHeight = CGRectGetMaxY(b.frame);
    }];
    //_listButtonsContainerHeight += (_listButtonsContainerHeight) ? kGeomSpaceInter : 0;
    [self.view setNeedsUpdateConstraints];

    ON_MAIN_THREAD(^{
        [_collectionView reloadData];// Sections:is];
        [self getFolloweesWithRestaurantOnList];
    });
}

- (void)viewDidLayoutSubviews {
    _listButtonsContainer.frame = CGRectMake(0, 0, width(self.view)-2*kGeomSpaceEdge, _listButtonsContainerHeight);
    //    NSLog(@"_listButtonsContainer=%@", _listButtonsContainer);
    self.uploadProgressBar.frame = CGRectMake(0, 0, width(self.view), 2);
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

- (void)removeAllButtons {
    for (OOTagButton *b in [_listButtons allObjects]) {
        [b removeFromSuperview];
    }
    [_listButtons removeAllObjects];
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)addToFavorites {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantVC *weakSelf = self;
    
    [api addRestaurantsToSpecialList:@[_restaurant] listType:kListTypeFavorites success:^(id response) {
        [weakSelf getListsForRestaurant];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)addToList {
    if (_listToAddTo) {
        [self addRestaurantToList:_listToAddTo];
    } else {
        [self showLists];
    }
}

- (void)showLists {
    ListsVC *vc = [[ListsVC alloc] init];
    vc.restaurantToAdd = _restaurant;
    [vc getLists];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Collection View stuff

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case kRestaurantSectionTypeMain:
            return 1;
            break;
        case kRestaurantSectionTypeLists:
            return ([_listButtons count]) ? 1 : 0;
            break;
        case kRestaurantSectionTypeMediaItems:
            return [self numberOfMediaItemsToDisplay];
            break;
        case kRestaurantSectionTypeFollowees:
            return [_followees count];
            break;
    }
    return 0;
}

//A count of all Oomami Items + other Media Items to make the total at least 10
- (NSUInteger)numberOfMediaItemsToDisplay {

    NSUInteger numItems = 0;
    for (MediaItemObject *mio in _mediaItems) {
        if (numItems >= 10 && mio.source == kMediaItemTypeGoogle)
            break;
        numItems++;
    }
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSUInteger userID = [Settings sharedInstance].userObject.userID;
    
    switch (indexPath.section) {
        case kRestaurantSectionTypeMain: {
            RestaurantMainCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kRestaurantMainCellIdentifier forIndexPath:indexPath];
            cvc.restaurant = _restaurant;
            cvc.delegate = self;
            [cvc setFavorite:(_favoriteID) ? YES: NO];
            cvc.mediaItemObject = ([_mediaItems count]) ? [_mediaItems objectAtIndex:0] : nil;
            //[DebugUtilities addBorderToViews:@[cvc]];
            return cvc;
            break;
        }
        case kRestaurantSectionTypeFollowees: {
            UICollectionViewCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kRestaurantListsCellIdentifier forIndexPath:indexPath];
            cvc.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
            OOUserView *uv = [[OOUserView alloc] init];
            uv.delegate = self;
            uv.user = [_followees objectAtIndex:indexPath.row];
            uv.frame = CGRectMake(0, 0, 50, 50);
            [cvc addSubview:uv];
            //[DebugUtilities addBorderToViews:@[cvc]];
            return cvc;
            break;
        }
        case kRestaurantSectionTypeLists: {
            UICollectionViewCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kRestaurantListsCellIdentifier forIndexPath:indexPath];
            cvc.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
            [cvc addSubview:_listButtonsContainer];
            //[DebugUtilities addBorderToViews:@[cvc]];
            return cvc;
            break;
        }
        case kRestaurantSectionTypeMediaItems: {
            PhotoCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kRestaurantPhotoCellIdentifier forIndexPath:indexPath];
            cvc.delegate = self;
            cvc.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
            MediaItemObject *mio = [_mediaItems objectAtIndex:indexPath.row];
            cvc.mediaItemObject = mio;
            [cvc showActionButton:NO];
            //[DebugUtilities addBorderToViews:@[cvc]];
            return cvc;
            break;
        }
        default:
            break;
    }
    
    return nil;
}

- (void)photoCell:(PhotoCVCell *)photoCell likePhoto:(MediaItemObject *)mio {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFoodFeedNeedsUpdate object:nil];
}

- (void)photoCell:(PhotoCVCell *)photoCell showProfile:(UserObject *)uo {
    ProfileVC *vc = [[ProfileVC alloc] init];
    vc.userInfo = uo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)photoCell:(PhotoCVCell *)photoCell showPhotoOptions:(MediaItemObject *)mio {
//    UIAlertController *showPhotoOptions = [UIAlertController alertControllerWithTitle:@"" message:@"What would you like to do with this photo?" preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
//                                                     style:UIAlertActionStyleCancel
//                                                   handler:^(UIAlertAction * action) {
//                                                         NSLog(@"Cancel");
//                                                     }];
//    
//    [_showPhotoOptions addAction:cancel];
//    
//    [self presentViewController:_showPhotoOptions animated:YES completion:^{
//        ;
//    }];
}

- (void)addCaption:(MediaItemObject *)mio forceIsFoodFeed:(BOOL)overrideFoodFeed {
    _aNC = [[UINavigationController alloc] init];
    
    AddCaptionToMIOVC *vc = [[AddCaptionToMIOVC alloc] init];
    vc.delegate = self;
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    vc.mio = mio;
    
    //when uploading a photo force the is food feed value, don't force if the user is just editing the caption
    if (overrideFoodFeed) {
        [vc overrideIsFoodWith:YES];
    }
    
    [_aNC addChildViewController:vc];
    [_aNC.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    [_aNC.navigationBar setShadowImage:[UIImage imageWithColor:UIColorRGBA(kColorBordersAndLines)]];
    [_aNC.navigationBar setTranslucent:YES];
    _aNC.view.backgroundColor = [UIColor clearColor];

    [self.navigationController presentViewController:_aNC animated:YES completion:^{
        _aNC.topViewController.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }];
}

- (void)textEntryFinished:(NSString *)text {
    [self dismissViewControllerAnimated:YES completion:^{
        [self getMediaItemsForRestaurant];
    }];
}

- (void)ooTextEntryVC:(AddCaptionToMIOVC *)textEntryVC textToSubmit:(NSString *)text {
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kRestaurantSectionTypeNumberOfSections;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RestaurantVCCVL *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case kRestaurantSectionTypeLists:
            return _listButtonsContainerHeight;
            break;
        case kRestaurantSectionTypeFollowees:
            return 50;
            break;
        case kRestaurantSectionTypeMain:
            return 200;
            break;
        case kRestaurantSectionTypeMediaItems: {
            MediaItemObject *mio = [_mediaItems objectAtIndex:indexPath.row];
            if (!mio.width || !mio.height) return width(collectionView)/kRestaurantNumColumnsForMediaItems; //NOTE: this should not happen
            CGFloat height = floorf(((width(self.collectionView) - (kRestaurantNumColumnsForMediaItems-1) - 2*kGeomSpaceEdge)/kRestaurantNumColumnsForMediaItems)*mio.height/mio.width);
            return height + ((mio.source == kMediaItemTypeOomami)? 30:0);
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

    [[reuseView viewWithTag:111] removeFromSuperview];
    if (indexPath.section == kRestaurantSectionTypeMediaItems) {
        OOStripHeader *header = [[OOStripHeader alloc] init];
        header.name = @"Photos";
        header.frame = CGRectMake(0, 0, width(self.view), kGeomStripHeaderHeight);
        header.tag = 111;
        [collectionView bringSubviewToFront:reuseView];
        [reuseView addSubview:header];
        [header setNeedsLayout];
        //[DebugUtilities addBorderToViews:@[reuseView, header]];
    } else if (indexPath.section == kRestaurantSectionTypeLists) {
        OOStripHeader *header = [[OOStripHeader alloc] init];
        header.name = @"On Your Lists";
        header.frame = CGRectMake(0, 0, width(self.view), kGeomStripHeaderHeight);
        header.tag = 111;
        [collectionView bringSubviewToFront:reuseView];
        [reuseView addSubview:header];
        [header setNeedsLayout];
        //[DebugUtilities addBorderToViews:@[reuseView, header]];
    } else if (indexPath.section == kRestaurantSectionTypeFollowees) {
        OOStripHeader *header = [[OOStripHeader alloc] init];
        header.name = @"On Their Lists";
        header.frame = CGRectMake(0, 0, width(self.view), kGeomStripHeaderHeight);
        header.tag = 111;
        [collectionView bringSubviewToFront:reuseView];
        [reuseView addSubview:header];
        [header setNeedsLayout];
        //[DebugUtilities addBorderToViews:@[reuseView]];
    }
    return reuseView;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kRestaurantSectionTypeMediaItems) {
        MediaItemObject *mio = [_mediaItems objectAtIndex:indexPath.row];
        UIView *v = [collectionView cellForItemAtIndexPath:indexPath];
        CGRect originRect = v.frame;
        originRect.origin.y += kGeomHeightNavBarStatusBar;
        
        ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];
        vc.originRect = originRect;
        vc.mio = mio;
        vc.restaurant = _restaurant;
        vc.delegate = self;
        
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.transitioningDelegate = self;
        self.navigationController.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];

//        NSUInteger row = indexPath.row;
//        __weak RestaurantVC *weakSelf = self;
//        MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:weakSelf];
//        [photoBrowser setCurrentPhotoIndex:row];
//        __weak MediaItemObject *mio = [_mediaItems objectAtIndex:row];
//        
//        OOAPI *api = [[OOAPI alloc] init];
//        [api getRestaurantImageWithMediaItem:[_mediaItems objectAtIndex:row] maxWidth:width(self.view) maxHeight:0 success:^(NSString *link) {
//            mio.url = link;
//            ON_MAIN_THREAD(^ {
//                [self.navigationController pushViewController:photoBrowser animated:YES];
//            });
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            ;
//        }];
    }
}

- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showProfile:(UserObject *)user {
    ProfileVC *vc = [[ProfileVC alloc] init];
    vc.userID = user.userID;
    vc.userInfo = user;
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
//        animator.duration = 0.8;
        animationController = animator;
    } else if ([fromVC isKindOfClass:[ViewPhotoVC class]] && operation == UINavigationControllerOperationPop) {
        ShowMediaItemAnimator *animator = [[ShowMediaItemAnimator alloc] init];
        ViewPhotoVC *vc = (ViewPhotoVC *)fromVC;
        animator.presenting = NO;
        animator.originRect = vc.originRect;
//        animator.duration = 0.6;
        animationController = animator;
    } else {
        
    }
    
    return animationController;
}

//#pragma MWPhotoBrowser delegates
//
//- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
//    return [_mediaItems count];
//}
//
//- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
//    if (index < _mediaItems.count) {
//        MediaItemObject *mio = [_mediaItems objectAtIndex:index];
//        MWPhoto *photo;
//        if (mio.url) {
//            photo = [[MWPhoto alloc] initWithURL:[NSURL URLWithString:mio.url]];
//            [photo performLoadUnderlyingImageAndNotify];
//            photo.caption = mio.caption;
//            return photo;
//        } else if (mio.source == kMediaItemTypeGoogle && mio.reference) {
//            OOAPI *api = [[OOAPI alloc] init];
//            NSLog(@"mio reference= %@", mio.reference);
//            
//            __weak MWPhotoBrowser *weakPhotoBrowser = photoBrowser;
//            
//            [api getRestaurantImageWithMediaItem:mio
//                                        maxWidth:width(self.view)
//                                       maxHeight:0
//                                         success:^(NSString *link) {
//                                             mio.url = link;
//                                             ON_MAIN_THREAD(^ {
//                                                 if (link) {
//                                                     [weakPhotoBrowser.delegate photoBrowser:weakPhotoBrowser photoAtIndex:index];
//                                                 }
//                                             });
//                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                             ;
//                                         }];
//            return nil;
//        }
//        
//    }
//    return nil;
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -
- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user {
    ProfileVC *vc = [[ProfileVC alloc] init];
    vc.userID = user.userID;
    vc.userInfo = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)restaurantMainCVCellMorePressed:(id)sender {
    [self moreButtonPressed:sender];
}

- (void)restaurantMainCVCellSharePressed:(id)sender {
    [self sharePressed:sender];
}

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
        }
    }
}

- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell showMapTapped:(CLLocationCoordinate2D)coordinate {
    [self showOnMap:coordinate];
}

- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell showListSearchingKeywords:(NSArray *)keywords {
    RestaurantListVC *vc = [[RestaurantListVC alloc] init];
    ListObject *list = [[ListObject alloc] init];
    list.name = [keywords firstObject];
    list.listDisplayType = KListDisplayTypeStrip;
    
    vc.listItem = list;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showOnMap:(CLLocationCoordinate2D)location {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f",location.latitude, location.longitude]];
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        NSLog(@"Google Maps app is not installed");
        //Apple Maps, using the MKMapItem class
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = _restaurant.name;
        [item openInMapsWithLaunchOptions:nil];
        //left as an exercise for the reader: open the Google Maps mobile website instead!
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)showPickPhotoUI
{
    BOOL haveCamera = NO, havePhotoLibrary = NO;
    haveCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? YES : NO;
    havePhotoLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ? YES : NO;
    UIAlertController *addPhoto = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Add Photo for %@", _restaurant.name]
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
    
    if (havePhotoLibrary && haveCamera )[self presentViewController:addPhoto animated:YES completion:nil];
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
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    CGSize s = image.size;
    UIImage *newImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(kGeomUploadWidth, kGeomUploadWidth*s.height/s.width)];
    
    self.uploading = YES;
    self.uploadProgressBar.hidden = NO;
    
    __weak RestaurantVC *weakSelf = self;
    [OOAPI uploadPhoto:newImage forObject:_restaurant
               success:^(MediaItemObject *mio){
                   weakSelf.uploading = NO;
                   dispatch_async(dispatch_get_main_queue(), ^{
                       weakSelf.uploadProgressBar.hidden = YES;
                       [self addCaption:mio forceIsFoodFeed:YES];
                   });
               } failure:^(NSError *error) {
                   weakSelf.uploading = NO;
                   dispatch_async(dispatch_get_main_queue(), ^{
                       weakSelf.uploadProgressBar.hidden = YES;
                   });
               } progress:^(NSUInteger __unused bytesWritten,
                          long long totalBytesWritten,
                          long long totalBytesExpectedToWrite) {
                   long double d= totalBytesWritten;
                   d/=totalBytesExpectedToWrite;
                   dispatch_async(dispatch_get_main_queue(), ^{
                       weakSelf.uploadProgressBar.progress = (float)d;
                   });
               }];

    [weakSelf dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

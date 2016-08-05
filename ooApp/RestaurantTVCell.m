//
//  RestaurantTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 9/24/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantTVCell.h"
#import "LocationManager.h"
#import "ListsVC.h"
#import "OOActivityItemProvider.h"
#import "OOUserView.h"
#import "DebugUtilities.h"
#import "NSString+Util.h"

@interface RestaurantTVCell ()
@property (nonatomic, strong) UIAlertController *restaurantOptionsAC;
@property (nonatomic, strong) UIAlertController *createListAC;
@property (nonatomic, assign) NSUInteger mode;
@property (nonatomic, strong) NSArray *followees;
@property (nonatomic, strong) UIView *followeesView;
@property (nonatomic, strong) UILabel *numberAdditionalFollowees;
@property (nonatomic, strong) AFHTTPRequestOperation *roFollowes;
@property (nonatomic, strong) AFHTTPRequestOperation *roRestaurant;
@property (nonatomic, strong) AFHTTPRequestOperation *roMIO;
@property (nonatomic, strong) MediaItemObject *mio;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *open;
@end

typedef enum {
    kActionButtonModeNone = 0,
    kActionButtonModeAdd = 1,
    kActionButtonModeRemove = 2,
    kActionButtonModeModal = 3,
    kActionButtonModeAddToList = 4
} kActionButtonMode;

@implementation RestaurantTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _followeesView = [UIView new];
        [self addSubview:_followeesView];
        
        _numberAdditionalFollowees = [UILabel new];
        [_numberAdditionalFollowees withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorBlack backgroundColor:kColorClear];
//        [DebugUtilities addBorderToViews:@[self.subHeader2, _followeesView, _numberAdditionalFollowees]];
    }
    return self;
}

- (void)setRestaurant:(RestaurantObject *)restaurant
{
    if (restaurant == _restaurant) return;
    _restaurant = restaurant;
    
    self.thumbnail.image = [UIImage imageNamed:@"background-image.jpg"];
    self.header.text = [self headerString];
    
    _open = _restaurant.isOpen==kRestaurantOpen ? @"Open Now" :
                            (_restaurant.isOpen==kRestaurantClosed? @"Not Open" : @"");
    _rating = _restaurant.rating ? [NSString stringWithFormat:@"%0.1f rating", _restaurant.rating] : @"";
        
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantTVCell *weakSelf = self;
    
    if (_restaurant && !_restaurant.restaurantID) {
        _roRestaurant = [api getRestaurantWithID:_restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
            _restaurant = restaurant;
            if (_restaurant.restaurantID) {
                [weakSelf addFolloweesWithRestaurant];
                [weakSelf updateThumbnail];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.subHeader1.text = [weakSelf subheader1String];
                    [self.subHeader1 sizeToFit];
                    weakSelf.subHeader2.text = [weakSelf subheader2String];
                    [self.subHeader2 sizeToFit];
                });
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog  (@"ERROR UNABLE TO IDENTIFY VENUE: %@",error);
        }];
    } else { //AUG we should have a check here
        [self addFolloweesWithRestaurant];
        [self updateThumbnail];
        self.subHeader1.text = [self subheader1String];
        [self.subHeader1 sizeToFit];
        self.subHeader2.text = [self subheader2String];
        [self.subHeader2 sizeToFit];
    }
    [self setupActionButton];
}

- (void)updateThumbnail {
    __weak RestaurantTVCell *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.restaurant.mediaItems count]) {
            [weakSelf setThumbnailImage:[weakSelf.restaurant.mediaItems objectAtIndex:0]];
        } else {
            weakSelf.thumbnail.image = [UIImage imageNamed:@"background-image.jpg"];
        }
    });    
}

- (void)setThumbnailImage:(MediaItemObject *)mio {
    OOAPI *api = [[OOAPI alloc] init];
    
    self.requestOperation =
    [api getRestaurantImageWithMediaItem:mio
                                maxWidth:width(self)
                               maxHeight:0
                                 success:^(NSString *link) {
                                     __weak UIImageView *weakIV = self.thumbnail;
                                     __weak RestaurantTVCell *weakSelf = self;
                                     [weakSelf.thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                                               placeholderImage:[UIImage imageNamed:@"background-image.jpg"]
                                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       [UIView transitionWithView:weakIV duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                                                           weakIV.image = image;
                                                                                                        } completion:^(BOOL finished) {
                                                                                                            ;
                                                                                                        }];
                                                                       [weakSelf setNeedsUpdateConstraints];
                                                                       [weakSelf setNeedsLayout];
                                                                                                    });
                                                                                                }
                                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                   weakIV.image = [UIImage imageNamed:@"background-image.jpg"];
                                                               }];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            ;
                        }];
}

- (void)addFolloweesWithRestaurant {
    __weak RestaurantTVCell *weakSelf = self;
    if (!_restaurant.restaurantID) {
        NSLog(@"rest=%@", _restaurant.name);
    }
    _roFollowes = [OOAPI getFolloweesForRestaurant:_restaurant success:^(NSArray *users) {
        weakSelf.followees = users;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf gotFollowees];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf gotFollowees];
        });
    }];
}

- (void)gotFollowees {
    NSUInteger index = 0;
    NSUInteger count = [_followees count];
    for (UserObject *u in _followees) {
        OOUserView *uv = [[OOUserView alloc] init];
        uv.user = u;
        uv.frame = CGRectMake(33*index, 0, 30, 30);
        [_followeesView addSubview:uv];
        index++;
        if (index == 3) {
            if (count > index) {
                _numberAdditionalFollowees.text = [NSString stringWithFormat:@"+%lu", count-index];
                
                [_numberAdditionalFollowees sizeToFit];
                _numberAdditionalFollowees.frame = CGRectMake(33*index, (30-CGRectGetHeight(_numberAdditionalFollowees.frame))/2, CGRectGetWidth(_numberAdditionalFollowees.frame), CGRectGetHeight(_numberAdditionalFollowees.frame));
                [_followeesView addSubview:_numberAdditionalFollowees];
            }
            break;
        }
    }
    
    if (count) {
        self.subHeader2.text = [self subheader2String];
        [self.subHeader2 sizeToFit];
    }
    [self setNeedsLayout];
}

- (NSString *)headerString {
    NSString *s;
    if (!_restaurant) return @"";
    
    s = [NSString stringWithFormat:@"%lu. %@", _index, _restaurant.name];
    
    return s;
}

- (NSString *)subheader1String {
    NSString *s;
    if (!_restaurant) return @"";
    
    NSMutableArray *components = [NSMutableArray array];
    if ([_restaurant distanceOrAddressString]) [components addObject:[_restaurant distanceOrAddressString]];
    if ([_open length]) [components addObject:_open];
    if ([[_restaurant priceRangeText] length]) [components addObject:[_restaurant priceRangeText]];

    s = [components componentsJoinedByString:@" | "];
    return s;
}

- (NSString *)subheader2String {
    NSString *s;
    if (!_restaurant) return @"";
    
    NSMutableArray *components = [NSMutableArray array];
    if (_restaurant.cuisine) [components addObject:_restaurant.cuisine];
    if ([_rating length]) [components addObject:_rating];
    
    s = [components componentsJoinedByString:@" | "];
    
    if ([s length] && [_followees count]) {
        s = [s stringByAppendingString:@" | "];
    }
    if (![s length]) {
        s = @" ";
    }
    return s;
}

//- (void)updateConstraints {
//    [super updateConstraints];

//    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomDimensionsIconButtonSmall)};
//        
//    UIView *superview = self, *subheader2 = self.subHeader2;
//    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _followeesView, subheader2);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_followeesView(30)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_followeesView(100)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_followeesView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:subheader2 attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_followeesView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:subheader2 attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_followees || ![_followees count]) return;
    
    CGRect frame;
    
    frame = _followeesView.frame;
    frame.size.height = 30;
    frame.size.width = 100;
    frame.origin.x = CGRectGetMaxX(self.subHeader2.frame);
    frame.origin.y = CGRectGetMinY(self.subHeader2.frame) + (CGRectGetHeight(_followeesView.frame) - CGRectGetHeight(_followeesView.frame))/2;
    _followeesView.frame = frame;
    
    frame = self.subHeader2.frame;
    frame.size.height = CGRectGetHeight(_followeesView.frame);
    self.subHeader2.frame = frame;
}


- (void)setListToAddTo:(ListObject *)listToAddTo
{
    if (_listToAddTo == listToAddTo) return;
    _listToAddTo = listToAddTo;
    [self setupActionButton];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_roFollowes cancel];
    _roFollowes = nil;
    [_roMIO cancel];
    _roMIO = nil;
    [_roRestaurant cancel];
    _roRestaurant = nil;
    [self.requestOperation  cancel];
    self.requestOperation = nil;
    
    _followees = nil;
    [self.actionButton setTitle:@"" forState:UIControlStateNormal];
    self.restaurant = nil;
    self.eventBeingEdited = nil;
    self.listToAddTo = nil;
    self.mode = kActionButtonModeNone;
    [[_followeesView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)expressMode
{
    NSString *string = @"";
    if (!self.eventBeingEdited) {
        if (self.listToAddTo) {
            if (_useModalForListedVenues) { //
                
                string= kFontIconMoreSolid;
                self.mode= kActionButtonModeModal;
            } else {
                
                if ( !self.listToAddTo.venues) {
                    // NOTE: We do not yet know what venues are in this list.
                    self.mode= kActionButtonModeNone;
                    string=  @"";
                } else {
                    if ( [_listToAddTo alreadyHasVenue:_restaurant]) {
                        string= kFontIconRemove;
                        self.mode= kActionButtonModeRemove;
                    } else {
                        string= kFontIconAdd;
                        self.mode= kActionButtonModeAdd;
                    }
                }
            }
        } else {
            //string = kFontIconMoreSolid;
            string = kFontIconAddToList;
            self.mode= kActionButtonModeAddToList;
            [self.actionButton.titleLabel setFont:[UIFont fontWithName:kFontIcons size:kGeomIconSize]];
        }
    } else {
        if ( [self.eventBeingEdited alreadyHasVenue:_restaurant ]) {
            string=kFontIconRemove;
            self.mode= kActionButtonModeRemove;
            
        } else {
            string= kFontIconAdd;
            self.mode= kActionButtonModeAdd;
        }
    }
    
    [self.actionButton setTitle:string forState:UIControlStateNormal];
}

- (void)setupActionButton
{
    [self expressMode];
    [self.actionButton addTarget:self action:@selector(userPressedActionButton:) forControlEvents:UIControlEventTouchUpInside];
    self.actionButton.hidden = NO;
}

- (void)addToList
{
    if (_listToAddTo) {
        [self addRestaurantToList:_listToAddTo];
    } else {
        [self showLists];
    }
}

- (void)removeFromList
{
    if (_listToAddTo) {
        __weak  RestaurantTVCell *weakSelf = self;
        __weak ListObject *weakList = _listToAddTo;
        [_listToAddTo removeVenue: _restaurant
                  completionBlock:^(BOOL success) {
                      [weakSelf expressMode];
                      NOTIFY_WITH(kNotificationListAltered, weakList);
                  }];
    } else {
        NSLog (@"THERE IS NO LIST TO REMOVE FROM.");
    }
}

- (void)showLists
{
    ListsVC *vc = [[ListsVC alloc] init];
    vc.restaurantToAdd = _restaurant;
    [vc getLists];
    [self.nc pushViewController:vc animated:YES];
}

- (void)userPressedActionButton:(id)sender
{
    __weak RestaurantTVCell *weakSelf = self;
    if (_restaurant.restaurantID) {
        switch (weakSelf.mode) {
            case kActionButtonModeAdd:
                if ( weakSelf.listToAddTo) {
                    [weakSelf addToList];
                } else if ( weakSelf.eventBeingEdited) {
                    [weakSelf addToEvent];
                } else {
                    NSLog (@"WARNING: NOTHING TO ADD RESTAURANT TO.");
                }
                break;
                
            case kActionButtonModeRemove:
                if ( weakSelf.listToAddTo) {
                    [weakSelf removeFromList];
                } else if ( weakSelf.eventBeingEdited) {
                    [weakSelf removeFromEvent];
                } else {
                    NSLog (@"WARNING: NOTHING TO REMOVE RESTAURANT FROM.");
                }
                break;
                
            case kActionButtonModeModal: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf setupRestaurantOptionsAC];
                    _restaurantOptionsAC.popoverPresentationController.sourceView = sender;
                    _restaurantOptionsAC.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
                    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
                        if (!result) {
                            [weakSelf presentUnverifiedMessage:@"You will need to verify your email to do this.\n\nCheck your email for a verification link."];
                        } else {
                            [weakSelf.nc presentViewController:_restaurantOptionsAC animated:YES completion:nil];
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        ;
                    }];
                });
                break;
            }
            case kActionButtonModeAddToList:
                [self addToList];
                break;
        }
        }
}

- (void)presentUnverifiedMessage:(NSString *)message {
    UnverifiedUserVC *vc = [[UnverifiedUserVC alloc] initWithSize:CGSizeMake(250, 200)];
    vc.delegate = self;
    vc.action = message;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.transitioningDelegate = vc;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *nc = [UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject;
        if ([nc isKindOfClass:[UINavigationController class]]) {
            ((UINavigationController *)nc).delegate = vc;
        }
        
        [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:vc animated:YES completion:nil];
    });
}

- (void)unverifiedUserVCDismiss:(UnverifiedUserVC *)unverifiedUserVC {
    [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)setIndex:(NSUInteger)index {
    _index = index;
    self.icon.text = kFontIconPin;
    self.iconLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    [self.iconLabel sizeToFit];
    
    self.header.text = [self headerString];
    [self setNeedsLayout];
}

- (void)setupRestaurantOptionsAC {
    _restaurantOptionsAC = [UIAlertController alertControllerWithTitle:@"Place Options"
                                                               message:@"What would you like to do with this place."
                                                        preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    _restaurantOptionsAC.view.tintColor = UIColorRGBA(kColorBlack);
    
    __weak RestaurantTVCell *weakSelf = self;
    
    UIAlertAction *shareRestaurant = [UIAlertAction actionWithTitle:@"Share Place"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  [weakSelf  sharePressed:weakSelf];
                                                              }];
    
    UIAlertAction *addToList = nil;
    UIAlertAction *removeFromList =nil;
    
    if ( _listToAddTo) {
        if  ([_listToAddTo alreadyHasVenue: _restaurant] ) {
            removeFromList= [UIAlertAction actionWithTitle:(_listToAddTo) ? [NSString stringWithFormat:@"Remove from \"%@\"", _listToAddTo.name] : @"Remove from List"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                         [ weakSelf   removeFromList];
                                                     }];
        } else {
            
            addToList= [UIAlertAction actionWithTitle:(_listToAddTo) ? [NSString stringWithFormat:@"Add to \"%@\"", _listToAddTo.name] : @"Add from List"
                                                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                    [weakSelf  addToList];
                                                }];
        }
    }
    
    UIAlertAction *addToEvent = nil;
    UIAlertAction *removeFromEvent = nil;
    if (self.eventBeingEdited) {
        if (  ![self.eventBeingEdited alreadyHasVenue: _restaurant ] ) {
            addToEvent= [UIAlertAction actionWithTitle: LOCAL(@"Add to Event")
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSLog(@"Add to Event");
                                                     [weakSelf addToEvent];
                                                 }];
        } else {
            // XX:  need ability to remove a restaurant from an event
            removeFromEvent= [UIAlertAction actionWithTitle: LOCAL(@"Remove from Event")
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     NSLog(@"Remove from Event");
                                                     [weakSelf removeFromEvent];
                                                 }];

        }
    }
    
    if (!addToList) {
        addToList = [UIAlertAction actionWithTitle:@"Add to an Existing List"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"Add/Remove from Existing List");
                                                               [weakSelf addToList];
                                                           }];
    }
    UIAlertAction *addToNewList = [UIAlertAction actionWithTitle:@"Add to New List"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"Add to New List");
                                                               [weakSelf setupCreateListAC];
                                                               [weakSelf createListPressed];
                                                           }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style: UIAlertActionStyleCancel
							 handler:^(UIAlertAction * action) {
                                                         NSLog(@"Cancel");
                                                     }];
    
    [_restaurantOptionsAC addAction:shareRestaurant];

    if (addToList) {
        [_restaurantOptionsAC addAction:addToList];
    }
    if (removeFromList) {
        [_restaurantOptionsAC addAction:removeFromList];
    }

    [_restaurantOptionsAC addAction:addToNewList];
    if (addToEvent) {
        [_restaurantOptionsAC addAction:addToEvent];
    }
    if ( removeFromEvent) {
        [_restaurantOptionsAC addAction:removeFromEvent];
    }
    
//    [_restaurantOptionsAC addAction:addToNewEvent];
    [_restaurantOptionsAC addAction:cancel];
    
//    [self.moreButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
    else if ( self.eventBeingEdited.numberOfVenues >= kMaximumRestaurantsPerEvent) {
        message( @"Cannot add more restaurants to event, maximum reached.");
        return;
    }
    
    EventObject* e= self.eventBeingEdited;
    __weak RestaurantTVCell *weakSelf = self;
    [e addVenue:_restaurant completionBlock:^(BOOL  success) {
        [weakSelf expressMode];
    }];
}

- (void)removeFromEvent
{
    if  ([self.eventBeingEdited alreadyHasVenue: _restaurant ] ) {
        
        EventObject* e= self.eventBeingEdited;
        __weak RestaurantTVCell *weakSelf = self;
        [e  removeVenue:_restaurant completionBlock:^(BOOL  success) {
            [weakSelf expressMode];
        }];
    }
}

- (UIImage *)shareImage {
    UIView *shareView = [UIView new];
    //shareView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    CGRect frame;
    UIImageView *iv = [UIImageView new];
    CGFloat height = width(self)*self.thumbnail.image.size.height/self.thumbnail.image.size.width;
    iv.frame = CGRectMake(0, 0, width(self), height);
    iv.image = self.thumbnail.image;
    
    if (_mio && _mio.source == kMediaItemTypeOomami) {
        UILabel *logo = [UILabel new];
        [logo withFont:[UIFont fontWithName:kFontIcons size:80] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentRight];
        logo.text = kFontIconLogoFull;
        [logo sizeToFit];
        frame = logo.frame;
        frame.size.width = CGRectGetWidth(iv.frame)-16;
        frame.origin = CGPointMake(0, CGRectGetHeight(iv.frame) - CGRectGetHeight(logo.frame) + 20);
        logo.frame = frame;
        [iv addSubview:logo];
    }
    
    [shareView addSubview:iv];
    
    frame = iv.bounds;
    shareView.frame = frame;
    [shareView setNeedsLayout];
    
    return [UIImage imageFromView:shareView];
}

- (void)sharePressed:(id)sender {
    UIImage *img = [self shareImage];
    [FBSDKAppEvents logEvent:kAppEventSharePressed
                  parameters:@{kAppEventParameterValueItem:kAppEventParameterValuePlace}];
    __weak RestaurantTVCell *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf showShare:img fromView:sender];
    });
}

- (void)showShare:(UIImage *)img fromView:(id)sender {
    OOActivityItemProvider *aip = [[OOActivityItemProvider alloc] initWithPlaceholderItem:@""];
    aip.restaurant = _restaurant;
    
    NSArray *items = @[aip, img];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    avc.popoverPresentationController.sourceView = sender;
    avc.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
    
    [avc setValue:[NSString stringWithFormat:@"Take a look at %@", _restaurant.name] forKey:@"subject"];
    [avc setExcludedActivityTypes:
     @[UIActivityTypeAssignToContact,
       UIActivityTypePostToFlickr,
       UIActivityTypeCopyToPasteboard,
       UIActivityTypePrint,
       UIActivityTypeSaveToCameraRoll,
       UIActivityTypePostToWeibo]];
    [self.nc presentViewController:avc animated:YES completion:^{
        ;
    }];
    
    avc.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
    };
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
    [self.nc presentViewController:_createListAC animated:YES completion:nil];
}

- (void)createListNamed:(NSString *)name {
    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantTVCell *weakSelf = self;
    [api addList:name success:^(ListObject *listObject) {
        [FBSDKAppEvents logEvent:kAppEventListCreated];
        if (listObject.listID) {
            [weakSelf addRestaurantToList:listObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Could not create list: %@", error);
    }];
}

- (void)addRestaurantToList:(ListObject *)list
{
    __weak RestaurantTVCell *weakSelf = self;
    //__weak ListObject *weakList = list;
    
    [list addVenue:_restaurant completionBlock:^(BOOL added, ListObject *list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (added) {
                [weakSelf expressMode];

                UIAlertController *a= [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", list.listName]
                                                                          message:[NSString stringWithFormat:@"Added '%@' to the list.", weakSelf.restaurant.name]
                                                                   preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                             style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
                
                [a addAction:ok];
                //seem like a hack...use delegates instead
                [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:a animated:YES completion:nil];
                
                NOTIFY_WITH(kNotificationListAltered, list);
            } else {
                
            }
        });
    }];
    
//    OOAPI *api= [[OOAPI alloc] init];
//    [api addRestaurants:@[_restaurant] toList:list.listID
//                success:^(id response) {
//                    NSLog (@"SUCCESS IN ADDING LIST.");
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [weakSelf expressMode];
//                        NOTIFY_WITH(kNotificationListAltered, weakList);
//                        
//                        UIAlertController *a= [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", list.listName]
//                                                                                  message:[NSString stringWithFormat:@"Added '%@' to the list.", weakSelf.restaurant.name]
//                                                                           preferredStyle:UIAlertControllerStyleAlert];
//                        
//                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
//                                                                     style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//
//                                                                     }];
//                        
//                        [a addAction:ok];
//                        //seem like a hack...use delegates instead
//                        [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:a animated:YES completion:nil];
//
//                    });
//                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    NSLog  (@"Failed to add venue to list %@",error);
//                }];
}

- (void)addToList:(RestaurantObject *)restaurant {
    ListsVC *vc = [[ListsVC alloc] init];
    vc.restaurantToAdd = restaurant;
    [vc getLists];
    [_nc pushViewController:vc animated:YES];
}

@end

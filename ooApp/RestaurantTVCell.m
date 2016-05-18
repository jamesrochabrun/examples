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

@interface RestaurantTVCell ()
@property (nonatomic, strong) UIAlertController *restaurantOptionsAC;
@property (nonatomic, strong) UIAlertController *createListAC;
@property (nonatomic, assign) NSUInteger mode;
@property (nonatomic, strong) NSArray *followees;
@property (nonatomic, strong) UIView *followeesView;
@property (nonatomic, strong) UILabel *numberAdditionalFollowees;
@property (nonatomic, strong) AFHTTPRequestOperation *roFollowes;
@end

enum  {
    MODE_ADD=1,
    MODE_REMOVE= 2,
    MODE_MODAL= 3,
    MODE_NONE= 0
};

@implementation RestaurantTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _followeesView = [UIView new];
        _followeesView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_followeesView];
        
        _numberAdditionalFollowees = [UILabel new];
        [_numberAdditionalFollowees withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorBlack backgroundColor:kColorClear];
        //[DebugUtilities addBorderToViews:@[_followeesView, _numberAdditionalFollowees]];
    }
    return self;
}

- (void)setRestaurant:(RestaurantObject *)restaurant
{
    if (restaurant == _restaurant) return;
    _restaurant = restaurant;
    self.thumbnail.image = [UIImage imageNamed:@"background-image.jpg"];
    self.header.text = _restaurant.name;
    self.subHeader1.text =  _restaurant.isOpen==kRestaurantOpen ? @"Open Now" :
                            (_restaurant.isOpen==kRestaurantClosed? @"Not Open" : @"");
    
    self.subHeader2.text = [self subheader2String];
    
    OOAPI *api = [[OOAPI alloc] init];
    
    NSString *imageRef;
    MediaItemObject *mio;
    if ([restaurant.mediaItems count]) {
        mio = [restaurant.mediaItems objectAtIndex:0];
    } else if ([restaurant.imageRefs count]) {
        imageRef = ((ImageRefObject *)[restaurant.imageRefs objectAtIndex:0]).reference;
    }
    
    if (mio) {
        self.requestOperation = [api getRestaurantImageWithMediaItem:mio
                                                            maxWidth:width(self)
                                                           maxHeight:0
                                                             success:^(NSString *link) {
            __weak UIImageView *weakIV = self.thumbnail;
            __weak RestaurantTVCell *weakSelf = self;
            [self.thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                  placeholderImage:[UIImage imageNamed:@"background-image.jpg"]
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               ON_MAIN_THREAD(^ {
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
    } else if (imageRef) {
        self.requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {

            __weak UIImageView *weakIV = self.thumbnail;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                      placeholderImage:[UIImage imageNamed:@"background-image.jpg"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                    [UIView transitionWithView:weakIV duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        weakIV.image = image;;
                    } completion:^(BOOL finished) {
                        ;
                    }];
                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                    ;
                }];//thURL:[NSURL URLWithString:link]];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
    __weak RestaurantTVCell *weakSelf = self;
    
    if (!_restaurant.restaurantID) {
        [api getRestaurantWithID:_restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
            _restaurant = restaurant;
            if (_restaurant.restaurantID) {
                
                [weakSelf addFolloweesWithRestaurant];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog  (@"ERROR UNABLE TO IDENTIFY VENUE: %@",error);
        }];
    } else {
        [self addFolloweesWithRestaurant];
    }
    [self setupActionButton];
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
        if (index == 2) {
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
    }
    [self setNeedsLayout];
}

- (NSString *)subheader2String {
    NSString *s;
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:_restaurant.location.latitude longitude:_restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    
    NSString *distance = (distanceInMeters) ? [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)] : @"";
    NSString *rating = _restaurant.rating ? [NSString stringWithFormat:@"%0.1f rating", _restaurant.rating] : @"";

    if ([distance length] && [rating length]) {
        s = [NSString stringWithFormat:@"%@ | %@", distance, rating];
    } else {
        s = [NSString stringWithFormat:@"%@", [distance length] ? distance : rating];
    }
    
    if ([_followees count]) {
        s = [s stringByAppendingString:@" | "];
    }
    return s;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomDimensionsIconButtonSmall)};
        
    UIView *superview = self, *subheader2 = self.subHeader2;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _followeesView, subheader2);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_followeesView(30)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_followeesView(100)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_followeesView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:subheader2 attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_followeesView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:subheader2 attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
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
    _followees = nil;
    [self.actionButton setTitle:@"" forState:UIControlStateNormal];
    self.restaurant= nil;
    self.eventBeingEdited= nil;
    self.listToAddTo=nil;
    self.mode= MODE_NONE;
    [[_followeesView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)expressMode
{
    NSString *string = @"";
    if (!self.eventBeingEdited) {
        if (self.listToAddTo) {
            if ( _useModalForListedVenues) {
                
                string= kFontIconMore;
                self.mode= MODE_MODAL;
            } else {
                
                if ( !self.listToAddTo.venues) {
                    // NOTE: We do not yet know what venues are in this list.
                    self.mode= MODE_NONE;
                    string=  @"";
                } else {
                    if ( [_listToAddTo alreadyHasVenue:_restaurant]) {
                        string= kFontIconRemove;
                        self.mode= MODE_REMOVE;
                    } else {
                        string= kFontIconAdd;
                        self.mode= MODE_ADD;
                    }
                }
            }
        } else {
            string= kFontIconMore;
            self.mode= MODE_MODAL;
        }
    } else {
        if ( [self.eventBeingEdited alreadyHasVenue:_restaurant ]) {
            string=kFontIconRemove;
            self.mode= MODE_REMOVE;
            
        } else {
            string= kFontIconAdd;
            self.mode= MODE_ADD;
        }
    }
    
    [self.actionButton setTitle: string forState:UIControlStateNormal];
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
        [_listToAddTo removeVenue: _restaurant
                  completionBlock:^(BOOL success) {
                      [weakSelf expressMode];
                      NOTIFY_WITH(kNotificationListAltered, @(_listToAddTo.listID));
                  }];
    } else {
        NSLog (@"THERE IS NO LIST TO REMOVE FROM.");
    }
}

- (void)showLists {
    ListsVC *vc = [[ListsVC alloc] init];
    vc.restaurantToAdd = _restaurant;
    [vc getLists];
    [self.nc pushViewController:vc animated:YES];
}

- (void)userPressedActionButton:(id)sender
{
//    OOAPI *api = [[OOAPI alloc] init];
    __weak RestaurantTVCell *weakSelf = self;
//    [api getRestaurantWithID:_restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
//        _restaurant = restaurant;
        if (_restaurant.restaurantID) {
            switch (weakSelf.mode) {
                case MODE_ADD:
                    if ( weakSelf.listToAddTo) {
                        [weakSelf addToList];
                    }
                    else if ( weakSelf.eventBeingEdited) {
                        [weakSelf addToEvent];
                    }
                    else {
                        NSLog (@"WARNING: NOTHING TO ADD RESTAURANT TO.");
                    }
                    break;
                    
                case MODE_REMOVE:
                    if ( weakSelf.listToAddTo) {
                        [weakSelf removeFromList];
                    }
                    else if ( weakSelf.eventBeingEdited) {
                        [weakSelf removeFromEvent];
                    }
                    else {
                        NSLog (@"WARNING: NOTHING TO REMOVE RESTAURANT FROM.");
                    }
                    break;
                    
                case MODE_MODAL:
                    ON_MAIN_THREAD(^{
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
            }
        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog  (@"ERROR UNABLE TO IDENTIFY VENUE: %@",error);
//    }];
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
    self.icon.text = kFontIconPin;
    self.iconLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)index];
}

- (void)setupRestaurantOptionsAC {
    _restaurantOptionsAC = [UIAlertController alertControllerWithTitle:@"Restaurant Options"
                                                               message:@"What would you like to do with this restaurant."
                                                        preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    _restaurantOptionsAC.view.tintColor = UIColorRGBA(kColorBlack);
    
    __weak RestaurantTVCell *weakSelf = self;
    
    UIAlertAction *shareRestaurant = [UIAlertAction actionWithTitle:@"Share Restaurant"
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

- (void)sharePressed:(id)sender {
//    MediaItemObject *mio;
//    NSArray *mediaItems = _restaurant.mediaItems;
//    if (mediaItems && [mediaItems count]) {
//        mio = [mediaItems objectAtIndex:0];
//        
//        OOAPI *api = [[OOAPI alloc] init];
//        
//        if (mio) {
//            self.requestOperation = [api getRestaurantImageWithMediaItem:mio maxWidth:150 maxHeight:0 success:^(NSString *link) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self showShare:link fromView:sender];
//                });
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self showShare:nil fromView:sender];
//                });
//            }];
//        } else {
//            [self showShare:nil fromView:sender];
//        }
//    } else {
        [self showShare:nil fromView:sender];
//    }
}

- (void)showShare:(NSString *)url fromView:(id)sender {
    NSURL *nsURL = [NSURL URLWithString:url];
    //NSData *data = [NSData dataWithContentsOfURL:nsURL];
    UIImage *img = self.thumbnail.image;// [UIImage imageWithData:data];
    
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
    __weak ListObject *weakList = list;
    
    OOAPI *api= [[OOAPI alloc] init];
    [api addRestaurants:@[_restaurant] toList:list.listID
                success:^(id response) {
                    NSLog (@"SUCCESS IN ADDING LIST.");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf expressMode];
                        NOTIFY_WITH(kNotificationListAltered, weakList);
                        
                        UIAlertController *a= [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", list.listName]
                                                                                  message:[NSString stringWithFormat:@"Added '%@' to the list.", weakSelf.restaurant.name]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                                     style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

                                                                     }];
                        
                        [a addAction:ok];
                        //seem like a hack...use delegates instead
                        [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:a animated:YES completion:nil];

                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog  (@"FAILED TO ADD VENUE TO EVENT %@",error);
                }];
}

- (void)addToList:(RestaurantObject *)restaurant {
    ListsVC *vc = [[ListsVC alloc] init];
    vc.restaurantToAdd = restaurant;
    [vc getLists];
    [_nc pushViewController:vc animated:YES];
}

@end

//
//  AddCaptionToMIOVC.m
//  ooApp
//
//  Created by Anuj Gujar on 1/3/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "AddCaptionToMIOVC.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "RestaurantObject.h"

@interface AddCaptionToMIOVC ()
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UIButton *isFoodButton;
@property (nonatomic, strong) UIButton *favoritesListButton;
@property (nonatomic, strong) UILabel *isFoodLabel;
@property (nonatomic, strong) UILabel *favoritesListLabel;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic) NSUInteger favoritesListId;
@property (nonatomic, strong) RestaurantObject *restaurant;
@end

@implementation AddCaptionToMIOVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nto = [[NavTitleObject alloc] initWithHeader:@"Add a Caption" subHeader:@""];
    self.navTitle = self.nto;
    
    _isFoodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_isFoodButton withIcon:@"" fontSize:25 width:40 height:40 backgroundColor:kColorOffBlack target:self selector:@selector(toggleIsFoodItem)];
    [_isFoodButton setTitle:kFontIconCheckmark forState:UIControlStateSelected];
    [_isFoodButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
    [_isFoodButton setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorButtonBackground)] forState:UIControlStateSelected];
    [_isFoodButton setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorButtonBackground)] forState:UIControlStateNormal];
    _isFoodButton.layer.borderColor = UIColorRGBA(kColorBordersAndLines).CGColor;
    _isFoodButton.layer.borderWidth = 1;
    _isFoodButton.layer.cornerRadius = kGeomCornerRadius;

    _favoritesListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_favoritesListButton withIcon:@"" fontSize:25 width:40 height:40 backgroundColor:kColorOffBlack target:self selector:@selector(toggleFavoritesState)];
    [_favoritesListButton setTitle:kFontIconFavoriteFilled forState:UIControlStateSelected];
    [_favoritesListButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
    [_favoritesListButton setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorButtonBackground)] forState:UIControlStateSelected];
    [_favoritesListButton setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorButtonBackground)] forState:UIControlStateNormal];
    _favoritesListButton.layer.borderColor = UIColorRGBA(kColorBordersAndLines).CGColor;
    _favoritesListButton.layer.borderWidth = 1;
    _favoritesListButton.layer.cornerRadius = kGeomCornerRadius;
    
    _isFoodLabel = [[UILabel alloc] init];
    [_isFoodLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorText backgroundColor:kColorClear];
    _isFoodLabel.text = @"photo of food or drink";
    [_isFoodLabel sizeToFit];

    _favoritesListLabel = [[UILabel alloc] init];
    [_favoritesListLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorText backgroundColor:kColorClear];
    _favoritesListLabel.text = @"favorite restaurant?";
    [_favoritesListLabel sizeToFit];

    _iv = [[UIImageView alloc] init];
    _iv.contentMode = UIViewContentModeScaleAspectFit;
    _iv.clipsToBounds = YES;
    _iv.backgroundColor = UIColorRGBA(kColorClear);
    
    [self.view addSubview:_iv];
    [self.view addSubview:_isFoodLabel];
    [self.view addSubview:_isFoodButton];
    [self.view addSubview:_favoritesListButton];
    [self.view addSubview:_favoritesListLabel];
    
    _favoritesListLabel.translatesAutoresizingMaskIntoConstraints =
    _favoritesListButton.translatesAutoresizingMaskIntoConstraints =
    _iv.translatesAutoresizingMaskIntoConstraints =
    _isFoodLabel.translatesAutoresizingMaskIntoConstraints =
    _isFoodButton.translatesAutoresizingMaskIntoConstraints = NO;
    
//    [DebugUtilities addBorderToViews:@[_iv, self.textView]];
}

- (void)toggleFavoritesState {
    OOAPI *api = [[OOAPI alloc] init];
    __weak AddCaptionToMIOVC *weakSelf = self;
    
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!weakSelf.favoritesListId) {
            [api addRestaurantsToSpecialList:@[_restaurant] listType:kListTypeFavorites success:^(id response) {
                [weakSelf getListsForRestaurant];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ;
            }];
        } else {
            //__weak RestaurantVC *weakSelf = self;
            [api deleteRestaurant:weakSelf.mio.restaurantID fromList:weakSelf.favoritesListId success:^(NSArray *lists) {
                [weakSelf getListsForRestaurant];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ;
            }];
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

- (void)toggleIsFoodItem {
    _mio.isFood = !_mio.isFood;
    _isFoodButton.selected = _mio.isFood;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Use this when a photo is first uploaded (e.g. from F1, R1, P1) to set the default value. Otherwise let
//mio.isFood determine the value of the checkbox
- (void)overrideIsFoodWith:(BOOL)isFood {
    _mio.isFood = isFood;
    _isFoodButton.selected = _mio.isFood;
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    NSDictionary *metrics = @{@"height":@(2*kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonDimensions":@(25)};
    
    UIView *superview = self.view;
    UIView *textEntryBox = self.textView;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _isFoodButton, _isFoodLabel, _iv, textEntryBox, _favoritesListLabel, _favoritesListButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textEntryBox]-spaceEdge-[_iv(60)]-[_favoritesListLabel]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_iv]-spaceInter-[_isFoodLabel]-spaceInter-[_isFoodButton(buttonDimensions)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_iv]-spaceInter-[_favoritesListLabel]-spaceInter-[_favoritesListButton(buttonDimensions)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_iv
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_iv
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_isFoodButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_isFoodButton
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_favoritesListButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_favoritesListButton
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_isFoodLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_iv
                                                          attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_isFoodButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_iv
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_favoritesListButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_favoritesListLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1 constant:0]];
}

- (void)post:(UIButton *)sender
{
    __weak AddCaptionToMIOVC *weakSelf = self;
    NSDictionary *properties = @{kKeyMediaItemCaption:[self text],
                                 kKeyMediaItemIsFood:((_mio.isFood)?@1:@0)};
    [OOAPI setMediaItem:_mio.mediaItemId
             properties:properties success:^{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf.delegate textEntryFinished:[self text]];
                 });
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 ;
             }];
}

- (void)setMio:(MediaItemObject *)mio {
    if (_mio == mio) return;
    _mio = mio;
    
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak UIImageView *weakIV = _iv;
    __weak AddCaptionToMIOVC *weakSelf = self;
    
    _requestOperation = [api getRestaurantImageWithMediaItem:_mio maxWidth:width(_iv) maxHeight:0 success:^(NSString *link) {
        [weakIV setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakIV setAlpha:0.0];
                                                 weakIV.image = image;
                                                 [UIView beginAnimations:nil context:NULL];
                                                 [UIView setAnimationDuration:0.3];
                                                 [weakIV setAlpha:1.0];
                                                 [UIView commitAnimations];
                                                 [weakSelf.view setNeedsUpdateConstraints];
                                                 [weakSelf.view setNeedsLayout];
                                             });
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             ;
                                         }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
    
    OOAPI *api2 = [[OOAPI alloc] init];
    [api2 getRestaurantWithID:[NSString stringWithFormat:@"%lu", (unsigned long)_mio.restaurantID]
                      source:kRestaurantSourceTypeOomami
                     success:^(RestaurantObject *restaurant) {
                         _restaurant = restaurant;
                         [self getListsForRestaurant];
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         NSLog(@"Could not find the restaurant");
                     }] ;

    self.defaultText = mio.caption;
    _isFoodButton.selected = _mio.isFood;
    [self.view setNeedsUpdateConstraints];
}

- (void)getListsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak AddCaptionToMIOVC *weakSelf = self;
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    [api getListsOfUser:user.userID
         withRestaurant:_restaurant.restaurantID
             includeAll:YES
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user:  %ld", ( long) foundLists.count);
                    weakSelf.favoritesListId = 0;
                    [foundLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        ListObject *lo = (ListObject *)obj;
                        if (lo.type == kListTypeFavorites) {
                            weakSelf.favoritesListId = lo.listID;
                            *stop = YES;
                        }
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.favoritesListButton setTitle:(weakSelf.favoritesListId) ? kFontIconFavoriteFilled : @"" forState:UIControlStateNormal];
                    });
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                    NSLog  (@" error while getting lists for user:  %@",e);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                    });
                }];
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

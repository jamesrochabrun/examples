//
//  ViewPhotoVC.m
//  ooApp
//
//  Created by Anuj Gujar on 1/8/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ViewPhotoVC.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "RestaurantVC.h"
#import "UserObject.h"
#import "Settings.h"

@interface ViewPhotoVC ()
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *captionButton;
@property (nonatomic, strong) UIButton *yumButton;
@property (nonatomic, strong) UIButton *numYums;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) OOUserView *userViewButton;
@property (nonatomic, strong) UIButton *restaurantName;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *closeTapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UserObject *user;
@property (nonatomic, strong) UINavigationController *aNC;
@property (nonatomic) CGPoint originPoint;
@end

@implementation ViewPhotoVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        _backgroundView.alpha = 0;
        
        _iv = [[UIImageView alloc] init];
        _iv.contentMode = UIViewContentModeScaleAspectFit;
        _iv.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        
//        _caption = [[UILabel alloc] init];
//        [_caption withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        _captionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captionButton withText:@"" fontSize:kGeomFontSizeH3 width:0 height:0 backgroundColor:kColorClear textColor:kColorWhite borderColor:kColorClear target:nil selector:nil];
        _captionButton.titleLabel.numberOfLines = 0;
        _captionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _captionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton withIcon:kFontIconRemove fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:40 backgroundColor:kColorClear target:self selector:@selector(close)];
        [_closeButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
        
        _restaurantName = [UIButton buttonWithType:UIButtonTypeCustom];
        [_restaurantName withText:@"" fontSize:kGeomFontSizeH1 width:10 height:10 backgroundColor:kColorClear textColor:kColorWhite borderColor:kColorClear target:self selector:@selector(showRestaurant)];
        _restaurantName.titleLabel.numberOfLines = 0;
        
        _tapGesture = [[UITapGestureRecognizer alloc] init];
        _closeTapGesture = [[UITapGestureRecognizer alloc] init];
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    
        
        _yumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_yumButton withIcon:kFontIconYumOutline fontSize:40 width:25 height:0 backgroundColor:kColorClear target:self selector:@selector(yumPhotoTapped)];
        [_yumButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
        [_yumButton setTitle:kFontIconYum forState:UIControlStateSelected];
        _yumButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
        _numYums = [UIButton buttonWithType:UIButtonTypeCustom];
        [_numYums withText:@"" fontSize:kGeomFontSizeH4 width:30 height:30 backgroundColor:kColorClear target:self selector:@selector(showYums)];
        [_numYums setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
        _numYums.contentMode = UIViewContentModeBottom;
        
        _userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userButton withText:@"" fontSize:kGeomFontSizeSubheader width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(showProfile)];
        [_userButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        _userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_userButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];

        _userViewButton = [[OOUserView alloc] init];
        _userViewButton.delegate = self;

        [self.view addSubview:_backgroundView];
        [_backgroundView addSubview:_closeButton];
        [_backgroundView addSubview:_captionButton];
        [_backgroundView addSubview:_userButton];
        [_backgroundView addSubview:_userViewButton];
        [_backgroundView addSubview:_numYums];
        [_backgroundView addSubview:_yumButton];
        [_backgroundView addSubview:_iv];
        [_backgroundView addSubview:_restaurantName];

//        [DebugUtilities addBorderToViews:@[_restaurantName, _numYums, _yumButton, _captionButton, _userButton, _iv, _userViewButton]];
    }
    return self;
}

- (void)addCaption {
    _aNC = [[UINavigationController alloc] init];
    AddCaptionToMIOVC *vc = [[AddCaptionToMIOVC alloc] init];
    
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    vc.mio = _mio;
    vc.delegate = self;
    
    [_aNC addChildViewController:vc];
    
    [_aNC.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorBlack)] forBarMetrics:UIBarMetricsDefault];
    [_aNC.navigationBar setShadowImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)]];
    [_aNC.navigationBar setTranslucent:YES];
    _aNC.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController presentViewController:_aNC animated:YES completion:^{
        _aNC.topViewController.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }];
}

- (void)textEntryFinished:(NSString *)text {
    _mio.caption = text;
    [_captionButton setTitle:text forState:UIControlStateNormal];
    [self.view setNeedsLayout];
//    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)showRestaurant {
    [UIView animateWithDuration:0.4 animations:^{
        _backgroundView.alpha = 0;
        self.view.backgroundColor = UIColorRGBA(kColorClear);
    } completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:NO];
        [_delegate viewPhotoVC:self showRestaurant:_restaurant];
    }];
}

- (void)showProfile {
    [UIView animateWithDuration:0.4 animations:^{
        _backgroundView.alpha = 0;
        self.view.backgroundColor = UIColorRGBA(kColorClear);
    } completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:NO];
        [_delegate viewPhotoVC:self showProfile:_user];
    }];
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user {
    [self showProfile];
}

- (void)showYums {
    
}

- (void)close {
    [UIView animateWithDuration:0.4 animations:^{
        _backgroundView.alpha = 0;
        self.view.backgroundColor = UIColorRGBA(kColorClear);
    } completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tapGesture addTarget:self action:@selector(showRestaurant)];
    [_closeTapGesture addTarget:self action:@selector(close)];
    [self.view addGestureRecognizer:_panGesture];
}

- (void)pan:(UIGestureRecognizer *)gestureRecognizer {
    if (_panGesture != gestureRecognizer) return;
    
    CGPoint newPoint;
//    NSLog(@"translation %@", NSStringFromCGPoint(_originPoint));
    if (_panGesture.state == UIGestureRecognizerStateBegan) {
        _originPoint = CGPointMake([_panGesture locationInView:self.view].x, [_panGesture locationInView:self.view].y);
    } else if (_panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = CGPointMake([_panGesture translationInView:self.view].x, [_panGesture translationInView:self.view].y);
        _backgroundView.transform = CGAffineTransformMakeTranslation(delta.x, delta.y);
        self.view.alpha = 0.5;
    } else if (_panGesture.state == UIGestureRecognizerStateEnded) {
        newPoint = CGPointMake([_panGesture locationInView:self.view].x, [_panGesture locationInView:self.view].y);
        CGFloat distance = distanceBetweenPoints(newPoint, _originPoint);
//        NSLog(@"distance moved: %f", distance);
        if (distance > 40) {
            [self close];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                _backgroundView.transform = CGAffineTransformIdentity;
                self.view.alpha = 1;
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = UIColorRGBA(kColorOverlay10);
        _backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (restaurant == _restaurant) return;
    _restaurant = restaurant;
    if ( _restaurant) {
        [_restaurantName setTitle:_restaurant.name forState:UIControlStateNormal];
    } else {
        [_restaurantName setTitle:@"NO RESTAURANT" forState:UIControlStateNormal];
    }
    [self.view setNeedsLayout];
}

- (void)setMio:(MediaItemObject *)mio {
    if (mio == _mio) return;
    _mio = mio;
    
//    _caption.text = _mio.caption;
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    if ([_mio.caption length]) {
        [_captionButton setTitle:_mio.caption forState:UIControlStateNormal];
    } else {
        if (_mio.sourceUserID == user.userID) {
            [_captionButton setTitle:@"+ add caption" forState:UIControlStateNormal];
        }
    }

    if (_mio.sourceUserID == user.userID) {
        [_captionButton addTarget:self action:@selector(addCaption) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_captionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    }

    OOAPI *api = [[OOAPI alloc] init];
    
    [_backgroundView addGestureRecognizer:_tapGesture];
    [self.view addGestureRecognizer:_closeTapGesture];
    
    __weak UIImageView *weakIV = _iv;
    __weak ViewPhotoVC *weakSelf = self;
    
    _requestOperation = [api getRestaurantImageWithMediaItem:_mio maxWidth:self.view.frame.size.width maxHeight:0 success:^(NSString *link) {
        
        [_iv setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakIV setAlpha:0.0];
                                                 weakIV.image = image;
                                                 [UIView beginAnimations:nil context:NULL];
                                                 [UIView setAnimationDuration:0.3];
                                                 [weakIV setAlpha:1.0];
                                                 [UIView commitAnimations];
                                                 [weakSelf.view setNeedsLayout];
                                             });
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             ;
                                         }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
    
    if (_mio.source == kMediaItemTypeOomami) {
        _yumButton.hidden = NO;
        
        [self updateNumYums];
        
        [OOAPI getMediaItemLiked:_mio.mediaItemId byUser:[Settings sharedInstance].userObject.userID success:^(BOOL liked) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_yumButton setSelected:liked];
                _yumButton.hidden = NO;
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_yumButton setSelected:NO];
                _yumButton.hidden = NO;
            });
        }];
        //get the state of the yum button for this user
    }
    
    if (_mio.sourceUserID) {
        __weak ViewPhotoVC *weakSelf = self;
        [OOAPI getUserWithID:_mio.sourceUserID success:^(UserObject *user) {
            _user = user;
            NSString *userName = [NSString stringWithFormat:@"@%@", user.username];
            dispatch_async(dispatch_get_main_queue(), ^{
                _userViewButton.user = user;
                [_userButton setTitle:userName forState:UIControlStateNormal];
                [_userButton sizeToFit];
                _userButton.hidden = NO;
                _userViewButton.hidden = NO;
                [_backgroundView bringSubviewToFront:_userViewButton];
                [weakSelf.view setNeedsLayout];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!height(self.view)) {
        return; // Fix for NaN crash.
    }
    
    CGRect frame;
    CGFloat maxImageHeight = 0.7 * height(self.view);
    CGFloat imageMaxY;
    
    //adjust backgroundview horizontal parameters
    frame = _backgroundView.frame;
    frame.size.width = width(self.view) - 2*kGeomSpaceEdge;
    frame.origin.x = (width(self.view) - frame.size.width)/2;
    _backgroundView.frame = frame;
    
    frame = _restaurantName.frame;
    frame.size.width = width(_backgroundView)-2*kGeomSpaceEdge-2*kGeomDimensionsIconButton;
    frame.origin.y = kGeomSpaceEdge;
    frame.origin.x = (width(_backgroundView) - width(_restaurantName))/2;
    frame.size.height = kGeomDimensionsIconButton;
    _restaurantName.frame = frame;

    frame = _iv.frame;

    CGFloat imageHeight = _iv.image.size.height/((_iv.image.size.width) ? (_iv.image.size.width) : 1) * width(_backgroundView) - 2*kGeomSpaceEdge;
    frame.size.height = (imageHeight > maxImageHeight) ? maxImageHeight : imageHeight;
    frame.size.width = width(_backgroundView) - 2*kGeomSpaceEdge;
    frame.origin = CGPointMake(kGeomSpaceEdge, CGRectGetMaxY(_restaurantName.frame) + kGeomSpaceCellPadding);
    _iv.frame = frame;
    
    imageMaxY = CGRectGetMaxY(_iv.frame);

    frame = _userViewButton.frame;
    frame.origin.y = imageMaxY + kGeomSpaceCellPadding;
    frame.origin.x = kGeomSpaceEdge;
    frame.size.height = kGeomDimensionsIconButton;
    frame.size.width = kGeomDimensionsIconButton;
    _userViewButton.frame = frame;

    frame = _userButton.frame;
    frame.origin.y = CGRectGetMaxY(_userViewButton.frame);
    frame.origin.x = kGeomSpaceEdge;
    _userButton.frame = frame;
    
    frame = _yumButton.frame;
    frame.size = CGSizeMake(kGeomDimensionsIconButton, kGeomDimensionsIconButton);
    frame.origin = CGPointMake(width(_backgroundView) - kGeomDimensionsIconButton - kGeomSpaceEdge, imageMaxY + kGeomSpaceCellPadding);
    _yumButton.frame = frame;

    [_numYums sizeToFit];
    frame = _numYums.frame;
//    frame.size = CGSizeMake(width(_numYums), kGeomDimensionsIconButton);
    frame.origin = CGPointMake(width(_backgroundView) - width(_numYums) - kGeomSpaceEdge, CGRectGetMaxY(_yumButton.frame));
    _numYums.frame = frame;
    _numYums.center = CGPointMake(_yumButton.center.x, _numYums.center.y);

    CGFloat distanceFromEdge = (CGRectGetMaxX(_userButton.frame) > (width(_backgroundView) - CGRectGetMinX(_numYums.frame))) ? CGRectGetMaxX(_userButton.frame) + kGeomSpaceCellPadding : (width(_backgroundView) - CGRectGetMinX(_numYums.frame) - kGeomSpaceCellPadding);
    
    frame = _captionButton.frame;
    frame.size = _captionButton.intrinsicContentSize;
    frame.size.width = (frame.size.width > (width(_backgroundView) - 2*distanceFromEdge)) ? width(_backgroundView) - 2*distanceFromEdge : frame.size.width;
    frame.size.height = imageMaxY + kGeomSpaceCellPadding - CGRectGetMaxY(_userButton.frame);
    frame.origin.y = imageMaxY + kGeomSpaceCellPadding +
        ((CGRectGetMaxY(_userButton.frame) - (imageMaxY + kGeomSpaceCellPadding)) - (frame.size.height))/2;
    frame.origin.x = (width(_backgroundView) - frame.size.width)/2;
    _captionButton.frame = frame;

    //adjust backgroundview vertical parameters based on content
    frame = _backgroundView.frame;
    frame.size.height = CGRectGetMaxY(_userButton.frame) + kGeomSpaceEdge;
    frame.origin.y = (height(self.view) - frame.size.height)/2;
    _backgroundView.frame = frame;
    
    frame = _closeButton.frame;
    frame.origin = CGPointMake(CGRectGetWidth(_backgroundView.frame)-CGRectGetWidth(_closeButton.frame), 0);
    _closeButton.frame = frame;
    
   // [_backgroundView bringSubviewToFront:_restaurantName];
}

- (void)yumPhotoTapped {
    __weak ViewPhotoVC *weakSelf = self;
    if (_yumButton.isSelected) {
        NSLog(@"unlike photo");
        NSUInteger userID = [Settings sharedInstance].userObject.userID;
        [OOAPI unsetMediaItemLike:_mio.mediaItemId forUser:userID success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_yumButton setSelected:NO];
                [weakSelf updateNumYums];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFoodFeedNeedsUpdate object:nil];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    } else {
        NSLog(@"like photo");
        NSUInteger userID = [Settings sharedInstance].userObject.userID;
        [OOAPI setMediaItemLike:_mio.mediaItemId forUser:userID success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_yumButton setSelected:YES];
                [weakSelf updateNumYums];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFoodFeedNeedsUpdate object:nil];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
    
    UserObject* myself= [Settings sharedInstance].userObject;
    if ( _mio.sourceUserID==myself.userID) {
        // RULE: If I like or unlike my own photo, I will need to update my profile screen.
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOwnProfileNeedsUpdate object:nil];
    }
}

- (void)updateNumYums {
    __weak ViewPhotoVC *weakSelf = self;
    [OOAPI getNumMediaItemLikes:_mio.mediaItemId success:^(NSUInteger count) {
        if (count) {
            [_numYums setTitle:[NSString stringWithFormat:@"%lu %@", (unsigned long)count, (count == 1) ? @"yum" : @"yums"] forState:UIControlStateNormal];
            dispatch_async(dispatch_get_main_queue(), ^{
                _numYums.hidden = NO;
                [weakSelf.view setNeedsLayout];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                _numYums.hidden = YES;
                [weakSelf.view setNeedsLayout];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _numYums.hidden = YES;
            [weakSelf.view setNeedsLayout];
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

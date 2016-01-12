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
@property (nonatomic, strong) UILabel *caption;
@property (nonatomic, strong) UIButton *yumButton;
@property (nonatomic, strong) UIButton *numYums;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) OOUserView *userViewButton;
@property (nonatomic, strong) UIButton *restaurantName;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *closeTapGesture;
@property (nonatomic, strong) UserObject *user;
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
        
        _caption = [[UILabel alloc] init];
        [_caption withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton withIcon:kFontIconRemove fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:40 backgroundColor:kColorClear target:self selector:@selector(close)];
        [_closeButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
        
        _restaurantName = [UIButton buttonWithType:UIButtonTypeCustom];
        [_restaurantName withText:@"" fontSize:kGeomFontSizeH1 width:10 height:10 backgroundColor:kColorClear textColor:kColorWhite borderColor:kColorClear target:self selector:@selector(showRestaurant)];
        _restaurantName.titleLabel.numberOfLines = 0;
        
        _tapGesture = [[UITapGestureRecognizer alloc] init];
        _closeTapGesture = [[UITapGestureRecognizer alloc] init];
        
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
        [_backgroundView addSubview:_caption];
        [_backgroundView addSubview:_userButton];
        [_backgroundView addSubview:_userViewButton];
        [_backgroundView addSubview:_numYums];
        [_backgroundView addSubview:_yumButton];
        [_backgroundView addSubview:_iv];
        [_backgroundView addSubview:_restaurantName];

//        [DebugUtilities addBorderToViews:@[_restaurantName, _numYums, _yumButton, _caption, _userButton, _iv, _userViewButton]];
    }
    return self;
}

- (void)showRestaurant {
    [_delegate viewPhotoVC:self showRestaurant:_restaurant];
    [self close];
}

- (void)showProfile {
    [_delegate viewPhotoVC:self showProfile:_user];
    [self close];
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
        [self dismissViewControllerAnimated:NO
                                 completion:^{
                                     ;
                                 }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tapGesture addTarget:self action:@selector(showRestaurant)];
    [_closeTapGesture addTarget:self action:@selector(close)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = UIColorRGBA(kColorOverlay10);
        _backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (restaurant == _restaurant) return;
    _restaurant = restaurant;
    
    [_restaurantName setTitle:_restaurant.name forState:UIControlStateNormal];
    [_restaurantName sizeToFit];
    [self.view setNeedsLayout];
}

- (void)setMio:(MediaItemObject *)mio {
    if (mio == _mio) return;
    _mio = mio;
    
    _caption.text = _mio.caption;
    
//    _userButton.hidden = _gradient.hidden = _yumButton.hidden = _numYums.hidden = YES;
    
//    _backgroundImage.image = nil;
    
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect frame;
    
    //adjust backgroundview horizontal parameters
    frame = _backgroundView.frame;
    frame.size.width = width(self.view) - 2*kGeomSpaceEdge;
    frame.origin.x = (width(self.view) - frame.size.width)/2;
    _backgroundView.frame = frame;

    frame = _restaurantName.frame;
    frame.size = [_restaurantName sizeThatFits:CGSizeMake(width(_backgroundView)-2*kGeomSpaceEdge, 100)];
    frame.origin.y = 0;
    frame.origin.x = (width(_backgroundView) - width(_restaurantName))/2;
    frame.size.height = kGeomDimensionsIconButton;
    _restaurantName.frame = frame;

    frame = _iv.frame;

    frame.size.height = _iv.image.size.height/((_iv.image.size.width) ? (_iv.image.size.width) : 1) * width(_backgroundView) - 2*kGeomSpaceEdge;
    frame.size.width = width(_backgroundView) - 2*kGeomSpaceEdge;
    frame.origin = CGPointMake(kGeomSpaceEdge, CGRectGetMaxY(_restaurantName.frame));
    _iv.frame = frame;

    frame = _userViewButton.frame;
    frame.origin.y = CGRectGetMaxY(_iv.frame) + kGeomSpaceInter;
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
    frame.origin = CGPointMake(width(_backgroundView) - kGeomDimensionsIconButton - kGeomSpaceEdge, CGRectGetMaxY(_iv.frame) + kGeomSpaceInter);
    _yumButton.frame = frame;

    [_numYums sizeToFit];
    frame = _numYums.frame;
//    frame.size = CGSizeMake(width(_numYums), kGeomDimensionsIconButton);
    frame.origin = CGPointMake(width(_backgroundView) - width(_numYums) - kGeomSpaceEdge, CGRectGetMaxY(_yumButton.frame));
    _numYums.frame = frame;
    _numYums.center = CGPointMake(_yumButton.center.x, _numYums.center.y);

    CGFloat distanceFromEdge = (CGRectGetMaxX(_userButton.frame) > (width(_backgroundView) - CGRectGetMinX(_numYums.frame))) ? CGRectGetMaxX(_userButton.frame) : (width(_backgroundView) - CGRectGetMinX(_numYums.frame));
    
    frame = _caption.frame;
    frame.size = [_caption sizeThatFits:CGSizeMake(width(_backgroundView) - 2*distanceFromEdge, 100)];
    frame.origin.y = CGRectGetMaxY(_iv.frame) + kGeomSpaceInter;
    frame.origin.x = (width(_backgroundView) - frame.size.width)/2;
    _caption.frame = frame;

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
//                [weakSelf.delegate photoCell:weakSelf likePhoto:_mediaItemObject];
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
//                [weakSelf.delegate photoCell:weakSelf likePhoto:_mediaItemObject];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
}

- (void)updateNumYums {
    __weak ViewPhotoVC *weakSelf = self;
    [OOAPI getNumMediaItemLikes:_mio.mediaItemId success:^(NSUInteger count) {
        if (count) {
            [_numYums setTitle:[NSString stringWithFormat:@"%lu %@", count, (count == 1) ? @"yum" : @"yums"] forState:UIControlStateNormal];
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

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
#import "UserListVC.h"
#import "AppDelegate.h"
#import "ListsVC.h"
#import "ShowMediaItemAnimator.h"

@interface ViewPhotoVC ()
@property (nonatomic, strong) UIButton *captionButton;
@property (nonatomic, strong) UIButton *yumButton;
@property (nonatomic, strong) UIButton *numYums;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) OOUserView *userViewButton;
@property (nonatomic, strong) UIButton *restaurantName;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UITapGestureRecognizer *showRestaurantTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *yumPhotoTapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UserObject *user;
@property (nonatomic, strong) UINavigationController *aNC;
@property (nonatomic) CGPoint originPoint;
@property (nonatomic, strong) ViewPhotoVC *nextPhoto;
@property (nonatomic) SwipeType swipeType;
@end

static CGFloat kDismissTolerance = 20;
static CGFloat kNextPhotoTolerance = 40;

@implementation ViewPhotoVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = UIColorRGBA(kColorBlack);
        _backgroundView.alpha = kAlphaBackground;
        
        _iv = [[UIImageView alloc] init];
        _iv.contentMode = UIViewContentModeScaleAspectFit;
        _iv.backgroundColor = UIColorRGBA(kColorClear);
        
        _captionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captionButton withText:@"" fontSize:kGeomFontSizeH3 width:0 height:0 backgroundColor:kColorClear textColor:kColorWhite borderColor:kColorClear target:nil selector:nil];
        _captionButton.titleLabel.numberOfLines = 0;
        _captionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _captionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton withIcon:kFontIconRemove fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:40 backgroundColor:kColorClear target:self selector:@selector(close)];
        [_closeButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];

        _optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_optionsButton withIcon:kFontIconMore fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:40 backgroundColor:kColorClear target:self selector:@selector(showOptions)];
        [_optionsButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];

        _restaurantName = [UIButton buttonWithType:UIButtonTypeCustom];
        [_restaurantName withText:@"" fontSize:kGeomFontSizeH1 width:10 height:10 backgroundColor:kColorClear textColor:kColorWhite borderColor:kColorClear target:self selector:@selector(showRestaurant)];
        _restaurantName.titleLabel.numberOfLines = 0;
        
        _showRestaurantTapGesture = [[UITapGestureRecognizer alloc] init];
        _yumPhotoTapGesture = [[UITapGestureRecognizer alloc] init];
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
//        [DebugUtilities addBorderToViews:@[_iv]];
//        [DebugUtilities addBorderToViews:@[_closeButton, _optionsButton, _restaurantName, _iv, _numYums, _yumButton, _userButton, _userViewButton, _captionButton]];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)showOptions {
    UIAlertController *photoOptions = [UIAlertController alertControllerWithTitle:@"" message:@"What would you like to do?" preferredStyle:UIAlertControllerStyleActionSheet];



    UIAlertAction *deletePhoto = [UIAlertAction actionWithTitle:@"Delete Photo"
                                                          style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                                                              __weak ViewPhotoVC *weakSelf = self;
                                                              ON_MAIN_THREAD(^{
                                                                  [weakSelf deletePhoto:_mio];
                                                              });
                                                              
                                                          }];
    UIAlertAction *addRestaurantToList = [UIAlertAction actionWithTitle:@"Add Restaurant to a List"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                             [self addToList:_restaurant];
                                                         }];
    UIAlertAction *flagPhoto = [UIAlertAction actionWithTitle:@"Flag Photo"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            [self flagPhoto:_mio];
                                                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       NSLog(@"Cancel");
                                                   }];

    UserObject *uo = [Settings sharedInstance].userObject;

    [photoOptions addAction:addRestaurantToList];
    if (_mio.sourceUserID == uo.userID) {
        [photoOptions addAction:deletePhoto];
    } else {
        [photoOptions addAction:flagPhoto];
    }
    [photoOptions addAction:cancel];

    [self presentViewController:photoOptions animated:YES completion:^{
        ;
    }];
}

- (void)deletePhoto:(MediaItemObject *)mio {
    NSUInteger userID = [Settings sharedInstance].userObject.userID;
    __weak ViewPhotoVC *weakSelf = self;
    
    if (mio.sourceUserID == userID) {
        [OOAPI deletePhoto:mio success:^{
            [weakSelf close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFoodFeedNeedsUpdate object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPhotoDeleted object:mio];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
}

- (void)flagPhoto:(MediaItemObject *)mio {
    [OOAPI flagMediaItem:mio.mediaItemId success:^(NSArray *names) {
        NSLog(@"photo flagged: %lu", (unsigned long)mio.mediaItemId);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"could not flag the photo: %@", error);
    }];
}

- (void)addToList:(RestaurantObject *)restaurant {
    ListsVC *vc = [[ListsVC alloc] init];
    vc.restaurantToAdd = restaurant;
    [vc getLists];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addCaption {
    _aNC = [[UINavigationController alloc] init];

    AddCaptionToMIOVC *vc = [[AddCaptionToMIOVC alloc] init];
    vc.delegate = self;
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    vc.mio = _mio;

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

    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)tapGestureRecognized:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)gesture;
        if (tapGesture.state == UIGestureRecognizerStateEnded) {
            if (tapGesture == _showRestaurantTapGesture) {
                [self showRestaurant];
            } else if (tapGesture == _yumPhotoTapGesture) {
                [self yumPhotoTapped];
            }
        }
    }
}

- (void)showRestaurant {
    if ([_delegate respondsToSelector:@selector(viewPhotoVC:showRestaurant:)]) {
        [_delegate viewPhotoVC:self showRestaurant:_restaurant];
    }
}

- (void)showProfile {
    if ([_delegate respondsToSelector:@selector(viewPhotoVC:showProfile:)]) {
        [_delegate viewPhotoVC:self showProfile:_user];
    }
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user {
    [self showProfile];
}

- (void)showYums {
    __weak ViewPhotoVC *weakSelf = self;
    [OOAPI getMediaItemYummers:_mio success:^(NSArray *users) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showYummers:users];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)showYummers:(NSArray *)users {
    UserListVC *vc = [[UserListVC alloc] init];
    vc.desiredTitle = @"Yummers";
    vc.user= _user;
    vc.usersArray = [NSMutableArray arrayWithArray:users];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)close {
    if ([_delegate respondsToSelector:@selector(viewPhotoVCClosed:)]) {
        [_delegate viewPhotoVCClosed:self];
    }
    
    _direction = 0;
    _nextPhoto = nil;
    self.transitioningDelegate = _dismissTransitionDelegate;
    self.navigationController.delegate = _dismissNCDelegate;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:_iv];
    [self.view addSubview:_restaurantName];
    [self.view addSubview:_closeButton];
    [self.view addSubview:_captionButton];
    [self.view addSubview:_userButton];
    [self.view addSubview:_userViewButton];
    [self.view addSubview:_numYums];
    [self.view addSubview:_yumButton];
    [self.view addSubview:_backgroundView];
    [self.view sendSubviewToBack:_backgroundView];

    [_showRestaurantTapGesture addTarget:self action:@selector(tapGestureRecognized:)];
    [_showRestaurantTapGesture setNumberOfTapsRequired:1];
    [_yumPhotoTapGesture addTarget:self action:@selector(tapGestureRecognized:)];
    [_yumPhotoTapGesture setNumberOfTapsRequired:2];
    
    [_showRestaurantTapGesture requireGestureRecognizerToFail:_yumPhotoTapGesture];
    [_backgroundView addGestureRecognizer:_showRestaurantTapGesture];
    [_backgroundView addGestureRecognizer:_yumPhotoTapGesture];
    [self.view addGestureRecognizer:_panGesture];
    
//    [DebugUtilities addBorderToViews:@[self.view]];
}

- (void)pan:(UIGestureRecognizer *)gestureRecognizer {
    if (_panGesture != gestureRecognizer) return;

    if (_panGesture.state == UIGestureRecognizerStateBegan) {
        _swipeType = kSwipeTypeNone;
        CGPoint delta = CGPointMake([_panGesture translationInView:self.view].x, [_panGesture translationInView:self.view].y);
        
        _interactiveController = [[UIPercentDrivenInteractiveTransition alloc] init];
        
        NSLog(@"began: %@", NSStringFromCGPoint(delta));
        _originPoint = CGPointMake([_panGesture locationInView:self.view].x, [_panGesture locationInView:self.view].y);
        
    } else if (_panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = CGPointMake([_panGesture translationInView:self.view].x, [_panGesture translationInView:self.view].y);
 
//        NSLog(@"changed: %@", NSStringFromCGPoint(delta));

        if (_swipeType == kSwipeTypeDismiss) {
            _iv.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, delta.y);
        }
        if (_swipeType == kSwipeTypeNone &&
            fabs(delta.y) > kDismissTolerance) {
            _swipeType = kSwipeTypeDismiss;
            [self.interactiveController cancelInteractiveTransition];
            self.interactiveController = nil;
        } else if (_swipeType != kSwipeTypeDismiss && delta.x > 0) {

            NSLog(@"show next photo? %f", delta.x);
            if (!_nextPhoto && _nextPhoto.direction != 1) {
                _swipeType = kSwipeTypeNextPhoto;
                NSLog(@"get next photo in direction 1");
                [self.interactiveController cancelInteractiveTransition];
                if (_nextPhoto) [_nextPhoto.interactiveController cancelInteractiveTransition];
                _direction = 1;
                _nextPhoto = [self getNextVC:_direction];
                
                self.transitioningDelegate = self;
                self.navigationController.delegate = self;
                
                [self.navigationController pushViewController:_nextPhoto animated:YES];
            }
        } else if (_swipeType != kSwipeTypeDismiss && delta.x < 0) {
            NSLog(@"show next photo? %f", delta.x);
            if (!_nextPhoto && _nextPhoto.direction != -1) {
                _swipeType = kSwipeTypeNextPhoto;
                NSLog(@"get next photo in direction -1");
                if (_nextPhoto) [_nextPhoto.interactiveController cancelInteractiveTransition];
                [self.interactiveController cancelInteractiveTransition];
                _direction = -1;
                _nextPhoto = [self getNextVC:_direction];
                
                self.transitioningDelegate = self;
                self.navigationController.delegate = self;
                
                [self.navigationController pushViewController:_nextPhoto animated:YES];
            }
        }
        
        [self.interactiveController updateInteractiveTransition:fabs(delta.x/width(self.view))];

    } else if (_panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint delta = CGPointMake([_panGesture translationInView:self.view].x, [_panGesture translationInView:self.view].y);

        NSLog(@"changed: %@ %f %f %f", NSStringFromCGPoint(delta), width(self.view), fabs(delta.x)/width(self.view), self.interactiveController.percentComplete);
        
        if (_swipeType == kSwipeTypeDismiss &&
            fabs(delta.y) > kDismissTolerance) {
            NSLog(@"dismiss photo");
//            [self.interactiveController cancelInteractiveTransition];
//            self.interactiveController = nil;
            [self close];
        } else if (_swipeType == kSwipeTypeNextPhoto &&
                   fabs(delta.x) > kNextPhotoTolerance) {
            NSLog(@"show next photo confirmed");
            [self.interactiveController finishInteractiveTransition];
        } else {
            NSLog(@"cancel transition");
            [self.interactiveController cancelInteractiveTransition];
            self.interactiveController = nil;
            _direction = 0;
            _nextPhoto = nil;
            [UIView animateWithDuration:0.1 animations:^{
                _iv.transform = CGAffineTransformIdentity;
            }];
        }
    }
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
        animator.duration = 0.65;
        animationController = animator;
    } else if ([fromVC isKindOfClass:[ViewPhotoVC class]] && operation == UINavigationControllerOperationPop) {
        ShowMediaItemAnimator *animator = [[ShowMediaItemAnimator alloc] init];
        ViewPhotoVC *vc = (ViewPhotoVC *)fromVC;
        animator.presenting = NO;
        animator.originRect = vc.originRect;
        animator.duration = 0.65;
        animationController = animator;
    } else {
        NSLog(@"*** operation=%lu, fromVC=%@ , toVC=%@", operation, [fromVC class], [toVC class]);
    }
    
    return animationController;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController*)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactiveController;
}

//- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
//    return _nextPhoto.interactiveController;
//}
//
//- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
//    return self.interactiveController;
//}

- (ViewPhotoVC *)getNextVC:(NSUInteger)direction {
    NSInteger nextIndex = _currentIndex + (-direction);
    NSLog(@"currentIndex=%lu nextIndex=%lu", _currentIndex, nextIndex);
    
    if (nextIndex < 0 || nextIndex >= [_restaurants count]) return nil;
    
    self.direction = direction;
    
    ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];
    RestaurantObject *r = [_restaurants objectAtIndex:nextIndex];
    MediaItemObject *mio = ([r.mediaItems count]) ? [r.mediaItems objectAtIndex:0] : nil;
    
    vc.originRect = _originRect;
    vc.mio = mio;
    vc.restaurant = r;
    vc.direction = direction;
    vc.delegate = _delegate;
    vc.restaurants = _restaurants;
    vc.currentIndex = nextIndex;

    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    vc.navigationController.delegate = self;
    
    vc.dismissNCDelegate = _dismissNCDelegate;
    vc.dismissTransitionDelegate = _dismissTransitionDelegate;

    return vc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showComponents:(BOOL)show {
    _optionsButton.hidden =
    _closeButton.hidden =
    _captionButton.hidden =
    _restaurantName.hidden =
    _yumButton.hidden =
    _userButton.hidden =
    _userViewButton.hidden = !show;
    
    if (show) {
        if (_numYums) {
            _numYums.hidden = NO;
        } else {
            _numYums.hidden = YES;
        }
    } else {
        _numYums.hidden = YES;
    }
}

- (void)setComponentsAlpha:(CGFloat)alpha {
    _optionsButton.alpha =
    _closeButton.alpha =
    _captionButton.alpha =
    _restaurantName.alpha =
    _yumButton.alpha =
    _userButton.alpha =
    _userViewButton.alpha =
    _numYums.alpha =
    _iv.alpha =
    alpha;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _backgroundView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.tabBarController.tabBar.hidden = YES;
        self.navigationController.navigationBarHidden = YES;
        _backgroundView.alpha = kAlphaBackground;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        self.tabBarController.tabBar.hidden = NO;
        self.navigationController.navigationBarHidden = NO;
        } completion:^(BOOL finished) {
        ;
    }];
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
    [self.view layoutIfNeeded];
}

- (void)setMio:(MediaItemObject *)mio {
    if (mio == _mio) return;
    _mio = mio;
    
    if (_mio.source == kMediaItemTypeOomami) {
        [self.view addSubview:_optionsButton];
    } else {
        [_optionsButton removeFromSuperview];
    }
    
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
    
    __weak UIImageView *weakIV = _iv;
    __weak ViewPhotoVC *weakSelf = self;
    
    _requestOperation = [api getRestaurantImageWithMediaItem:_mio
                                                    maxWidth:self.view.frame.size.width
                                                   maxHeight:0 success:^(NSString *link) {
                            [weakIV setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
//                                                 [weakIV setAlpha:0.0];
                                                 weakIV.image = image;
//                                                 [UIView beginAnimations:nil context:NULL];
//                                                 [UIView setAnimationDuration:0.1];
                                                 [weakIV setAlpha:1.0];
//                                                 [UIView commitAnimations];
                                                 [weakSelf.view setNeedsLayout];
                                                 [weakSelf.view layoutIfNeeded];
                                                 NSLog(@"iv got image viewFrame %@", NSStringFromCGRect(weakIV.frame));
                                             });
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             NSLog(@"ERROR: failed to get image: %@", error);
                                         }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: failed to get image: %@", error);;
    }];
    
    if (_mio.source == kMediaItemTypeOomami) {
        [self updateNumYums];
        
        __weak ViewPhotoVC *weakSelf = self;
    
        [OOAPI getMediaItemLiked:_mio.mediaItemId byUser:[Settings sharedInstance].userObject.userID success:^(BOOL liked) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.yumButton setSelected:liked];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.yumButton setSelected:NO];
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
                weakSelf.userViewButton.user = user;
                [weakSelf.userButton setTitle:userName forState:UIControlStateNormal];
                [weakSelf.userButton sizeToFit];
                [weakSelf.view bringSubviewToFront:_userViewButton];
                [weakSelf.view setNeedsLayout];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: failed to get user: %@", error);;
        }];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
//    if (!_iv.image.size.width) {
//        return; // Fix for NaN crash.
//    }
    
    self.view.frame = APP.window.bounds;
    CGRect frame;
    CGFloat imageMaxY;
        
    _backgroundView.frame = self.view.frame;
    
//    _iv.center = self.view.center;
    frame = _iv.frame;
    frame.size.height = frame.size.height;// (maxImageHeight > frame.size.height) ? frame.size.height : maxImageHeight;

    
    CGFloat imageWidth = width(self.view);
//    CGFloat imageHeight = (imageWidth < width(self.view)) ? height(_iv) : _iv.image.size.height/((_iv.image.size.width)?(_iv.image.size.width):1) * width(self.view);
    
    CGFloat imageHeight = (imageWidth < width(self.view)) ? height(_iv) : _mio.height/_mio.width * width(self.view);
    
    frame.size.width = imageWidth;
    frame.size.height = imageHeight;
    _iv.frame = frame;
    _iv.center = self.view.center;
    
    frame = _restaurantName.frame;
    frame.size.width = width(self.view)-2*kGeomSpaceEdge;
    frame.origin.y = CGRectGetMidY(self.view.frame) - imageHeight/2 - kGeomDimensionsIconButton;
    frame.origin.x = (width(self.view) - width(_restaurantName))/2;
    frame.size.height = kGeomDimensionsIconButton;
    _restaurantName.frame = frame;
    
    frame = _closeButton.frame;
    frame.origin = CGPointMake(0, 0);
    _closeButton.frame = frame;
    
    frame = _optionsButton.frame;
    frame.origin = CGPointMake(width(self.view)-width(_optionsButton), 0);
    _optionsButton.frame = frame;

    imageMaxY = CGRectGetMidY(_iv.frame) + imageHeight/2;

    frame = _userButton.frame;
    frame.origin.y = height(self.view) - 3*kGeomDimensionsIconButton/4;
    frame.origin.x = kGeomSpaceEdge;
    frame.size.height = 3*kGeomDimensionsIconButton/4;
    _userButton.frame = frame;
    
    if (_mio.source == kMediaItemTypeOomami) {
        frame = _userViewButton.frame;
        //      frame.origin.y = imageMaxY + kGeomSpaceCellPadding;
        frame.origin.x = kGeomSpaceEdge;
        frame.size.height = kGeomDimensionsIconButton;
        frame.size.width = kGeomDimensionsIconButton;
        frame.origin.y = CGRectGetMinY(_userButton.frame) - kGeomDimensionsIconButton;
        _userViewButton.frame = frame;
    } else {
        _userViewButton.frame = CGRectZero;
    }
    
    if (_mio.source == kMediaItemTypeOomami) {
        [_numYums sizeToFit];
        frame = _numYums.frame;
        frame.origin = CGPointMake(width(self.view) - width(_numYums) - kGeomSpaceEdge, height(self.view)-3*kGeomDimensionsIconButton/4);
        frame.size.height = 3*kGeomDimensionsIconButton/4;
        _numYums.frame = frame;
        _numYums.center = CGPointMake(_yumButton.center.x, _numYums.center.y);
        
        frame = _yumButton.frame;
        frame.size = CGSizeMake(kGeomDimensionsIconButton, kGeomDimensionsIconButton);
        frame.origin = CGPointMake(width(self.view) - kGeomDimensionsIconButton - kGeomSpaceEdge, CGRectGetMinY(_numYums.frame)-CGRectGetHeight(frame));
        _yumButton.frame = frame;
    } else {
        _yumButton.frame = CGRectZero;
        _numYums.frame = CGRectZero;
    }
    
    frame = _captionButton.frame;
    frame.size.width = CGRectGetMinX(_yumButton.frame) - CGRectGetMaxX(_userViewButton.frame);
    frame.size.height = [_captionButton.titleLabel sizeThatFits:CGSizeMake(frame.size.width, 200)].height;
    frame.origin.y = CGRectGetMinY(_userViewButton.frame) + (CGRectGetHeight(_userViewButton.frame) - frame.size.height)/2;
    frame.origin.x = (width(self.view) - frame.size.width)/2;
    _captionButton.frame = frame;
    
    NSLog(@"imageView frame = %@", NSStringFromCGRect(_iv.frame));
}

- (void)yumPhotoTapped {
    __weak ViewPhotoVC *weakSelf = self;
    if (_yumButton.isSelected) {
        NSLog(@"unlike photo");
        NSUInteger userID = [Settings sharedInstance].userObject.userID;
        [OOAPI unsetMediaItemLike:_mio.mediaItemId forUser:userID success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.yumButton setSelected:NO];
                [weakSelf updateNumYums];
                NOTIFY_WITH(kNotificationUserStatsChanged, @(userID));
                NOTIFY_WITH(kNotificationMediaItemAltered, @(_mio.mediaItemId))
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: failed to unlike photo: %@", error);;
        }];
    } else {
        NSLog(@"like photo");
        NSUInteger userID = [Settings sharedInstance].userObject.userID;
        [OOAPI setMediaItemLike:_mio.mediaItemId forUser:userID success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.yumButton setSelected:YES];
                [weakSelf updateNumYums];
                NOTIFY_WITH(kNotificationUserStatsChanged, @(userID));
                NOTIFY_WITH(kNotificationMediaItemAltered, @(_mio.mediaItemId))
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: failed to like photo: %@", error);;
        }];
    }
    
    UserObject* myself= [Settings sharedInstance].userObject;
    if (_mio.sourceUserID == myself.userID) {
        // RULE: If I like or unlike my own photo, I will need to update my profile screen.
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOwnProfileNeedsUpdate object:nil];
    }
}

- (void)updateNumYums {
    __weak ViewPhotoVC *weakSelf = self;
    [OOAPI getNumMediaItemLikes:_mio.mediaItemId success:^(NSUInteger count) {
        if (count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.numYums setTitle:[NSString stringWithFormat:@"%lu %@", (unsigned long)count, (count == 1) ? @"yum" : @"yums"] forState:UIControlStateNormal];
                [weakSelf.view setNeedsLayout];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                weakSelf.numYums.hidden = YES;
                [weakSelf.view setNeedsLayout];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
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

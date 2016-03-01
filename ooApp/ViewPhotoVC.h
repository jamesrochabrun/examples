//
//  ViewPhotoVC.h
//  ooApp
//
//  Created by Anuj Gujar on 1/8/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "SubBaseVC.h"
#import "MediaItemObject.h"
#import "RestaurantObject.h"
#import "UserObject.h"
#import "AddCaptionToMIOVC.h"
#import "OOUserView.h"

static CGFloat kAlphaBackground = 0.9;

typedef enum {
    kSwipeTypeNone,
    kSwipeTypeDismiss,
    kSwipeTypeNextPhoto
} SwipeType;

@class ViewPhotoVC;

@protocol ViewPhotoVCDelegate <NSObject>

@optional
- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showRestaurant:(RestaurantObject *)restaurant;
- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showProfile:(UserObject *)user;
- (void)viewPhotoVCClosed:(ViewPhotoVC *)viewPhotoVC;
@end

@interface ViewPhotoVC : SubBaseVC <OOUserViewDelegate,
                                    OOTextEntryVCDelegate,
                                    UINavigationControllerDelegate,
                                    UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) MediaItemObject *mio;
@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, weak) id<ViewPhotoVCDelegate> delegate;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic) CGRect originRect;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSInteger direction;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> dismissTransitionDelegate;
@property (nonatomic, strong) id<UINavigationControllerDelegate> dismissNCDelegate;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveController;

- (void)showComponents:(BOOL)show;
- (void)setComponentsAlpha:(CGFloat)alpha;

@end

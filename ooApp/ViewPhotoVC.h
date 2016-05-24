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
#import "UnverifiedUserVC.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

static CGFloat kAlphaBackground = 1;

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

@interface ViewPhotoVC : UIViewController <OOUserViewDelegate,
                                    OOTextEntryVCDelegate,
                                    UINavigationControllerDelegate,
                                    UIViewControllerTransitioningDelegate,
                                    UnverifiedUserVCDelegate,
                                    UIActivityItemSource,
                                    FBSDKSharingDelegate>
@property (nonatomic, strong) MediaItemObject *mio;
@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic) CGRect originRect;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSInteger direction;
@property (nonatomic, weak) id<ViewPhotoVCDelegate> delegate;
//@property (nonatomic, weak) UIViewController *rootViewController;;
@property (nonatomic, weak) id<UIViewControllerTransitioningDelegate> dismissTransitionDelegate;
@property (nonatomic, weak) id<UINavigationControllerDelegate> dismissNCDelegate;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveController;

- (void)showComponents:(BOOL)show;
- (void)setComponentsAlpha:(CGFloat)alpha;
- (UIImage *)shareImage;

@end

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

@class ViewPhotoVC;

@protocol ViewPhotoVCDelegate <NSObject>
- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showRestaurant:(RestaurantObject *)restaurant;
- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showProfile:(UserObject *)user;
- (void)viewPhotoVCClosed:(ViewPhotoVC *)viewPhotoVC;
@end

@interface ViewPhotoVC : SubBaseVC <OOUserViewDelegate, OOTextEntryVCDelegate>
@property (nonatomic, strong) MediaItemObject *mio;
@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, weak) id<ViewPhotoVCDelegate> delegate;
@property (nonatomic, weak) UINavigationController *nc;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic) CGRect originRect;
@property (nonatomic, strong) UIView *backgroundView;

- (void)showComponents:(BOOL)show;
@end

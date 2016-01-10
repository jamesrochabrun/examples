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
#import "OOUserView.h"

@class ViewPhotoVC;

@protocol ViewPhotoVCDelegate
- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showRestaurant:(RestaurantObject *)restaurant;
- (void)viewPhotoVC:(ViewPhotoVC *)viewPhotoVC showProfile:(UserObject *)user;
@end

@interface ViewPhotoVC : SubBaseVC <OOUserViewDelegate>
@property (nonatomic, strong) MediaItemObject *mio;
@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, weak) id<ViewPhotoVCDelegate> delegate;
@end

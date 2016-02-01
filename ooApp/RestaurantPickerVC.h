//
//  RestaurantPickerVC.h
//  ooApp
//
//  Created by Anuj Gujar on 12/20/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantObject.h"
#import "SubBaseVC.h"

@class RestaurantPickerVC;

@protocol RestaurantPickerVCDelegate
- (void)restaurantPickerVC:(RestaurantPickerVC *)restaurantPickerVC restaurantSelected:(RestaurantObject *)restaurant;
- (void)restaurantPickerVCCanceled:(RestaurantPickerVC *)restaurantPickerVC;
@end

@interface RestaurantPickerVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) id<RestaurantPickerVCDelegate> delegate;
@property (nonatomic, strong) UIImage *imageToUpload;
@property (nonatomic) CLLocationCoordinate2D location;

@end

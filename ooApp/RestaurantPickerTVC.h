//
//  RestaurantPickerTVC.h
//  ooApp
//
//  Created by Anuj Gujar on 12/20/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantObject.h"

@class RestaurantPickerTVC;

@protocol RestaurantPickerTVCDelegate
- (void)restaurantPickerTVC:(RestaurantPickerTVC *)restaurantPickerTVC restaurantSelected:(RestaurantObject *)restaurant;
- (void)restaurantPickerTVCCanceled:(RestaurantPickerTVC *)restaurantPickerTVC;
@end

@interface RestaurantPickerTVC : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<RestaurantPickerTVCDelegate> delegate;

@end

//
//  ChangeLocationVC.h
//  ooApp
//
//  Created by Anuj Gujar on 2/5/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "OOAPI.h"

@class ChangeLocationVC;

@protocol ChangeLocationVCDelegate <NSObject>
- (void)changeLocationVC:(ChangeLocationVC *)changeLocationVC locationSelected:(CLPlacemark *)placemark;
- (void)changeLocationVCCanceled:(ChangeLocationVC *)changeLocationVC;
@end


@interface ChangeLocationVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) id<ChangeLocationVCDelegate> delegate;
@end

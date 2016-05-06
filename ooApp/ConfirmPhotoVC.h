//
//  ConfirmPhotoVC.h
//  ooApp
//
//  Created by Anuj Gujar on 2/5/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "OOAPI.h"

@class ConfirmPhotoVC;

@protocol ConfirmPhotoVCDelegate <NSObject>
- (void)confirmPhotoVCAccepted:(ConfirmPhotoVC *)confirmPhotoVC photoInfo:(NSDictionary *)photoInfo image:(UIImage *)image;
- (void)confirmPhotoVCCancelled:(ConfirmPhotoVC *)confirmPhotoVC getNewPhoto:(BOOL)getNewPhoto;
@end


@interface ConfirmPhotoVC : SubBaseVC <UISearchBarDelegate>
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) NSDictionary *photoInfo;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) id<ConfirmPhotoVCDelegate> delegate;
@end

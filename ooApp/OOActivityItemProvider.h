//
//  OOActivityItemProvider.h
//  ooApp
//
//  Created by Anuj Gujar on 10/27/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantObject.h"
#import "MediaItemObject.h"
#import "ListObject.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

typedef enum {
    kShareTypeList = 0,
    kShareTypePlace = 1,
    KShareTypeItem = 2,
    kShareTypeApp = 3
} kShareType;

@interface OOActivityItemProvider : UIActivityItemProvider <UIActivityItemSource, FBSDKSharingDelegate>


@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, strong) ListObject *list;
@property (nonatomic, strong) MediaItemObject *mio;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *username;

@end

@interface OOActivityIcon : UIActivity

@end

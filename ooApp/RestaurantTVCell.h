//
//  RestaurantTVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 9/24/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ObjectTVCell.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import <GoogleMaps/GoogleMaps.h>

@interface RestaurantTVCell : ObjectTVCell

@property (nonatomic, strong) RestaurantObject *restaurant;

@property (nonatomic, strong) ListObject *listToAddTo;

@end

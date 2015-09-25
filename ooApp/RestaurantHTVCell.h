//
//  RestaurantHTVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 9/24/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "HorizonalTVCell.h"
#import "RestaurantObject.h"
#import <GoogleMaps/GoogleMaps.h>

@interface RestaurantHTVCell : HorizonalTVCell

@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, strong) GMSMarker *marker;

@end

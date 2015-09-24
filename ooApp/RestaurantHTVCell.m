//
//  RestaurantHTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 9/24/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantHTVCell.h"
#import "LocationManager.h"

@implementation RestaurantHTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (restaurant == _restaurant) return;
    _restaurant = restaurant;
    self.thumbnail.image = nil;
    self.header.text = _restaurant.name;
    self.subHeader1.text = (_restaurant.isOpen) ? @"Open Now" : @"Not Open";
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    self.subHeader2.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];

    OOAPI *api = [[OOAPI alloc] init];
    
    if (_restaurant.imageRef) {
        self.requestOperation = [api getRestaurantImageWithImageRef:_restaurant.imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.thumbnail setImageWithURL:[NSURL URLWithString:link]];
            });
        } failure:^(NSError *error) {
            ;
        }];
    }
}

@end

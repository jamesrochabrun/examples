//
//  RestaurantTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 9/24/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "RestaurantTVCell.h"
#import "LocationManager.h"

@interface RestaurantTVCell ()

@end

@implementation RestaurantTVCell

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
    
    NSString *imageRef;
    if ([restaurant.mediaItems count]) {
        imageRef = ((MediaItemObject*)[restaurant.mediaItems objectAtIndex:0]).reference;
    } else if ([restaurant.imageRefs count]) {
        imageRef = ((ImageRefObject *)[restaurant.imageRefs objectAtIndex:0]).reference;
    }
    
    if (imageRef) {
        self.requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.thumbnail setImageWithURL:[NSURL URLWithString:link]];
            });
        } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
            ;
        }];
    }
    [self setupActionButton];
}

- (void)setListToAddTo:(ListObject *)listToAddTo {
    if (_listToAddTo == listToAddTo) return;
    _listToAddTo = listToAddTo;
    [self setupActionButton];
}

- (void)setupActionButton {
    if (_listToAddTo && _restaurant.restaurantID) {
        self.actionButton.hidden = NO;
        [self.actionButton setTitle:kFontIconAdd forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(addToList) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        self.actionButton.hidden = YES;
    }
}

- (void)addToList {
    OOAPI *api = [[OOAPI alloc] init];
    [api addRestaurants:@[_restaurant] toList:_listToAddTo.listID success:^(id response) {
        ;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

@end

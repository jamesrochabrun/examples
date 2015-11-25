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
    self.thumbnail.image = [UIImage imageNamed:@"background-image.jpg"];
    self.header.text = _restaurant.name;
    self.subHeader1.text = [NSString stringWithFormat:@"%@", (_restaurant.isOpen) ? @"Open Now" : @"Not Open"];
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    self.subHeader2.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];

    OOAPI *api = [[OOAPI alloc] init];
    
    NSString *imageRef;
    MediaItemObject *mio;
    if ([restaurant.mediaItems count]) {
        mio = [restaurant.mediaItems objectAtIndex:0];
    } else if ([restaurant.imageRefs count]) {
        imageRef = ((ImageRefObject *)[restaurant.imageRefs objectAtIndex:0]).reference;
    }
    
    if (mio) {
        self.requestOperation = [api getRestaurantImageWithMediaItem:mio
                                                            maxWidth:width(self)
                                                           maxHeight:0
                                                             success:^(NSString *link) {
            __weak UIImageView *weakIV = self.thumbnail;
            __weak RestaurantTVCell *weakSelf = self;
            [self.thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                  placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               ON_MAIN_THREAD(^ {
                                                   [weakIV setAlpha:0.0];
                                                   weakIV.image = image;
                                                   [UIView beginAnimations:nil context:NULL];
                                                   [UIView setAnimationDuration:0.3];
                                                   [weakIV setAlpha:1.0];
                                                   [UIView commitAnimations];
                                                   [weakSelf setNeedsUpdateConstraints];
                                                   [weakSelf setNeedsLayout];
                                               });
                                           }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               weakIV.image = [UIImage imageNamed:@"background-image.jpg"];
                                           }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    } else if (imageRef) {
        self.requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.thumbnail setImageWithURL:[NSURL URLWithString:link]];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

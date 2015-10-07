//
//  ListTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 10/1/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ListTVCell.h"

@implementation ListTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setList:(ListObject *)list {
    if (list == _list) return;
    _list = list;
    self.thumbnail.image = nil;
    self.header.text = _list.name;
//    self.subHeader1.text = (_list.isOpen) ? @"Open Now" : @"Not Open";
//    
//    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
//    
//    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
//    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
//    
//    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
//    self.subHeader2.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];
//    
//    OOAPI *api = [[OOAPI alloc] init];
//    
//    NSString *imageRef;
//    if ([restaurant.mediaItems count]) {
//        imageRef = ((MediaItemObject*)[restaurant.mediaItems objectAtIndex:0]).reference;
//    } else if ([restaurant.imageRefs count]) {
//        imageRef = ((ImageRefObject *)[restaurant.imageRefs objectAtIndex:0]).reference;
//    }
//    
//    if (imageRef) {
//        self.requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.thumbnail setImageWithURL:[NSURL URLWithString:link]];
//            });
//        } failure:^(NSError *error) {
//            ;
//        }];
//    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

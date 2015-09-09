//
//  ListCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 8/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListCVCell.h"
#import "LocationManager.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "UIImageView+AFNetworking.h"

@interface ListCVCell ()

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *distance;
@property (nonatomic, strong) UILabel *rating;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIView *overlay;

@end

@implementation ListCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorRGBA(kColorBlack);
        _name = [[UILabel alloc] init];
        _distance = [[UILabel alloc] init];
        _rating = [[UILabel alloc] init];
        _backgroundImage = [[UIImageView alloc] init];
        _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImage.clipsToBounds = YES;
        _overlay = [[UIView alloc] init];
        
        _overlay.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        _name.translatesAutoresizingMaskIntoConstraints = NO;
        _rating.translatesAutoresizingMaskIntoConstraints = NO;
        _distance.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_name withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail] textColor:kColorWhite backgroundColor:kColorClear];
        [_distance withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail] textColor:kColorWhite backgroundColor:kColorClear];
        [_rating withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail] textColor:kColorWhite backgroundColor:kColorClear];

        _overlay.backgroundColor = UIColorRGBA(kColorStripOverlay);
        
        [self addSubview:_backgroundImage];
        [self addSubview:_overlay];
        [self addSubview:_distance];
        [self addSubview:_rating];
        [self addSubview:_name];

//        [DebugUtilities addBorderToViews:@[self]];
        [self layout];
    }
    return self;
}

- (void)layout {
    CGSize labelSize = [@"Abc" sizeWithAttributes:@{NSFontAttributeName:_name.font}];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightListRow), @"labelY":@((kGeomHeightListRow-labelSize.height)/2), @"buttonY":@(kGeomHeightListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightListRow-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _name, _backgroundImage, _rating, _distance, _overlay);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_overlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_name]-(15)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_distance]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_rating]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_overlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_name(<=nameWidth)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rating]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_distance]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
    _name.text = _restaurant.name;
    _backgroundImage.image = nil;
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    
    _distance.text = [NSString stringWithFormat:@"%0.1f mi.", distanceInMeters/1000/1.6];
    _rating.text = restaurant.rating;
    
    OOAPI *api = [[OOAPI alloc] init];
    if (restaurant.imageRef) {
        [api getRestaurantImageWithImageRef:restaurant.imageRef success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:link]
                                                              cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                          timeoutInterval:60];
                
                [_backgroundImage setImageWithURLRequest:imageRequest
                                 placeholderImage:[UIImage imageNamed:@"Logo2.png"]
                                          success:nil
                                          failure:nil];
            });
        } failure:^(NSError *error) {
            ;
        }];
    }
}


@end

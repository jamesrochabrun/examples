//
//  TileCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 8/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "TileCVCell.h"
#import "LocationManager.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "UIImageView+AFNetworking.h"
#import "EmptyRestaurantTile.h"
#import "ImageRefObject.h"
#import "MediaItemObject.h"

@interface TileCVCell ()

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *distance;
@property (nonatomic, strong) UILabel *rating;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) UIView *emptyTile;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

@implementation TileCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorRGBA(kColorWhite);
        _name = [[UILabel alloc] init];
        _distance = [[UILabel alloc] init];
        _rating = [[UILabel alloc] init];
        _backgroundImage = [[UIImageView alloc] init];
        _overlay = [[UIView alloc] init];
        _emptyTile = [[EmptyRestaurantTile alloc] init];
        _requestOperation = nil;
        
        _overlay.translatesAutoresizingMaskIntoConstraints =
        _backgroundImage.translatesAutoresizingMaskIntoConstraints =
        _name.translatesAutoresizingMaskIntoConstraints =
        _rating.translatesAutoresizingMaskIntoConstraints =
        _emptyTile.translatesAutoresizingMaskIntoConstraints =
        _distance.translatesAutoresizingMaskIntoConstraints = NO;

        _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImage.clipsToBounds = YES;
        _backgroundImage.image = [UIImage imageNamed:@"Logo2.png"];

        [_name withFont:[UIFont fontWithName:kFontLatoHeavyItalic size:kGeomFontSizeBannerMain] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentLeft];
        [_distance withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail] textColor:kColorWhite backgroundColor:kColorClear];
        [_rating withFont:[UIFont fontWithName:kFontIcons size:kGeomFontSizeDetail] textColor:kColorYellow backgroundColor:kColorClear];

//        _overlay.backgroundColor = UIColorRGBA(kColorStripOverlay);

        _gradient = [CAGradientLayer layer];
        _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];

        [self addSubview:_emptyTile];
        [self addSubview:_backgroundImage];
        [self addSubview:_overlay];
        [self addSubview:_distance];
        [self addSubview:_rating];
        [self addSubview:_name];
        
        _gradient = [CAGradientLayer layer];
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           [NSNull null], @"bounds",
                                           [NSNull null], @"position",
                                           nil];
        _gradient.actions = newActions;
        
        [_overlay.layer addSublayer:_gradient];
        _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    
//        [DebugUtilities addBorderToViews:@[self]];
    }
    return self;
}

- (void)layoutSubviews {
    _gradient.frame = _overlay.bounds;
}

- (void)updateConstraints
{
    [super updateConstraints];
    CGSize labelSize = [@"Abc" sizeWithAttributes:@{NSFontAttributeName:_name.font}];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"labelY":@((kGeomHeightStripListRow-labelSize.height)/2), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _name, _emptyTile, _backgroundImage, _rating, _distance, _overlay);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emptyTile]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_overlay(50)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_name][_distance]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_rating]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyTile]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_overlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_name]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rating]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_distance]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
//    NSLog(@"restaurant name = %@", restaurant.name);
    _name.text = _restaurant.name;
    _backgroundImage.image = nil;
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    _distance.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];
    _rating.text = (restaurant.rating && ([restaurant.rating floatValue] > 3.5)) ? kFontIconWhatsNewFilled : @"";
    
    OOAPI *api = [[OOAPI alloc] init];
    
    NSString *imageRef;
    if ([restaurant.mediaItems count]) {
        imageRef = ((MediaItemObject*)[restaurant.mediaItems objectAtIndex:0]).reference;
    } else if ([restaurant.imageRefs count]) {
        imageRef = ((ImageRefObject *)[restaurant.imageRefs objectAtIndex:0]).reference;
    }
    
    if (imageRef) {
        _requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_backgroundImage setImageWithURL:[NSURL URLWithString:link]];
            });
        } failure:^(NSError *error) {
            ;
        }];
    } else {
        
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
//    _requestOperation = nil;

//    [self.backgroundImage cancelImageRequestOperation];
    
    // AFNetworking
    [_requestOperation cancel];
    _requestOperation = nil;
}


@end

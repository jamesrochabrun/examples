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

@property (nonatomic, strong) UILabel *priceRange;
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
        self.backgroundColor = UIColorRGBA(kColorBlack);
        _name = [[UILabel alloc] init];
        _distance = [[UILabel alloc] init];
        _rating = [[UILabel alloc] init];
        _backgroundImage = [[UIImageView alloc] init];
        _overlay = [[UIView alloc] init];
        _emptyTile = [[EmptyRestaurantTile alloc] init];
        _priceRange = [[UILabel alloc] init];
        _requestOperation = nil;
        
        _priceRange.translatesAutoresizingMaskIntoConstraints =
        _overlay.translatesAutoresizingMaskIntoConstraints =
        _backgroundImage.translatesAutoresizingMaskIntoConstraints =
        _name.translatesAutoresizingMaskIntoConstraints =
        _rating.translatesAutoresizingMaskIntoConstraints =
        _emptyTile.translatesAutoresizingMaskIntoConstraints =
        _distance.translatesAutoresizingMaskIntoConstraints = NO;

        _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImage.clipsToBounds = YES;
        _backgroundImage.image = nil;

        [_name withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH4] textColor:kColorText backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentLeft];
        [_distance withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH5] textColor:kColorText backgroundColor:kColorClear];
        [_rating withFont:[UIFont fontWithName:kFontIcons size:kGeomFontSizeH5] textColor:kColorTextActive backgroundColor:kColorClear];
        [_priceRange withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH5] textColor:kColorText backgroundColor:kColorClear];

        [self addSubview:_emptyTile];
        [self addSubview:_backgroundImage];
        [self addSubview:_overlay];
        [self addSubview:_distance];
        [self addSubview:_rating];
        [self addSubview:_name];
        [self addSubview:_priceRange];
        
        _gradient = [CAGradientLayer layer];
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           [NSNull null], @"bounds",
                                           [NSNull null], @"position",
                                           nil];
        _gradient.actions = newActions;
        
//        [_overlay.layer addSublayer:_gradient];
//        _gradient.colors = [NSArray arrayWithObjects:(id)[UIColorRGBA(0x02000000) CGColor], (id)[UIColorRGBA((0xBB000000)) CGColor], nil];
    
//        [DebugUtilities addBorderToViews:@[_overlay]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradient.frame = _overlay.bounds;
    [_gradient setStartPoint:CGPointMake(0, 0)];
    [_gradient setEndPoint:CGPointMake(0, 1)];
}

- (void)updateConstraints
{
    [super updateConstraints];
    CGSize labelSize = [@"Abc" sizeWithAttributes:@{NSFontAttributeName:_name.font}];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"labelY":@((kGeomHeightStripListRow-labelSize.height)/2), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"featuredNameY": @(kGeomHeightFeaturedRow/2 + kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _name, _emptyTile, _backgroundImage, _rating, _distance, _overlay, _priceRange);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emptyTile]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyTile]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_overlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    if (_displayType == kListDisplayTypeFeatured) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_overlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_distance]-spaceCellPadding-[_rating]-spaceCellPadding-[_priceRange]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_name]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_name attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(featuredNameY)-[_name]-spaceCellPadding-[_distance]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_rating attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_overlay(35)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_priceRange][_rating(0)]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceCellPadding-[_distance]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceCellPadding-[_name]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_name][_distance]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_rating attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_distance attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_priceRange attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_distance attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

}

- (void)setDisplayType:(ListDisplayType)displayType {
    _displayType = displayType;
    
    if (_displayType == kListDisplayTypeFeatured) {
        _overlay.backgroundColor = UIColorRGBA(kColorOverlay50);
        [_gradient removeFromSuperlayer];
        [_name setFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH5]];
    } else {
        [_overlay.layer addSublayer:_gradient];
        
        _gradient.colors = [NSArray arrayWithObjects:(id)[UIColorRGBA((kColorButtonBackground & 0x11FFFFFF)) CGColor], (id)[UIColorRGBA(kColorButtonBackground) CGColor], nil];
        
        _overlay.backgroundColor = UIColorRGBA(kColorClear);
        [_name setFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH5]];
    }
//    [self setNeedsDisplay];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
//    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
    NSLog(@"RESTAURANT NAME = %@, #MEDIA= %lu", restaurant.name,  (unsigned long)restaurant.mediaItems.count);
    _name.text = _restaurant.name;
    _backgroundImage.image = nil;
    _priceRange.text = [_restaurant priceRangeText];
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    _distance.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];
    //_rating.text = (restaurant.rating && ([restaurant.rating floatValue] > 3.7)) ? kFontIconWhatsNewFilled : @"";
    
    OOAPI *api = [[OOAPI alloc] init];
    
    if ([restaurant.mediaItems count]) {
        MediaItemObject *mediaItem = ((MediaItemObject*)[restaurant.mediaItems objectAtIndex:0]);
        _requestOperation = [api getRestaurantImageWithMediaItem:mediaItem maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            __weak UIImageView *weakIV = _backgroundImage;
            __weak TileCVCell *weakSelf = self;
            [_backgroundImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
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
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                NSLog  (@"ERROR= %@",error);
                NSLog(@"FAILED TO GET IMAGE FOR RESTAURANT NAME = %@, #MEDIA= %lu", restaurant.name,  (unsigned long)restaurant.mediaItems.count);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    } else if ([restaurant.imageRefs count]) {
        NSString *imageRef = ((ImageRefObject *)[restaurant.imageRefs objectAtIndex:0]).reference;
        if (imageRef) {
            _requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
                __weak UIImageView *weakIV = _backgroundImage;
                __weak TileCVCell *weakSelf = self;
                [_backgroundImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
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
                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                    ;
                }];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ;
            }];
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.backgroundImage.layer removeAllAnimations];
    [self.backgroundImage cancelImageRequestOperation];
    [self.backgroundImage setImage: nil];
    
    // AFNetworking
    [_requestOperation cancel];
    _requestOperation = nil;
}


@end

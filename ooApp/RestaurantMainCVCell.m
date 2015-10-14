//
//  RestaurantMainCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 10/14/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOAPI.h"
#import "RestaurantMainCVCell.h"

@interface RestaurantMainCVCell()

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UILabel *phoneNumber;
@property (nonatomic, strong) UILabel *website;
@property (nonatomic, strong) UILabel *address;

@end


@implementation RestaurantMainCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iv = [[UIImageView alloc] init];
        _iv.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_iv];

        _phoneNumber = [[UILabel alloc] init];
        [_phoneNumber withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorBlack backgroundColor:kColorWhite];
        _phoneNumber.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_phoneNumber];

        _website = [[UILabel alloc] init];
        [_website withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorBlack backgroundColor:kColorWhite];
        _website.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_website];
        
        _address = [[UILabel alloc] init];
        [_address withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorBlack backgroundColor:kColorWhite numberOfLines:3 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
        _address.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_address];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"imageWidth":@(120), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _iv, _address, _website, _phoneNumber);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_iv(imageWidth)]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(spaceEdge)-[_phoneNumber]-(spaceEdge)-[_website]-(spaceEdge)-[_address]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_iv]-[_phoneNumber]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_iv]-[_website]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_iv]-[_address]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:_iv
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:_iv
                                      attribute:NSLayoutAttributeHeight
                                      multiplier:1
                                      constant:0];
    [self addConstraint:constraint];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
    
    _address.text = _restaurant.address;
    _website.text = _restaurant.website;
    _phoneNumber.text = _restaurant.phone;
    [self updateConstraintsIfNeeded];
}

-(void)setMediaItemObject:(MediaItemObject *)mediaItemObject {
    if (mediaItemObject == _mediaItemObject) return;
    _mediaItemObject = mediaItemObject;
    OOAPI *api = [[OOAPI alloc] init];
    
    NSString *imageRef = mediaItemObject.reference;
    
    if (imageRef) {
        _requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_iv setImageWithURL:[NSURL URLWithString:link]];
                [self setNeedsUpdateConstraints];
            });
        } failure:^(NSError *error) {
            ;
        }];
    } else {
        
    }
}


@end

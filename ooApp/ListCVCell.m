//
//  ListCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 8/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListCVCell.h"
#import "DebugUtilities.h"

@interface ListCVCell ()

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *distance;
@property (nonatomic, strong) UILabel *rating;
@property (nonatomic, strong) UIImageView *backgroundImage;

@end

@implementation ListCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorRGBA(0xFF0000FF);
        _name = [[UILabel alloc] init];
        _distance = [[UILabel alloc] init];
        _rating = [[UILabel alloc] init];
        _backgroundImage = [[UIImageView alloc] init];
        
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        _name.translatesAutoresizingMaskIntoConstraints = NO;
        _rating.translatesAutoresizingMaskIntoConstraints = NO;
        _distance.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_name withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail] textColor:kColorWhite backgroundColor:kColorClear];
        [_distance withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail] textColor:kColorWhite backgroundColor:kColorClear];
        [_rating withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail] textColor:kColorWhite backgroundColor:kColorClear];

        [self addSubview:_distance];
        [self addSubview:_rating];
        [self addSubview:_name];
        [self addSubview:_backgroundImage];
        
        [DebugUtilities addBorderToViews:@[self]];
        [self layout];
    }
    return self;
}

- (void)layout {
    CGSize labelSize = [@"Abc" sizeWithAttributes:@{NSFontAttributeName:_name.font}];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightListRow), @"labelY":@((kGeomHeightListRow-labelSize.height)/2), @"buttonY":@(kGeomHeightListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightListRow-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _name, _backgroundImage, _rating, _distance);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_name]-(15)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_distance]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_rating]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_name(<=nameWidth)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rating]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_distance]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    _restaurant = restaurant;
    _name.text = _restaurant.name;
    _distance.text = @"1.0 mi.";
    _rating.text = @"4.5";
}

@end

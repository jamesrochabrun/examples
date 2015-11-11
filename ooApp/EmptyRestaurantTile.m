//
//  EmptyRestaurantTile.m
//  ooApp
//
//  Created by Anuj Gujar on 9/30/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "EmptyRestaurantTile.h"

@interface EmptyRestaurantTile ()

@property (nonatomic, strong) UILabel *icon;

@end

@implementation EmptyRestaurantTile

- (instancetype)init {
    self = [super init];
    if (self) {
        _icon = [[UILabel alloc] init];
        [_icon withFont:[UIFont fontWithName:kFontIcons size:35] textColor:kColorOffWhite backgroundColor:kColorOffBlack numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        _icon.text = kFontIconDiscover;
        [self addSubview:_icon];
        _icon.translatesAutoresizingMaskIntoConstraints = NO;
        [self layout];
    }
    return self;
}

- (void)layout {
 
    UIView *superview = self;
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};

    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _icon);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_icon]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_icon]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_icon
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_icon.superview
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_icon
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_icon.superview
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

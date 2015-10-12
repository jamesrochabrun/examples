//
//  NavTitleView.m
//  ooApp
//
//  Created by Anuj Gujar on 9/15/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "NavTitleView.h"
#import "DebugUtilities.h"

@interface NavTitleView ()

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *subHeaderLabel;

@end

@implementation NavTitleView

- (id)init
{
    if (self = [super init]) {
        _headerLabel = [[UILabel alloc] init];
        _subHeaderLabel = [[UILabel alloc] init];
        
        [_headerLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeHeader] textColor:kColorBlack backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        [_subHeaderLabel withFont:[UIFont fontWithName:kFontLatoThin size:kGeomFontSizeSubheader] textColor:kColorBlack backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        
        _headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _subHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_headerLabel];
        [self addSubview:_subHeaderLabel];
        [self layout];
        
//        [DebugUtilities addBorderToViews:@[_headerLabel, _subHeaderLabel]];
    }
    return self;
}

- (void)layout
{
    // Create the views and metrics dictionaries
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _headerLabel, _subHeaderLabel);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(<=spaceEdge)-[_headerLabel][_subHeaderLabel]-(<=spaceEdge)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    // Horizontal Layout
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headerLabel]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_subHeaderLabel]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_headerLabel
//                                                     attribute:NSLayoutAttributeCenterY
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:_headerLabel.superview
//                                                     attribute:NSLayoutAttributeCenterY
//                                                    multiplier:1.f constant:0.f]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_headerLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_headerLabel.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_subHeaderLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_subHeaderLabel.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
}

- (void)setNavTitle:(NavTitleObject *)navTitle
{
    if (_navTitle == navTitle) return;
    _navTitle = navTitle;
    
    _headerLabel.text = _navTitle.header;
    _subHeaderLabel.text = _navTitle.subheader;
    
    [_headerLabel sizeToFit];
    [_subHeaderLabel sizeToFit];
}

@end

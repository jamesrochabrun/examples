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
@property (nonatomic, strong) UILabel *arrow;

@end

@implementation NavTitleView

- (id)init
{
    if (self = [super init]) {
        _headerLabel = [[UILabel alloc] init];
        _subHeaderLabel = [[UILabel alloc] init];
        _arrow = [[UILabel alloc] init];
        
        [_headerLabel withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        [_subHeaderLabel withFont:[UIFont fontWithName:kFontLatoThin size:kGeomFontSizeSubheader] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        [_arrow withFont:[UIFont fontWithName:kFontIcons size:20] textColor:kColorYellow backgroundColor:kColorClear];
        _arrow.text = kFontIconBack;
        _arrow.hidden = YES;
        
        _arrow.translatesAutoresizingMaskIntoConstraints = NO;
        _headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _subHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_headerLabel];
        [self addSubview:_subHeaderLabel];
        [self addSubview:_arrow];
        
//        [DebugUtilities addBorderToViews:@[_headerLabel, _subHeaderLabel, _arrow]];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
// Create the views and metrics dictionaries
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _headerLabel, _subHeaderLabel, _arrow);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(<=spaceEdge)-[_headerLabel][_subHeaderLabel]-(<=spaceEdge)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    // Horizontal Layout
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_headerLabel]-spaceInter-[_arrow]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_subHeaderLabel]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_headerLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_subHeaderLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_arrow
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_headerLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];
}

- (void)setDDLState:(BOOL)open {
    _arrow.hidden = NO;
    _arrow.transform = (open) ? CGAffineTransformMakeRotation(3*M_PI_2) : CGAffineTransformMakeRotation(M_PI_2);
}

- (void)setNavTitle:(NavTitleObject *)navTitle
{
    _navTitle = navTitle;
    
    _headerLabel.text = [_navTitle.header uppercaseString];
    _subHeaderLabel.text = _navTitle.subheader;
    [_headerLabel sizeToFit];
    [_subHeaderLabel sizeToFit];
    [self setNeedsUpdateConstraints];
}

@end

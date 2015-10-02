//
//  OORemoveButton.m
//  ooApp
//
//  Created by Anuj Gujar on 9/30/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OORemoveButton.h"
#import "DebugUtilities.h"

@interface OORemoveButton ()
@property (nonatomic, strong) UILabel *x;
@end

@implementation OORemoveButton

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _x = [[UILabel alloc] init];
        [_x withFont:[UIFont fontWithName:kFontIcons size:10] textColor:kColorBlack backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        _x.text = kFontIconRemove;

        _name = [[UILabel alloc] init];
        [_name withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorBlack backgroundColor:kColorClear];
        
        [self addSubview:_name];
        [self addSubview:_x];
        
        _name.translatesAutoresizingMaskIntoConstraints = NO;
        _x.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.backgroundColor = UIColorRGBA(kColorOffWhite);
        self.layer.cornerRadius = kGeomCornerRadius;
        [self layout];
        
//        [DebugUtilities addBorderToViews:@[_name, _x]];
    }
    return self;
}

- (void)layout {
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _name, _x);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_x]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_name]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-spaceEdge-[_x]-[_name]-spaceEdge-|" options:0 metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_x
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_x.superview
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_name
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_name.superview
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.f constant:0.f]];
}

- (CGSize)getSuggestedSize {
    CGRect frame;
    CGSize s = CGSizeZero;
    [_name sizeToFit];
    [_x sizeToFit];
    s.width = 2*kGeomSpaceEdge + kGeomSpaceInter + CGRectGetWidth(_name.frame) + CGRectGetWidth(_x.frame);
    s.height = 2*kGeomSpaceEdge + CGRectGetHeight(_name.frame);
    return s;
}

- (BOOL)isEqual:(id)object {
    OORemoveButton *rb = (OORemoveButton *)object;
    return (rb.identifier == self.identifier) ? YES : NO;
}

- (NSUInteger)hash {
    return _identifier;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

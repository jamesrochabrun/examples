//
//  OOTagButton.m
//  ooApp
//
//  Created by Anuj Gujar on 9/30/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOTagButton.h"
#import "DebugUtilities.h"

@interface OOTagButton ()
@property (nonatomic, strong) UILabel *xLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation OOTagButton

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _xLabel = [[UILabel alloc] init];
        [_xLabel withFont:[UIFont fontWithName:kFontIcons size:10] textColor:kColorBlack backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];

        _nameLabel = [[UILabel alloc] init];
        [_nameLabel withFont:[UIFont fontWithName:kFontLatoMediumItalic size:kGeomFontSizeRemoveButton] textColor:kColorBlack backgroundColor:kColorClear];
        
        [self addSubview:_nameLabel];
        [self addSubview:_xLabel];
        
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _xLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.backgroundColor = UIColorRGBA(kColorOffWhite);
        self.layer.cornerRadius = kGeomCornerRadius;
//      [self layout];
        
//        [DebugUtilities addBorderToViews:@[_nameLabel, _xLabel]];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _nameLabel, _xLabel);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_xLabel]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_nameLabel]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    if (_icon.length) {
        [self addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-spaceEdge-[_xLabel]-spaceInter-[_nameLabel]-spaceEdge-|" options:0 metrics:metrics views:views]];
    } else {
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-spaceEdge-[_nameLabel]-spaceEdge-|" options:0 metrics:metrics views:views]];
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_xLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_xLabel.superview
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_nameLabel.superview
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.f constant:0.f]];
}

- (void)setName:(NSString *)name {
    _name = name;
    _nameLabel.text = _name;
    [_nameLabel sizeToFit];
}

- (void)setIcon:(NSString *)icon {
    _icon = icon;
    _xLabel.text = icon;
    [_xLabel sizeToFit];
}

- (CGSize)getSuggestedSize {
    CGSize s = CGSizeZero;
    [_nameLabel sizeToFit];
    [_xLabel sizeToFit];
    s.width = 2*kGeomSpaceEdge + width(_nameLabel) + width(_xLabel) + (width(_xLabel) ? kGeomSpaceInter : 0);
    s.height = 2*kGeomSpaceEdge + height(_nameLabel);
    [self updateConstraintsIfNeeded];
    return s;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (!object || ![object isKindOfClass:[self class]]) return NO;

    OOTagButton *rb = (OOTagButton *)object;
    return (rb.theId == _theId) ? YES : NO;
}

- (NSUInteger)hash {
    return _theId;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

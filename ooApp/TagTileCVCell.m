//
//  TagTileCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 12/3/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "TagTileCVCell.h"

@interface TagTileCVCell ()
@property (nonatomic, strong) UILabel *termLabel;
@end

@implementation TagTileCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _termLabel = [[UILabel alloc] init];
        [_termLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH4] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:2 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        _termLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_termLabel];
    }
    return self;
}

- (void)setTagObject:(TagObject *)tagObject {
    if (_tagObject == tagObject) return;
    _tagObject = tagObject;
    _termLabel.text = _tagObject.term;
    [_termLabel setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _termLabel);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=spaceEdge)-[_termLabel]-(>=spaceEdge)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=spaceEdge)-[_termLabel]-(>=spaceEdge)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_termLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_termLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.backgroundColor = (selected) ? UIColorRGBA(kColorBlack) : UIColorRGBA(kColorOffBlack);
    _termLabel.textColor = (selected) ? UIColorRGBA(kColorYellow) : UIColorRGBA(kColorWhite);
}

@end

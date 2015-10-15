//
//  ObjectTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ObjectTVCell.h"
#import "DebugUtilities.h"

@interface ObjectTVCell ()

@end

@implementation ObjectTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        self.backgroundColor = UIColorRGB(kColorWhite);
        _thumbnail = [[UIImageView alloc] init];
        
        _header = [[UILabel alloc] init];
        [_header withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeHeader] textColor:kColorBlack backgroundColor:kColorClear numberOfLines:2 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
        
        _subHeader1 = [[UILabel alloc] init];
        [_subHeader1 withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorBlack backgroundColor:kColorClear];
        
        _subHeader2 = [[UILabel alloc] init];
        [_subHeader2 withFont:[UIFont fontWithName:kFontLatoThin size:kGeomFontSizeSubheader] textColor:kColorBlack backgroundColor:kColorClear];
        
        [self addSubview:_thumbnail];
        [self addSubview:_header];
        [self addSubview:_subHeader1];
        [self addSubview:_subHeader2];
        
        //set the selected color for the cell
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = UIColorRGBA(kColorCellSelected);
        [self setSelectedBackgroundView:bgColorView];
        
        _thumbnail.translatesAutoresizingMaskIntoConstraints = _header.translatesAutoresizingMaskIntoConstraints = _subHeader1.translatesAutoresizingMaskIntoConstraints = _subHeader2.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;

        //[DebugUtilities addBorderToViews:@[_thumbnail, _header, _subHeader1, _subHeader2]];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self layout];
}

- (void)layout {
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _thumbnail, _header, _subHeader1, _subHeader2);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_thumbnail]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(spaceEdge)-[_header]-(spaceEdge)-[_subHeader1]-(spaceEdge)-[_subHeader2]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_thumbnail]-[_header]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_thumbnail]-[_subHeader1]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_thumbnail]-[_subHeader2]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:_thumbnail
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:_thumbnail
                                      attribute:NSLayoutAttributeHeight
                                      multiplier:1
                                      constant:0];
    [self addConstraint:constraint];
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
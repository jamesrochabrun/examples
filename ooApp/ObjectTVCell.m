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

@property (nonatomic, strong) UIView *verticalLine1;

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
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        _thumbnail = [[UIImageView alloc] init];
        _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnail.backgroundColor = UIColorRGBA(kColorOffWhite);
        _thumbnail.clipsToBounds = YES;
        [self addSubview:_thumbnail];

        _gradient = [CAGradientLayer layer];
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           [NSNull null], @"bounds",
                                           [NSNull null], @"position",
                                           nil];
        _gradient.actions = newActions;
        
        [_thumbnail.layer addSublayer:_gradient];
        _gradient.colors = [NSArray arrayWithObjects:(id)[UIColorRGBA(kColorButtonBackground) CGColor], (id)[UIColorRGBA(kColorButtonBackground & 0xF5FFFFFF) CGColor], (id)[UIColorRGBA((kColorButtonBackground & 0x00FFFFFF)) CGColor], nil];
        _gradient.locations = @[@(0),@(0.3),@(1)];
        
        _icon = [[UILabel alloc] init];
        [_icon withFont:[UIFont fontWithName:kFontIcons size:kGeomIconSize] textColor:kColorTextActive backgroundColor:kColorClear];
        _icon.text = kFontIconPinDot;
        _icon.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_icon];
        
        _header = [[UILabel alloc] init];
        [_header withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader] textColor:kColorText backgroundColor:kColorClear numberOfLines:2 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
        
        _subHeader1 = [[UILabel alloc] init];
        [_subHeader1 withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader] textColor:kColorText backgroundColor:kColorClear];
        
        _iconLabel = [[UILabel alloc] init];
        [_iconLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH6] textColor:kColorTextActive backgroundColor:kColorClear];
        _iconLabel.text = @"";
        
        _subHeader2 = [[UILabel alloc] init];
        [_subHeader2 withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader] textColor:kColorText backgroundColor:kColorClear];
        
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_actionButton roundButtonWithIcon:kFontIconAdd fontSize:kGeomIconSizeSmall width:kGeomDimensionsIconButtonSmall height:0 backgroundColor:kColorBackgroundTheme target:nil selector:nil];
        //[_actionButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        [self addSubview:_actionButton];
        _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        _actionButton.hidden = YES;
        
        _viewShadow = [[UIView alloc] init];
        [self addSubview:_viewShadow];
        _viewShadow.backgroundColor = UIColorRGBA(kColorWhite);
        _viewShadow.translatesAutoresizingMaskIntoConstraints = NO;
//        [self addShadowToView:_viewShadow];
        [self sendSubviewToBack:_viewShadow];
        
        [self addSubview:_header];
        [self addSubview:_subHeader1];
        [self addSubview:_subHeader2];
        [_icon addSubview:_iconLabel];
        
        //set the selected color for the cell
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = UIColorRGBA(kColorCellSelected);
        [self setSelectedBackgroundView:bgColorView];
        
        _thumbnail.translatesAutoresizingMaskIntoConstraints =
        _header.translatesAutoresizingMaskIntoConstraints =
        _subHeader1.translatesAutoresizingMaskIntoConstraints =
        _subHeader2.translatesAutoresizingMaskIntoConstraints =
        _icon.translatesAutoresizingMaskIntoConstraints =
        _iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;

//        [DebugUtilities addBorderToViews:@[_viewShadow/*_thumbnail, _header, _subHeader1, _subHeader2, _viewShadow*/]];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];

    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomDimensionsIconButtonSmall)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _thumbnail, _header, _subHeader1, _subHeader2, _viewShadow, _actionButton, _icon, _iconLabel);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    _shadowConstraints = [NSMutableArray array];
    [_shadowConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceCellPadding-[_viewShadow]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [_shadowConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_viewShadow]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:_shadowConstraints];
    
    _tnConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceCellPadding-[_thumbnail]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
    [self addConstraints:_tnConstraints];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_header]-(spaceEdge)-[_subHeader1]-(spaceEdge)-[_subHeader2]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_actionButton(buttonWidth)]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_icon(45)]-spaceInter-[_header]-[_actionButton(buttonWidth)]-spaceEdgeX2-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_thumbnail]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_iconLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:_icon
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_iconLabel
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_icon
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:-6]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_subHeader1
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_icon
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_viewShadow
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:_thumbnail
                         attribute:NSLayoutAttributeHeight
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_subHeader1
                         attribute:NSLayoutAttributeLeft
                         relatedBy:NSLayoutRelationEqual
                         toItem:_header
                         attribute:NSLayoutAttributeLeft
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_subHeader2
                         attribute:NSLayoutAttributeLeft
                         relatedBy:NSLayoutRelationEqual
                         toItem:_header
                         attribute:NSLayoutAttributeLeft
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_actionButton
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.viewShadow
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_icon
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradient.frame = _thumbnail.bounds;
//    _gradient.frame = CGRectMake(kGeomSpaceEdge, kGeomSpaceCellPadding, width(self)*5/5, height(_viewShadow));
    [_gradient setStartPoint:CGPointMake(0, 0)];
    [_gradient setEndPoint:CGPointMake(1, 0)];
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

- (void)hideShadow
{
    _viewShadow.opaque = YES;
    _viewShadow.layer.shadowOffset = CGSizeMake(0, 0);
    _viewShadow.layer.shadowColor = UIColorRGBA(kColorClear).CGColor;
    _viewShadow.layer.shadowOpacity = 0;
    _viewShadow.layer.shadowRadius = 0;
}

- (void)showShadow
{
    _viewShadow.opaque = YES;
    _viewShadow.layer.shadowOffset = CGSizeMake(0, 5);
    _viewShadow.layer.shadowColor = UIColorRGBA(kColorBlack).CGColor;
    _viewShadow.layer.shadowOpacity = 0.25;
    _viewShadow.layer.shadowRadius = 4;
}

- (void)addShadowToView:(UIView *)view
{
    view.opaque = YES;
    view.layer.shadowOffset = CGSizeMake(0, 5);
    view.layer.shadowColor = UIColorRGBA(kColorBlack).CGColor;
    view.layer.shadowOpacity = 0.25;
    view.layer.shadowRadius = 4;
    view.clipsToBounds = NO;
    view.layer.shouldRasterize = YES;
}

@end

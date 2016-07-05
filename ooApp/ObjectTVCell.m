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
@property (nonatomic, strong) UITapGestureRecognizer *iconTappedGesture;
@property (nonatomic, strong) UITapGestureRecognizer *thumbnailTappedGesture;

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
        self.backgroundColor = UIColorRGBA(kColorButtonBackground);
        _thumbnail = [[UIImageView alloc] init];
        _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnail.backgroundColor = UIColorRGBA(kColorOffWhite);
        _thumbnail.clipsToBounds = YES;
        _thumbnail.layer.cornerRadius = kGeomCornerRadius;
        _thumbnail.layer.borderWidth = 0.5;
        _thumbnail.layer.borderColor = UIColorRGBA(kColorBlack).CGColor;
        [self addSubview:_thumbnail];
        
        _thumbnailTappedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailTapped:)];
        _thumbnail.userInteractionEnabled = YES;
        [_thumbnail addGestureRecognizer:_thumbnailTappedGesture];


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
        [_icon withFont:[UIFont fontWithName:kFontIcons size:kGeomIconSizeSmallest] textColor:kColorTextActive backgroundColor:kColorClear];
        _icon.text = kFontIconPinDot;
        _icon.textAlignment = NSTextAlignmentCenter;
        
        _iconTappedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTapped:)];
        _icon.userInteractionEnabled = YES;
        [_icon addGestureRecognizer:_iconTappedGesture];
        
        _header = [[UILabel alloc] init];
        [_header withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader] textColor:kColorText backgroundColor:kColorClear numberOfLines:2 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
        
        _subHeader1 = [[UILabel alloc] init];
        [_subHeader1 withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader] textColor:kColorText backgroundColor:kColorClear];
        
        _iconLabel = [[UILabel alloc] init];
        [_iconLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH7] textColor:kColorTextActive backgroundColor:kColorClear];
        _iconLabel.text = @"";
        
        _subHeader2 = [[UILabel alloc] init];
        [_subHeader2 withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader] textColor:kColorText backgroundColor:kColorClear];
        
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_actionButton roundButtonWithIcon:kFontIconAdd fontSize:kGeomIconSizeSmall width:kGeomDimensionsIconButtonSmall height:0 backgroundColor:kColorBackgroundTheme target:nil selector:nil];
        //[_actionButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        [self addSubview:_actionButton];
//        _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        _actionButton.hidden = YES;
        
        [self addSubview:_header];
        [self addSubview:_subHeader1];
        [self addSubview:_subHeader2];
        [_icon addSubview:_iconLabel];
        [self addSubview:_icon];
        
        //set the selected color for the cell
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = UIColorRGBA(kColorCellSelected);
        [self setSelectedBackgroundView:bgColorView];
        
//        _thumbnail.translatesAutoresizingMaskIntoConstraints =
//        _header.translatesAutoresizingMaskIntoConstraints =
//        _subHeader1.translatesAutoresizingMaskIntoConstraints =
//        _subHeader2.translatesAutoresizingMaskIntoConstraints =
//        _icon.translatesAutoresizingMaskIntoConstraints =
//        _iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;

//        [DebugUtilities addBorderToViews:@[_icon]];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];

//    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomDimensionsIconButtonSmall)};
//    
//    UIView *superview = self;
//    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _thumbnail, _header, _subHeader1, _subHeader2, _actionButton, _icon, _iconLabel);
//    
    // Vertical layout - note the options for aligning the top and bottom of all views
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_actionButton(buttonWidth)]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_icon(45)]-spaceInter-[_header]-[_actionButton(buttonWidth)]-spaceEdgeX2-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_iconLabel
//                         attribute:NSLayoutAttributeCenterX
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:_icon
//                         attribute:NSLayoutAttributeCenterX
//                         multiplier:1
//                         constant:0]];
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_iconLabel
//                         attribute:NSLayoutAttributeCenterY
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:_icon
//                         attribute:NSLayoutAttributeCenterY
//                         multiplier:1
//                         constant:-6]];
    
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_subHeader1
//                         attribute:NSLayoutAttributeCenterY
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:_icon
//                         attribute:NSLayoutAttributeCenterY
//                         multiplier:1
//                         constant:0]];
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_icon
//                         attribute:NSLayoutAttributeCenterY
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:self
//                         attribute:NSLayoutAttributeCenterY
//                         multiplier:1
//                         constant:0]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    CGFloat w = width(self);
    CGFloat h = height(self);
    
    frame = _actionButton.frame;
    frame.size = CGSizeMake(kGeomDimensionsIconButtonSmall, kGeomDimensionsIconButtonSmall);
    frame.origin.x = w - kGeomDimensionsIconButtonSmall - kGeomSpaceEdge;
    frame.origin.y = (h - kGeomDimensionsIconButtonSmall)/2;
    _actionButton.frame = frame;

    frame = _thumbnail.frame;
    frame.origin.x = kGeomSpaceEdge;
    frame.origin.y = 2*kGeomSpaceEdge;
    frame.size.width = h - 4*kGeomSpaceEdge;
    frame.size.height = frame.size.width;
    _thumbnail.frame = frame;

    CGFloat leftMargin = CGRectGetMaxX(_thumbnail.frame) + kGeomSpaceEdge;
    
    frame = _subHeader1.frame;
    frame.origin.x = leftMargin;
    frame.origin.y = (h - CGRectGetHeight(_subHeader1.frame))/2;
    _subHeader1.frame = frame;
    
    CGFloat iconHeight = 25;
    frame = _icon.frame;
    frame.origin.x = CGRectGetMaxX(_thumbnail.frame);
    frame.origin.y = CGRectGetMinY(_subHeader1.frame) - iconHeight - kGeomSpaceInter;
    frame.size.height = iconHeight;
    frame.size.width = CGRectGetHeight(_header.frame) + 5;
    _icon.frame = frame;

    frame = _header.frame;
    frame.origin.x = CGRectGetMaxX(_icon.frame);
    frame.size = [self.header sizeThatFits:CGSizeMake(CGRectGetMinX(_actionButton.frame)-CGRectGetMaxX(_icon.frame), 100)];
    frame.origin.y = CGRectGetMinY(_subHeader1.frame) - CGRectGetHeight(frame) - kGeomSpaceInter;
    _header.frame = frame;
    
    NSLog(@"header: %@, rect: %@, width: %f ", _header.text, NSStringFromCGRect(_header.frame), w);
    
    frame = _iconLabel.frame;
    frame.origin.x = (CGRectGetWidth(_icon.frame) - CGRectGetWidth(_iconLabel.frame))/2;
    frame.origin.y = (CGRectGetHeight(_icon.frame) - CGRectGetHeight(_iconLabel.frame))/2 - 5;
    _iconLabel.frame = frame;

    frame = _subHeader2.frame;
    frame.origin.x = leftMargin;
    frame.origin.y = CGRectGetMaxY(_subHeader1.frame) + kGeomSpaceInter;
    _subHeader2.frame = frame;
    
//    _gradient.frame = _thumbnail.bounds; //CGRectZero;
//    [_gradient setStartPoint:CGPointMake(0, 0)];
//    [_gradient setEndPoint:CGPointMake(1, 0)];
}

- (void)iconTapped:(id)sender {
    NSLog(@"icon tapped");
    if ([_delegate respondsToSelector:@selector(objectTVCellIconTapped:)]) {
        [_delegate objectTVCellIconTapped:self];
    }
}

- (void)thumbnailTapped:(id)sender {
    NSLog(@"thumbnail tapped");
    if ([_delegate respondsToSelector:@selector(objectTVCellThumbnailTapped:)]) {
        [_delegate objectTVCellThumbnailTapped:self];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    //    _requestOperation = nil;
    
    //    [self.backgroundImage cancelImageRequestOperation];
    
    // AFNetworking
//    [_requestOperation cancel];
//    _requestOperation = nil;
}

@end

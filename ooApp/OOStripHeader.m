//
//  OOStripHeader.m
//  ooApp
//
//  Created by Anuj Gujar on 10/15/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOStripHeader.h"
#import "DebugUtilities.h"

@interface OOStripHeader()

@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic,strong) UIButton* buttonAdd;

@end

@implementation OOStripHeader

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        _iconLabel = [[UILabel alloc] init];
        _iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_iconLabel withFont:[UIFont fontWithName:kFontIcons size:kGeomFontSizeStripHeader] textColor:kColorYellow backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        _iconLabel.text = @"";
        [self addSubview:_iconLabel];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_nameLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeStripHeader] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        [self addSubview:_nameLabel];
    }
    return self;
}

- (void) unHighlightButton;
{
    // Need because any button that is a subview of UITableViewCell will get highlighted when the cell is highlighted.
    _buttonAdd.highlighted= NO;
    _buttonAdd.selected= NO;
    _buttonAdd.backgroundColor= BLACK;
}

- (void)enableAddButtonWithTarget:(id)target action:(SEL)action
{
    if  (_buttonAdd) {
        return;
    }

    self.buttonAdd = makeRoundIconButtonForAutolayout(self, kFontIconAdd, kGeomFontSizeHeader,
                                        YELLOW, BLACK, target, action,
                                        0, kGeomFontSizeHeader/2.);

    _buttonAdd.layer.borderColor= WHITE.CGColor;
    _buttonAdd.layer.borderWidth= .5;
    [self setNeedsLayout];
}

- (void)setName:(NSString *)name {
    NSString *newName = [name uppercaseString];
    if ([_name isEqualToString:newName]) return;
    _name = newName;
    _nameLabel.text = _name;
    
    [self bringSubviewToFront:_nameLabel];
    [self setNeedsLayout];
}

- (void)setFont:(UIFont *)font {
    [_nameLabel setFont:font];
    [self setNeedsLayout];
}

- (void)setIcon:(NSString *)icon {
    if ([_icon isEqualToString:icon]) return;
    _icon = icon;
    _iconLabel.text = icon;
    
    [self bringSubviewToFront:_iconLabel];
    [self setNeedsLayout];
}

- (void)updateConstraints {
    [super updateConstraints];
    UIView *superview = self;
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@(self.frame.size.width), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    NSDictionary *views= NSDictionaryOfVariableBindings(superview, _nameLabel, _iconLabel);
    
    if (!_buttonAdd && [_icon length]) {
        [self removeConstraints:self.constraints];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_nameLabel]-(>=0)-|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInter-[_iconLabel]-spaceEdge-[_nameLabel]"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_iconLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_nameLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.f constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.f constant:0.f]];
    } else if (!_buttonAdd && ![_icon length]) {
        [self removeConstraints:self.constraints];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_nameLabel]-(>=0)-|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInter-[_nameLabel]"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.f constant:0.f]];
    } else {
        // widths
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_buttonAdd
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:  self
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.f constant: 0]
         ];

        // heights
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_nameLabel
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem: self
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.f constant: 0]
         ];
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_buttonAdd
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem: self
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.f constant: 0]
         ];
        float h= self.frame.size.height;
        _buttonAdd.layer.cornerRadius= h/2;
        
        // left-right sequence
//        [self addConstraint: [NSLayoutConstraint constraintWithItem:_nameLabel
//                                                          attribute:NSLayoutAttributeCenterX
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem: self
//                                                          attribute:NSLayoutAttributeCenterX
//                                                         multiplier:1.f constant:0]
//         ];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_iconLabel]-spaceEdge-[_nameLabel]"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

        [self addConstraint: [NSLayoutConstraint constraintWithItem:_buttonAdd
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:  self
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.f constant:0]
         ];
        
        // Vertical
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem: self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.f constant:0.f]
         ];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_buttonAdd
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem: self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.f constant:0.f]
         ];
        
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.frame;
    frame.size.width = (_buttonAdd) ? width(self) : CGRectGetMaxX(_nameLabel.frame) + kGeomSpaceInter;
    self.frame = frame;
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(7, 7)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    [self updateConstraintsIfNeeded];
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    CGSize s = [_nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                        _nameLabel.font, NSFontAttributeName,
//                                                         nil]];
//    if ( _buttonAdd) {
//        s.width +=kGeomHeightButton;
//    }
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//
//    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 3, UIColorRGBA(kColorStripHeaderShadow).CGColor);
//    
//    CGContextBeginPath(ctx);
//    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMidY(rect) - 2);  // upper mid left
//    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) - s.width/2 - 12, CGRectGetMidY(rect) - 2);  // upper inner left
//    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) - s.width/2, CGRectGetMinY(rect));  // top left
//    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) + s.width/2, CGRectGetMinY(rect));  // top right
//    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) + s.width/2 + 12, CGRectGetMidY(rect) - 2);  // upper inner right
//    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect) - 2);  // upper mid right
//    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect) + 2);  // lower mid right
//    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) + s.width/2 + 12, CGRectGetMidY(rect) + 2);  // lower inner right
//    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) + s.width/2, CGRectGetMaxY(rect));  // bottom right
//    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) - s.width/2, CGRectGetMaxY(rect));  // bottom left
//    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) - s.width/2 - 12, CGRectGetMidY(rect) + 2);  // lower inner left
//    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect) + 2);  // lower mid left
//    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect) - 2);  // back to upper mid left
//    CGContextClosePath(ctx);
//    
//    CGContextSetRGBFillColor(ctx, 0x00/255.f, 0x00/255.f, 0x00/255.f, 1);
//    CGContextFillPath(ctx);
//}

@end



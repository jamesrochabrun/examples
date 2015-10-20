//
//  OOStripHeader.m
//  ooApp
//
//  Created by Anuj Gujar on 10/15/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOStripHeader.h"

@interface OOStripHeader()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic,strong) UIButton* buttonAdd;
@property (nonatomic, strong) UIView *spacerLeft;
@property (nonatomic, strong) UIView *spacerRight;

@end

@implementation OOStripHeader

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_nameLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeStripHeader] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        [self addSubview:_nameLabel];
        self.backgroundColor = UIColorRGBA(kColorClear);
        
        _spacerLeft= makeView(self, CLEAR);
        _spacerRight=  makeView(self, CLEAR);
        _spacerLeft.translatesAutoresizingMaskIntoConstraints = NO ;
        _spacerRight.translatesAutoresizingMaskIntoConstraints = NO ;
    }
    return self;
}

- (void)enableAddButtonWithTarget:(id) target action: (SEL) action
{
    if  ( _buttonAdd) {
        return;
    }
    self.buttonAdd= makeRoundIconButtonForAutolayout(self, kFontIconAdd, kGeomFontSizeHeader,
                                        YELLOW, CLEAR, target, action,
                                        0, kGeomFontSizeHeader/2.);
    
    [self setNeedsLayout];
}

- (void)setName:(NSString *)name {
    NSString *newName = [name uppercaseString];
    if ([_name isEqualToString:newName]) return;
    _name = newName;
    _nameLabel.text = _name;
    
    [self bringSubviewToFront:_nameLabel];
    [self setNeedsDisplay];
}

- (void)updateConstraints {
    [super updateConstraints];
    UIView *superview = self;
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@(self.frame.size.width), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    NSDictionary *views;
    
    if (!_buttonAdd) {
        views= NSDictionaryOfVariableBindings(superview, _nameLabel);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=5)-[_nameLabel]-(>=5)-|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem: self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.f constant:0.f]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem: self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.f constant:0.f]];
    } else {
        // widths
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_spacerLeft
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem: nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.f constant:5]
         ];
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_spacerRight
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem: _spacerLeft
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.f constant:0]
         ];
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_buttonAdd
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem: nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.f constant: 44]
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
        
        // left-right sequence
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_spacerLeft
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem: self
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.f constant:5.f]
         ];
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_spacerLeft
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem: _nameLabel
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.f constant:5.f]
         ];
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_nameLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem: _buttonAdd
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.f constant:6.f]
         ];
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_buttonAdd
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem: _spacerRight
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.f constant:5.f]
         ];
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_spacerRight
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem: superview
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.f constant:5.f]
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
    [self updateConstraints];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGSize s = [_nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        _nameLabel.font, NSFontAttributeName,
                                                         nil]];
    if ( _buttonAdd) {
        s.width +=kGeomHeightButton;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 3, UIColorRGBA(kColorStripHeaderShadow).CGColor);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMidY(rect) - 2);  // upper mid left
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) - s.width/2 - 12, CGRectGetMidY(rect) - 2);  // upper inner left
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) - s.width/2, CGRectGetMinY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) + s.width/2, CGRectGetMinY(rect));  // top right
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) + s.width/2 + 12, CGRectGetMidY(rect) - 2);  // upper inner right
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect) - 2);  // upper mid right
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect) + 2);  // lower mid right
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) + s.width/2 + 12, CGRectGetMidY(rect) + 2);  // lower inner right
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) + s.width/2, CGRectGetMaxY(rect));  // bottom right
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) - s.width/2, CGRectGetMaxY(rect));  // bottom left
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect) - s.width/2 - 12, CGRectGetMidY(rect) + 2);  // lower inner left
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect) + 2);  // lower mid left
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect) - 2);  // back to upper mid left
    CGContextClosePath(ctx);
    
    CGContextSetRGBFillColor(ctx, 0x00/255.f, 0x00/255.f, 0x00/255.f, 1);
    CGContextFillPath(ctx);
}

@end

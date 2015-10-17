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
    }
    return self;
}

- (void)enableAddButtonWithTarget:(id) target action: (SEL) action
{
    if  ( _buttonAdd) {
        return;
    }
    self.buttonAdd= makeRoundIconButton(self, kFontIconAdd, kGeomFontSizeHeader,
                                        YELLOW, BLACK, target, action,
                                        0, kGeomHeightButton/2.);
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

- (void)addConstraintsForButton
{
    UIView *superview = self;
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};

    NSDictionary *views;
    views= NSDictionaryOfVariableBindings(superview, _buttonAdd);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_buttonAdd]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=5)-[_buttonAdd]-(2)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
}

- (void)updateConstraints {
    [super updateConstraints];
    UIView *superview = self;
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    NSDictionary *views;
    
    views= NSDictionaryOfVariableBindings(superview, _nameLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=5)-[_nameLabel]-(>=5)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=5)-[_nameLabel]-(>=5)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_nameLabel.superview
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_nameLabel.superview
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];
    if ( _buttonAdd) {
//        [self addConstraintsForButton];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float w=self.frame.size.width;
    float h=self.frame.size.height;
    [self updateConstraints];
    _buttonAdd.frame = CGRectMake(w-kGeomHeightButton, (h-kGeomHeightButton)/2,kGeomHeightButton,kGeomHeightButton);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGSize s = [_nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        _nameLabel.font, NSFontAttributeName,
                                                         nil]];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 1.25, UIColorRGBA(kColorStripHeaderShadow).CGColor);
    
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

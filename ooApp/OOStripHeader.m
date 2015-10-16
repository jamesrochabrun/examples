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

- (void)setName:(NSString *)name {
    NSString *newName = [name uppercaseString];
    if ([_name isEqualToString:newName]) return;
    _name = newName;
    _nameLabel.text = _name;
    
    [self bringSubviewToFront:_nameLabel];
}

- (void)updateConstraints {
    [super updateConstraints];
    UIView *superview = self;
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _nameLabel);

    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_nameLabel]-5-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_nameLabel]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_icon
//                                                     attribute:NSLayoutAttributeCenterX
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:_icon.superview
//                                                     attribute:NSLayoutAttributeCenterX
//                                                    multiplier:1.f constant:0.f]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_icon
//                                                     attribute:NSLayoutAttributeCenterY
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:_icon.superview
//                                                     attribute:NSLayoutAttributeCenterY
//                                                    multiplier:1.f constant:0.f]];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), (CGRectGetMinY(rect) + CGRectGetMaxY(rect))/2);  // mid left
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect) + 15, CGRectGetMinY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) - 15, CGRectGetMinY(rect));  // top right
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), (CGRectGetMinY(rect) + CGRectGetMaxY(rect))/2);  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) - 15, CGRectGetMaxY(rect));  // bottom right
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect) + 15, CGRectGetMaxY(rect));  // bottom left
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), (CGRectGetMinY(rect) + CGRectGetMaxY(rect))/2);  // mid left
    CGContextClosePath(ctx);
    
    //(0xDC2763FF)
    CGContextSetRGBFillColor(ctx, 0x00/255.f, 0x00/255.f, 0x00/255.f, 1);
    CGContextFillPath(ctx);
}

@end

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
        [_xLabel withFont:[UIFont fontWithName:kFontIcons size:18] textColor:kColorBlack backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];

        _nameLabel = [[UILabel alloc] init];
        [_nameLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeListButton] textColor:kColorBlack backgroundColor:kColorClear];
        
        [self addSubview:_nameLabel];
        [self addSubview:_xLabel];
        
        self.backgroundColor = UIColorRGBA(kColorOffWhite);
        self.layer.cornerRadius = kGeomCornerRadius;
                
//        [DebugUtilities addBorderToViews:@[_nameLabel, _xLabel]];
    }
    return self;
}

- (void)setName:(NSString *)name {
    _name = name;
    _nameLabel.text = _name;
    [_nameLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setIcon:(NSString *)icon {
    _icon = icon;
    _xLabel.text = icon;
    [_xLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame;
    frame = _xLabel.frame;
    frame.origin = CGPointMake(kGeomSpaceEdge, (CGRectGetHeight(self.frame) - CGRectGetHeight(_xLabel.frame))/2);
    _xLabel.frame = frame;
    
    frame = _nameLabel.frame;
    frame.origin.x = CGRectGetMaxX(_xLabel.frame) + kGeomSpaceInter;
    frame.origin.y = kGeomSpaceEdge;
    _nameLabel.frame = frame;

}

- (CGSize)getSuggestedSize {
    CGSize s = CGSizeZero;
    [_nameLabel sizeToFit];
    [_xLabel sizeToFit];
    s.width = 2*kGeomSpaceEdge + width(_nameLabel) + width(_xLabel) + (width(_xLabel) ? kGeomSpaceInter : 0);
    s.height = 2*kGeomSpaceEdge + height(_nameLabel);
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

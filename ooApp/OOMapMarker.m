//
//  OOMapMarker.m
//  ooApp
//
//  Created by Anuj Gujar on 9/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOMapMarker.h"

@interface OOMapMarker ()
@property (nonatomic, strong) UILabel *markerIcon;
@end

@implementation OOMapMarker

- (instancetype)init {
    self = [super init];
    if (self) {
        self.appearAnimation = kGMSMarkerAnimationPop;
        
        _markerIcon = [[UILabel alloc] init];
        [_markerIcon withFont:[UIFont fontWithName:kFontIcons size:24] textColor:kColorBlack backgroundColor:kColorClear];
        _markerIcon.text = kFontIconPinFilled;
        _markerIcon.frame = CGRectMake(0, 0, 30, 30);
        [_markerIcon sizeToFit];
        UIView *circle = [[UIView alloc] init];
        circle.backgroundColor = UIColorRGBA(kColorBlack);
        circle.frame = CGRectMake(10, 7, 4, 4);
        circle.layer.cornerRadius = width(circle)/2;
        [_markerIcon addSubview:circle];
    }
    return self;
}

- (void)highLight:(BOOL)highlight {
    _markerIcon.textColor = (highlight) ? UIColorRGBA(kColorMarker) : UIColorRGBA(kColorMarkerFaded) ;
    self.icon = [UIImage imageFromView:_markerIcon];
    
//    [GMSMarker markerImageWithColor:((highlight) ? UIColorRGBA(kColorNavyBlue) : UIColorRGBA(kColorRed))];
}

- (BOOL)isEqual:(OOMapMarker *)object {
    return [_objectID isEqualToString:object.objectID];
}

- (NSUInteger)hash {
    return [self.objectID hash];
}
@end

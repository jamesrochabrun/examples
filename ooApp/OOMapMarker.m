//
//  OOMapMarker.m
//  ooApp
//
//  Created by Anuj Gujar on 9/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOMapMarker.h"
#import "DebugUtilities.h"

@interface OOMapMarker ()
@property (nonatomic, strong) UILabel *markerIcon;
@property (nonatomic, strong) UILabel *indexLabel;
@end

@implementation OOMapMarker

- (instancetype)init {
    self = [super init];
    if (self) {
        self.appearAnimation = kGMSMarkerAnimationPop;
        
        _markerIcon = [[UILabel alloc] init];
        [_markerIcon withFont:[UIFont fontWithName:kFontIcons size:kGeomIconSize] textColor:kColorBlack backgroundColor:kColorClear];
        _markerIcon.text = kFontIconPinFilled;
        //_markerIcon.frame = CGRectMake(0, 0, 30, 30);
        [_markerIcon sizeToFit];
        
        _indexLabel = [[UILabel alloc] init];
        [_indexLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH5] textColor:kColorBlack backgroundColor:kColorClear];
        _indexLabel.frame = CGRectMake(0, 2, 0, 0);
        [_markerIcon addSubview:_indexLabel];
    }
    return self;
}

- (void)highLight:(BOOL)highlight {
    _markerIcon.textColor = (highlight) ? UIColorRGBA(kColorMarker):UIColorRGBA(kColorMarkerFaded);
    _markerIcon.font = [UIFont fontWithName:kFontIcons size:(highlight) ? kGeomIconSize:kGeomIconSize/2];
    _indexLabel.hidden = (highlight) ? NO:YES;
    
    self.icon = [UIImage imageFromView:_markerIcon];
    
//    [GMSMarker markerImageWithColor:((highlight) ? UIColorRGBA(kColorNavyBlue) : UIColorRGBA(kColorRed))];
}

- (BOOL)isEqual:(OOMapMarker *)object {
    return [_objectID isEqualToString:object.objectID];
}

- (void)setIndex:(NSUInteger)index {
    _index = index;
    _indexLabel.text = [NSString stringWithFormat:@"%lu", _index+1];
    [_indexLabel sizeToFit];
    _indexLabel.center = CGPointMake(_markerIcon.center.x, _indexLabel.center.y);
}

- (NSUInteger)hash {
    return [self.objectID hash];
}
@end

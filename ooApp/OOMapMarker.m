//
//  OOMapMarker.m
//  ooApp
//
//  Created by Anuj Gujar on 9/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOMapMarker.h"

@implementation OOMapMarker

- (instancetype)init {
    self = [super init];
    if (self) {
        self.appearAnimation = kGMSMarkerAnimationPop;
    }
    return self;
}

- (void)highLight:(BOOL)highlight {
//    self.icon = [GMSMarker markerImageWithColor:((highlight) ? UIColorRGBA(kColorNavyBlue) : UIColorRGBA(kColorRed))];
}

- (BOOL)isEqual:(OOMapMarker *)object {
    return [_objectID isEqual:object.objectID];
}

- (NSUInteger)hash {
    return [self.objectID hash];
}
@end

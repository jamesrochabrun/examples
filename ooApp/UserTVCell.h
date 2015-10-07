//
//  UserTVCell.h
//  ooApp
//
//  Created by Zack Smith on 9/30/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ObjectTVCell.h"
#import "UserObject.h"
#import <GoogleMaps/GoogleMaps.h>

@interface UserTVCell : ObjectTVCell

@property (nonatomic, strong) UserObject *userInfo;

@end

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
#import "OOUserView.h"

@protocol UserTVCellDelegate
- (void) userImageTapped: (UserObject*)userid;
@end

@interface UserTVCell : UITableViewCell <OOUserViewDelegate>

- (void)setUser:(UserObject *)user;
@property (nonatomic,weak) NSObject<UserTVCellDelegate> *delegate;
@end

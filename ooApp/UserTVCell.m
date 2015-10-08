//
//  UserTVCell.m
//  ooApp
//
//  Created by Zack Smith on 9/30/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "UserTVCell.h"
#import "LocationManager.h"

@interface UserTVCell ()

@end

@implementation UserTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        _marker = [[GMSMarker alloc] init];
        
    }
    return self;
}

- (void)setUser:(UserObject *)user
{
    // NOTE:  the contents of the user object may have changed, therefore set user always.
    
    self.userInfo = user;
    self.thumbnail.image = nil;
    self.header.text = _userInfo.username;
    self.subHeader1.text = [NSString stringWithFormat: @"%@ %@", _userInfo.firstName,_userInfo.lastName];
    self.subHeader2.text = nil;
    
    OOAPI *api = [[OOAPI alloc] init];
    
    if (_userInfo.imageURLString) {
//        self.requestOperation = [api getUserImageWithImageRef:_userInfo.imageURLString
//                                                     maxWidth:self.frame.size.width
//                                                    maxHeight:0 success:^(NSString *link) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.thumbnail setImageWithURL:[NSURL URLWithString:link]];
//            });
//        } failure:^(NSError *error) {
//            ;
//        }];
    }
}

@end

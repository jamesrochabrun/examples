//
//  OOUserView.h
//  ooApp
//
//  Created by Anuj Gujar on 11/19/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserObject.h"

@class OOUserView;

@protocol OOUserViewDelegate <NSObject>
- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user;
@end

@interface OOUserView : UIControl

@property (nonatomic, strong) UserObject *user;
@property (nonatomic, weak) id<OOUserViewDelegate> delegate;

- (void) clear;

@end

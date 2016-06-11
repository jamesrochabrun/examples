//
//  EmptyListVC.h
//  ooApp
//
//  Created by Zack Smith on 9/23/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SubBaseVC.h"
#import "ListObject.h"
#import "EventObject.h"

@interface EmptyListVC : SubBaseVC
@property (nonatomic, strong) EventObject *eventBeingEdited;
@property (nonatomic, strong) ListObject *listItem;
@end

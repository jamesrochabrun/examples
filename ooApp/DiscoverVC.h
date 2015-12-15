//
//  DiscoverVC.h
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"
#import "ListObject.h"
#import "EventObject.h"
#import "OptionsVC.h"

@interface DiscoverVC : BaseVC <UITableViewDataSource, UITableViewDelegate, OptionsVCDelegate>

@property (nonatomic, strong) ListObject *listToAddTo;
@property (nonatomic, strong) EventObject *eventBeingEdited;

- (void)showOptionsIfTimedOut;

- (void)getRestaurants;

@end


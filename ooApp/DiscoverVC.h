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

@interface DiscoverVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ListObject *listToAddTo;
@property (nonatomic,strong) EventObject *eventBeingEdited;

- (void)getRestaurants;

@end


//
//  EventWhenVC.h E7
//  ooApp
//
//  Created by Zack Smith on 10/7/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"

@protocol EventWhenVCDelegate <NSObject>
- (void) datesChanged;
@end

@interface EventWhenVC : SubBaseVC
@property (nonatomic,weak) id<EventWhenVCDelegate> delegate;
@property (nonatomic,strong) EventObject* eventBeingEdited;
@property (nonatomic,assign) BOOL  editable;
@end

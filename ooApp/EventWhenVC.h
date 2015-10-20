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
@property (nonatomic,assign) id<EventWhenVCDelegate> delegate;
@end

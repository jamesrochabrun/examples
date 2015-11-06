//
//  EventCoordinatorVC.h E3
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "EventWhenVC.h"
#import "ParticipantsView.h"
#import "EventWhoVC.h"

@protocol EventCoordinatorVCDelegate
- (void) userDidAlterEvent;

@end

@interface EventCoordinatorVC : SubBaseVC <UIScrollViewDelegate,UICollectionViewDataSource,
                    UICollectionViewDelegate,EventWhenVCDelegate, ParticipantsViewDelegate, EventWhoVCDelegate>
@property (nonatomic,assign) id <EventCoordinatorVCDelegate> delegate;
@end


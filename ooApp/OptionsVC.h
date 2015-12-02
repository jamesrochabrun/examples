//
//  OptionsVC.h
//  ooApp
//
//  Created by Anuj Gujar on 11/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"

@class OptionsVC;

@protocol OptionsVCDelegate

- (void)optionsVCDismiss:(OptionsVC *)optionsVC withTags:(NSMutableSet *)tags;

@end

@interface OptionsVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<OptionsVCDelegate> delegate;

@end

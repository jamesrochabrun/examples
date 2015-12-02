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

- (void)optionsVCDismiss:(OptionsVC *)optionsVC;

@end

@interface OptionsVC : SubBaseVC

@property (nonatomic, weak) id<OptionsVCDelegate> delegate;

@end

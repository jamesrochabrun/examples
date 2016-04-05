//
//  UnverifiedUserVC.h
//  ooApp
//
//  Created by Anuj Gujar on 4/1/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@class UnverifiedUserVC;

@protocol UnverifiedUserVCDelegate
- (void)unverifiedUserVCDismiss:(UnverifiedUserVC *)unverifiedUserVC;
@end

@interface UnverifiedUserVC : UIViewController <UINavigationControllerDelegate,
                                                UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSString *action;
@property (nonatomic, weak) id<UnverifiedUserVCDelegate> delegate;

- (instancetype)initWithSize:(CGSize)size;
@end

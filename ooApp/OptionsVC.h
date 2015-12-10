//
//  OptionsVC.h
//  ooApp
//
//  Created by Anuj Gujar on 11/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "OptionsVCCVL.h"

@class OptionsVC;

@protocol OptionsVCDelegate

- (void)optionsVCDismiss:(OptionsVC *)optionsVC withTags:(NSMutableSet *)tags;

@end

@interface OptionsVC : BaseVC <UICollectionViewDataSource, UICollectionViewDelegate, OptionsVCCollectionViewDelegate>

@property (nonatomic, weak) id<OptionsVCDelegate> delegate;
@property (nonatomic, strong) NSMutableSet *userTags;

@end

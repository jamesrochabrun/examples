//
//  OOTextEntryModalVC.h
//  ooApp
//
//  Created by Anuj Gujar on 1/2/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "NavTitleObject.h"

@protocol OOTextEntryModalVCDelegate
- (void)textEntryFinished:(NSString *)text;
@end

@interface OOTextEntryModalVC : SubBaseVC <UITextViewDelegate>
@property (nonatomic, weak) id<OOTextEntryModalVCDelegate> delegate;
@property (nonatomic, strong) NSString *defaultText;
@property (nonatomic, assign) NSUInteger textLengthLimit;
@property (nonatomic, strong) NavTitleObject *nto;
- (NSString*)text;
@end

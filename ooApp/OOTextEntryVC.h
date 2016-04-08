//
//  OOTextEntryVC.h
//  ooApp
//
//  Created by Anuj Gujar on 1/2/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "NavTitleObject.h"

@class OOTextEntryVC;

@protocol OOTextEntryVCDelegate
- (void)textEntryFinished:(NSString *)text;
@end

@interface OOTextEntryVC : SubBaseVC <UITextViewDelegate>
@property (nonatomic, weak) id<OOTextEntryVCDelegate> delegate;
@property (nonatomic, strong) NSString *defaultText;
@property (nonatomic, assign) NSUInteger textLengthLimit;
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *postButton;
- (NSString*)text;
@end

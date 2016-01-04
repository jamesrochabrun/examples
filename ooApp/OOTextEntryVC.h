//
//  OOTextEntryVC.h
//  ooApp
//
//  Created by Anuj Gujar on 1/2/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "NavTitleObject.h"

@class OOTextEntryVC;

@protocol OOTextEntryVCDelegate
- (void)ooTextEntryVC:(OOTextEntryVC *)textEntryVC textToSubmit:(NSString *)text;
- (void)textEntryFinished:(OOTextEntryVC *)textEntryVC;
@end

@interface OOTextEntryVC :  BaseVC <UITextViewDelegate>
@property (nonatomic, weak) id<OOTextEntryVCDelegate> delegate;
@property (nonatomic, strong) NSString *defaultText;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NavTitleObject *nto;
@end

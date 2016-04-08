//
//  OOFeedbackView.h
//  ooApp
//
//  Created by Anuj Gujar on 4/7/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OOFeedbackView : UIView

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *icon;

- (instancetype)initWithFrame:(CGRect)frame andMessage:(NSString *)message andIcon:(NSString *)icon;
- (void)show;

@end


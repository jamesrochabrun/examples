//
//  SubBaseVC.h
//  ooApp
//
//  Created by Anuj Gujar on 9/15/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "NavTitleObject.h"

@interface SubBaseVC : UIViewController

@property (nonatomic, strong) NavTitleObject *navTitle;
@property (nonatomic, strong) OOAIV *aiv;
@property (nonatomic, strong) UIProgressView *uploadProgressBar;
@property (nonatomic, assign) BOOL uploading;

- (UIButton *)addNavButtonWithIcon:(NSString *)icon target:(id)target action:(SEL)selector forSide:(NavBarSideType)side isCTA:(BOOL)isCTA;
- (void)removeNavButtonForSide:(NavBarSideType)side;

- (void)registerForNotification:(NSString*) name calling:(SEL)selector;
- (void)unregisterFromNotifications;

@end

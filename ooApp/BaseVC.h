//
//  BaseVC.h
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavTitleObject.h"
#import "DropDownListTVC.h"
#import "NavTitleView.h"

typedef enum {
    kNavBarSideTypeLeft,
    kNavBarSideTypeRight
} NavBarSideType;

@interface BaseVC : UIViewController <DropDownListTVCDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) IBOutlet UIBarButtonItem *leftNavButton;
@property (nonatomic, strong) NavTitleObject *navTitle;
@property (nonatomic, strong) DropDownListTVC *dropDownList;
@property (nonatomic, strong) NavTitleView *navTitleView;
@property (nonatomic, strong) OOAIV *aiv;
@property (nonatomic, strong) UIProgressView *uploadProgressBar;
@property (nonatomic, assign) BOOL uploading;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

//- (void)setRightNavWithIcon:(NSString *)icon target:(id)target action:(SEL)selector;
//- (void)setLeftNavWithIcon:(NSString *)icon target:(id)targer action:(SEL)sector;
- (void)displayDropDown:(BOOL)showIt;
- (void)registerForNotification:(NSString*) name calling:(SEL)selector;
- (void)unregisterFromNotifications;
- (CGRect)getRightButtonFrame;

- (UIButton *)addNavButtonWithIcon:(NSString *)icon target:(id)target action:(SEL)selector forSide:(NavBarSideType)side isCTA:(BOOL)isCTA;
- (void)removeNavButtonForSide:(NavBarSideType)side;

@end

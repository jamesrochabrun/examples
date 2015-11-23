//
//  BaseVC.h
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "NavTitleObject.h"
#import "DropDownListTVC.h"
#import "NavTitleView.h"

@interface BaseVC : UIViewController <SWRevealViewControllerDelegate, DropDownListTVCDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *leftNavButton;
@property (nonatomic, strong) NavTitleObject *navTitle;
@property (nonatomic, strong) DropDownListTVC *dropDownList;
@property (nonatomic, strong) NavTitleView *navTitleView;

- (void)setLeftNavWithIcon:(NSString *)icon target:(id)targer action:(SEL)sector;
- (void)displayDropDown:(BOOL)showIt;

@end

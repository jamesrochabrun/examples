//
//  BaseVC.h
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface BaseVC : UIViewController

@property (nonatomic, strong) IBOutlet UIBarButtonItem *menu;

@property (nonatomic, strong) NSString *screenTitle;

- (void)layout;
@end

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
@property (nonatomic, strong) UIButton *moreButton;

@end

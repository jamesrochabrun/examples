//
//  CreateUsernameVC.h
//  ooApp
//
//  Created by Zack Smith on 9/23/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "BaseVC.h"

@interface CreateUsernameVC : BaseVC <UITextFieldDelegate>
@property (nonatomic,strong) NSString* listName;
@end

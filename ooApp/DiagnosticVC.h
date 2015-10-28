//
//  DiagnosticVC.h
//  ooApp
//
//  Created by Zack Smith on 9/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseVC.h"

@interface DiagnosticVC : BaseVC<UIImagePickerControllerDelegate,UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>

@end


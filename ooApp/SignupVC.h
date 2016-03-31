//
//  SignupVC.h
//  ooApp
//
//  Created by Anuj Gujar on 3/23/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <SafariServices/SafariServices.h>

@interface SignupVC : UIViewController <FBSDKLoginButtonDelegate,
                                        TTTAttributedLabelDelegate,
                                        UINavigationControllerDelegate,
                                        SFSafariViewControllerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> navControllerDelegate;

@end

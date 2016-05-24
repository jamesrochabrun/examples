//
//  IntroScreenView.h
//  ooApp
//
//  Created by Anuj Gujar on 3/23/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface IntroScreenView : UIView

@property (nonatomic, strong) NSString *backgroundImageURL;
@property (nonatomic, strong) NSString *phoneImageURL;
@property (nonatomic, strong) NSString *introTitle;
@property (nonatomic, strong) NSString *introDescription;
@property (nonatomic, strong) NSArray *underlinedWords;

@end

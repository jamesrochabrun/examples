//
//  ShowMediaItemAnimator.h
//  ooApp
//
//  Created by Anuj Gujar on 1/27/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShowMediaItemAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL presenting;
@property (nonatomic) CGFloat duration;
@property (nonatomic) CGRect originRect;


@end

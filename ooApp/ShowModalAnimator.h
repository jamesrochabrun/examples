//
//  ShowModalAnimator.h
//  ooApp
//
//  Created by Anuj Gujar on 4/3/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShowModalAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL presenting;
@property (nonatomic) CGFloat duration;


@end

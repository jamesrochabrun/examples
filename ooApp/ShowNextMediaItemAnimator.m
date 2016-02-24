//
//  ShowNextMediaItemAnimator.m
//  ooApp
//
//  Created by Anuj Gujar on 1/27/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ShowNextMediaItemAnimator.h"
#import "ViewPhotoVC.h"
#import "FoodFeedVC.h"
#import "DebugUtilities.h"

@implementation ShowNextMediaItemAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // Presenting
    if (_presenting) {
        // Position the view offscreen
        
        toView = toVC.view;
        
        NSLog(@"presenting origin frame %@", NSStringFromCGRect(_originRect));
        toView.frame = _originRect;
        [containerView addSubview:toVC.view];
        
        CGRect newFrame = _originRect;
        newFrame.origin.x = 0;
        NSLog(@"presenting new frame %@", NSStringFromCGRect(newFrame));
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            toView.frame = newFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];;
        }];
    } else {
        NSLog(@"popping origin frame %@", NSStringFromCGRect(fromVC.view.frame));
        [containerView addSubview:toView];
        [containerView sendSubviewToBack:toView];
        
        NSLog(@"popping new frame %@", NSStringFromCGRect(_originRect));
        
        // Animate the view onscreen
        [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            fromView.frame = _originRect;
        } completion:^(BOOL finished) {
            [fromView removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 4; //self.duration;// (_duration) ? _duration : 2;
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end

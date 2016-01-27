//
//  ShowMediaItemAnimator.m
//  ooApp
//
//  Created by Anuj Gujar on 1/27/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ShowMediaItemAnimator.h"

@implementation ShowMediaItemAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    
    // Presenting
    if (_presenting) {
        // Position the view offscreen
        toView.frame = _originRect;
        toView.alpha = 0;
        [containerView addSubview:toView];
        
        // Animate the view onscreen
        [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            toView.frame = initialFrame;
            toView.alpha = 1;
            toVC.tabBarController.tabBar.hidden = YES;
            toVC.navigationController.navigationBarHidden = YES;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];;
        }];
    }
    // Dismissing
    else {
        [containerView addSubview:toView];
        [containerView sendSubviewToBack:toView];
        
        // Animate the view onscreen
        [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            fromView.frame = _originRect;
            fromView.alpha = 0;
            toVC.tabBarController.tabBar.hidden = NO;
            toVC.navigationController.navigationBarHidden = NO;
        } completion:^(BOOL finished) {
            [fromView removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return (_duration) ? _duration : 2;
}

@end

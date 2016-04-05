//
//  ShowModalAnimator.m
//  ooApp
//
//  Created by Anuj Gujar on 4/3/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ShowModalAnimator.h"

@implementation ShowModalAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    CGRect vcViewFrame = [transitionContext initialFrameForViewController:fromVC];
    
    //    vcViewFrame.origin.y = kGeomHeightNavBarStatusBar;
    
    NSLog(@"*** fromVC:%@ %@ toVC:%@ %@", NSStringFromClass([fromVC class]), fromVC, NSStringFromClass([toVC class]), toVC);
    NSLog(@"*** fromVC frame:%@ toVC frame:%@", NSStringFromCGRect(fromVC.view.frame), NSStringFromCGRect(toVC.view.frame));
    
    // Presenting
    if (_presenting) { //pushing
        UIView *snapshotView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
        snapshotView.tag = 1;
        snapshotView.frame = vcViewFrame;
        [toVC.view addSubview:snapshotView];
        [toVC.view sendSubviewToBack:snapshotView];
        
        [containerView addSubview:toVC.view];
        
        CGRect newToVCframe = toVC.view.frame;
        newToVCframe = CGRectMake(newToVCframe.origin.x, -newToVCframe.size.height, newToVCframe.size.width, newToVCframe.size.height);
        toVC.view.frame = newToVCframe;
        
        snapshotView.alpha = 0;
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            toVC.view.frame = vcViewFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];;
            snapshotView.alpha = 1;
        }];
    } else { //popping
        CGRect newFromVCframe = toVC.view.frame;
        newFromVCframe = CGRectMake(newFromVCframe.origin.x, -newFromVCframe.size.height, newFromVCframe.size.width, newFromVCframe.size.height);
        
        toVC.view.frame = vcViewFrame;
        toVC.view.alpha = 1;
        [containerView addSubview:toVC.view];
        [containerView sendSubviewToBack:toVC.view];
        
        fromVC.view.alpha = 1;
        UIView *b = [fromVC.view viewWithTag:1];
        b.alpha = 0;
        
        [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            fromVC.view.frame = newFromVCframe;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            [fromVC removeFromParentViewController];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return (self.duration) ? self.duration : 1;
}

- (void)animationEnded:(BOOL)transitionCompleted {
    NSLog(@"transition completed");
}

@end

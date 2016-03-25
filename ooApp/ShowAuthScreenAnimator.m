//
//  ShowAuthScreenAnimator.m
//  ooApp
//
//  Created by Anuj Gujar on 1/27/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ShowAuthScreenAnimator.h"
#import "DebugUtilities.h"

@implementation ShowAuthScreenAnimator

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
        snapshotView.frame = vcViewFrame;
        [toVC.view addSubview:snapshotView];
        [toVC.view sendSubviewToBack:snapshotView];
        
        [containerView addSubview:toVC.view];
        
        vcViewFrame.size.height += (kGeomHeightNavBarStatusBar + kGeomHeightTabBar);
        vcViewFrame.origin.y = 0;
        
        toVC.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        toVC.view.alpha = 0;
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            toVC.view.alpha = 1;
            toVC.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];;
        }];
    } else { //popping
        toVC.view.alpha = 0;
        [containerView addSubview:toVC.view];
        //[containerView sendSubviewToBack:toVC.view];
        
        fromVC.view.alpha = 1;
        [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            toVC.view.alpha = 1;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return (self.duration) ? self.duration : 1;
}

- (void)animationEnded:(BOOL)transitionCompleted {
    NSLog(@"transition completed");
}

- (void)logVCs:(NSArray *)viewControllers {
    for (UIViewController *tempVC in viewControllers) {
        NSLog(@"*** VC:%@ %@", NSStringFromClass([tempVC class]), tempVC);
    }
}

@end

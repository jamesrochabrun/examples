//
//  ShowMediaItemAnimator.m
//  ooApp
//
//  Created by Anuj Gujar on 1/27/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ShowMediaItemAnimator.h"
#import "ViewPhotoVC.h"
#import "FoodFeedVC.h"
#import "DebugUtilities.h"

@implementation ShowMediaItemAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    CGRect imageViewFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect vcViewFrame = [transitionContext initialFrameForViewController:fromVC];
    
    imageViewFrame.origin.y = kGeomHeightNavBarStatusBar;
    
    // Presenting
    if (_presenting) {
        // Position the view offscreen
        
        ViewPhotoVC *vpvc;
        if ([toVC isKindOfClass:[ViewPhotoVC class]]) {
            vpvc = (ViewPhotoVC *)toVC;
            toView = vpvc.iv;
            [vpvc showComponents:NO];
        } else {
            return;
        }
        
        UIView *snapshotView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
        snapshotView.frame = imageViewFrame;
        [toVC.view addSubview:snapshotView];
        [toVC.view sendSubviewToBack:snapshotView];
        
        toView.frame = _originRect;
        toView.alpha = 0;
        [containerView addSubview:toVC.view];
        
        vcViewFrame.size.height += (kGeomHeightNavBarStatusBar + kGeomHeightTabBar);
        vcViewFrame.origin.y = 0;
        vpvc.backgroundView.alpha = 0;
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            toView.frame = imageViewFrame;
            toView.center = vpvc.view.center;
            toView.alpha = 1;

            vpvc.backgroundView.alpha = kAlphaBackground;
            toVC.tabBarController.tabBar.hidden = YES;
            toVC.navigationController.navigationBarHidden = YES;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];;
            vpvc.view.frame = vcViewFrame;
            [vpvc showComponents:YES];
        }];
    } else {
        [containerView addSubview:toView];
        [containerView sendSubviewToBack:toView];
        
        ViewPhotoVC *vpvc;
        if ([fromVC isKindOfClass:[ViewPhotoVC class]]) {
            vpvc = (ViewPhotoVC *)fromVC;
            fromView = vpvc.iv;
            [vpvc showComponents:NO];
        }
        // Animate the view onscreen
        [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            fromView.frame = _originRect;
            fromView.alpha = 0;
            vpvc.backgroundView.alpha = 0;
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

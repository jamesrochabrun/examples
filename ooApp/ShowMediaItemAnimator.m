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
    
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    initialFrame.origin.y = kGeomHeightNavBarStatusBar;
    
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
//        snapshotView.alpha = 0.1;
        snapshotView.frame = initialFrame;
        [toVC.view addSubview:snapshotView];
        [toVC.view sendSubviewToBack:snapshotView];
        
        toView.frame = _originRect;
        toView.alpha = 0;
        vpvc.view.backgroundColor = UIColorRGBA(kColorClear);
        [containerView addSubview:toVC.view];
        
        // Animate the view onscreen
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            toView.frame = initialFrame;
            toView.alpha = 1;
            vpvc.backgroundView.alpha = 0.98;
            toVC.tabBarController.tabBar.hidden = YES;
            toVC.navigationController.navigationBarHidden = YES;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];;
            vpvc.view.frame = fromVC.view.bounds;
            vpvc.view.backgroundColor = UIColorRGBA(kColorOverlay10);
            [vpvc showComponents:YES];
        }];
    }
    // Dismissing
    else {
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

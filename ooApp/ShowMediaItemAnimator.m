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
        
        if (vpvc.direction) {
            
            ViewPhotoVC *fromVPVC;
            if ([fromVC isKindOfClass:[ViewPhotoVC class]]) {
                fromVPVC = (ViewPhotoVC *)fromVC;
                [fromVPVC showComponents:YES];
                [fromVPVC setComponentsAlpha:0.7];
            } else {
                return;
            }
            
            NSLog(@"toVC direction:%ld", (long)vpvc.direction);
            toVC.tabBarController.tabBar.hidden = YES;
            toVC.navigationController.navigationBarHidden = YES;
            [containerView addSubview:toVC.view];
            CGRect frame = containerView.frame;
            frame.origin.x = -1*vpvc.direction*CGRectGetWidth(containerView.frame);
            vpvc.view.frame = frame;
            
            frame.origin.x = 0;
            
            NSLog(@"toVC old=%@ new=%@", NSStringFromCGRect(vpvc.view.frame), NSStringFromCGRect(frame));
            
            [UIView animateWithDuration:duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{

                vpvc.view.frame = frame;
                [fromVPVC setComponentsAlpha:0];
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                if (![transitionContext transitionWasCancelled]) {
                    [fromVC removeFromParentViewController];
                    [vpvc showComponents:YES];
                } else {
                    [fromVPVC setComponentsAlpha:1.0];
                }
            }];
        } else {
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [vpvc showComponents:YES];
                });
            }];
        }
    } else {
        [containerView addSubview:toView];
        [containerView sendSubviewToBack:toView];
        
        ViewPhotoVC *vpvc;
        if ([fromVC isKindOfClass:[ViewPhotoVC class]]) {
            vpvc = (ViewPhotoVC *)fromVC;
            fromView = vpvc.iv;
            [vpvc showComponents:NO];
        }
        
        if (vpvc.direction) {
            NSLog(@"fromVC direction:%ld", (long)vpvc.direction);
            fromVC.tabBarController.tabBar.hidden = YES;
            fromVC.navigationController.navigationBarHidden = YES;
            CGRect frame = containerView.frame;
            frame.origin.x = vpvc.direction*CGRectGetWidth(containerView.frame);
            
            NSLog(@"fromVC old=%@ new=%@", NSStringFromCGRect(vpvc.view.frame), NSStringFromCGRect(frame));
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                vpvc.view.frame = frame;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [vpvc showComponents:YES];
                });
            }];
        } else {
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
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return (self.duration) ? self.duration : 1;
}


@end

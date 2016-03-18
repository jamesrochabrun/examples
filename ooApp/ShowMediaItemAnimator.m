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
    ViewPhotoVC *fromVPVC, *toVPVC;
    UIView *fromIV, *toIV;
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    CGRect vcViewFrame = [transitionContext initialFrameForViewController:fromVC];
    
//    vcViewFrame.origin.y = kGeomHeightNavBarStatusBar;
    
    NSLog(@"*** fromVC:%@ %@ toVC:%@ %@", NSStringFromClass([fromVC class]), fromVC, NSStringFromClass([toVC class]), toVC);
    NSLog(@"*** fromVC frame:%@ toVC frame:%@", NSStringFromCGRect(fromVC.view.frame), NSStringFromCGRect(toVC.view.frame));
    
    // Presenting
    if (_presenting) { //pushing
        // Position the view offscreen
        if ([toVC isKindOfClass:[ViewPhotoVC class]]) {
            toVPVC = (ViewPhotoVC *)toVC;
            toIV = toVPVC.iv;
            [toVPVC showComponents:NO];
        } else {
            return;
        }
        
        if (toVPVC.direction) { //when panning to new photo
            if ([fromVC isKindOfClass:[ViewPhotoVC class]]) {
                fromVPVC = (ViewPhotoVC *)fromVC;
                [fromVPVC showComponents:YES];
                [fromVPVC setComponentsAlpha:0.7];
            } else {
                return;
            }
            
            NSLog(@"toVC direction:%ld", (long)toVPVC.direction);
            [containerView addSubview:toVC.view];
            CGRect frame = containerView.frame;
            frame.origin.x = -1*toVPVC.direction*CGRectGetWidth(containerView.frame);
            toVPVC.view.frame = frame;
            
            frame.origin.x = 0;
            [toVPVC setComponentsAlpha:1];
            [toVPVC showComponents:YES];
            
            NSLog(@"toVC old=%@ new=%@", NSStringFromCGRect(toVPVC.view.frame), NSStringFromCGRect(frame));
            
            [UIView animateWithDuration:duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{

                toVPVC.view.frame = frame;
                [toVPVC setComponentsAlpha:1.0];
                [fromVPVC setComponentsAlpha:0];
                [fromVPVC.backgroundView setAlpha:0];
            } completion:^(BOOL finished) {
                if (![transitionContext transitionWasCancelled]) { //transition not canceled
                    [self logVCs:[fromVPVC.navigationController viewControllers]];
                    NSLog(@"removing %@", fromVPVC);
                    [fromVPVC removeFromParentViewController];
                    [self logVCs:[toVC.navigationController viewControllers]];
                } else { //transition canceled
                    [fromVPVC setComponentsAlpha:1.0];
                }
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        } else { //when first showing photo
            UIView *snapshotView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
            snapshotView.frame = vcViewFrame;
            [toVC.view addSubview:snapshotView];
            [toVC.view sendSubviewToBack:snapshotView];
            
            toIV.frame = _originRect;
            toIV.alpha = 0;
            [containerView addSubview:toVC.view];
            
            vcViewFrame.size.height += (kGeomHeightNavBarStatusBar + kGeomHeightTabBar);
            vcViewFrame.origin.y = 0;
            toVPVC.backgroundView.alpha = 0;
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                toIV.frame = vcViewFrame;
                toIV.center = toVPVC.view.center;
                toIV.alpha = 1;

                toVPVC.backgroundView.alpha = kAlphaBackground;
                toVPVC.tabBarController.tabBar.hidden = YES;
//
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];;
                toVPVC.view.frame = vcViewFrame;
                [toVPVC showComponents:YES];
            }];
        }
    } else { //popping
        [containerView addSubview:toVC.view];
        [containerView sendSubviewToBack:toVC.view];
        
        if ([fromVC isKindOfClass:[ViewPhotoVC class]]) {
            fromVPVC = (ViewPhotoVC *)fromVC;
            fromIV = fromVPVC.iv;
            [fromVPVC showComponents:NO];
        } else {
            return;
        }
        
        if (fromVPVC.direction) { // interactive panning (popping)
            NSLog(@"*** fromIV frame:%@", NSStringFromCGRect(fromIV.frame));
            NSLog(@"fromVC direction:%ld", (long)fromVPVC.direction);
//            fromVC.tabBarController.tabBar.hidden = YES;
            CGRect frame = fromVPVC.view.frame;
            frame.origin.x = fromVPVC.direction*CGRectGetWidth(containerView.frame);
            
            NSLog(@"fromVC old=%@ new=%@", NSStringFromCGRect(fromVPVC.view.frame), NSStringFromCGRect(frame));
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                fromVPVC.view.frame = frame;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [fromVPVC showComponents:YES];
                });
            }];
        } else { //dismissing a photo
            [self logVCs:[fromVPVC.navigationController viewControllers]];
            NSLog(@"*** fromIV frame:%@ containerView frame:%@", NSStringFromCGRect(fromIV.frame), NSStringFromCGRect(containerView.frame));
            _originRect = fromVPVC.originRect;
            
            [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                NSLog(@"*** fromIV frame:%@ containerView frame:%@", NSStringFromCGRect(fromIV.frame), NSStringFromCGRect(containerView.frame));
//                fromIV.frame = _originRect;
                fromIV.alpha = 0;
                fromVPVC.view.alpha = 0;
                toVC.view.alpha = 1;
            } completion:^(BOOL finished) {
                [self logVCs:[toVC.navigationController viewControllers]];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
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

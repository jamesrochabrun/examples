//
//  UnverifiedUserVC.m
//  ooApp
//
//  Created by Anuj Gujar on 4/1/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "UnverifiedUserVC.h"
#import "NavTitleObject.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "ShowModalAnimator.h"

@interface UnverifiedUserVC ()

@property (nonatomic, strong) UILabel *actionMessage;
@property (nonatomic, strong) UILabel *header;
@property (nonatomic, strong) UIButton *close;
@property (nonatomic, strong) UIButton *resendVerificationEmail;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation UnverifiedUserVC

- (instancetype)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        _backgroundView = [UIView new];
        _backgroundView.frame = CGRectMake(0, 0, size.width, size.height);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorRGBA(kColorClear);
    
    _backgroundView.backgroundColor = UIColorRGBA(kColorButtonBackground);
    _backgroundView.layer.cornerRadius = kGeomCornerRadius;
    
    [self.view addSubview:_backgroundView];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(done)];
    [self.view addGestureRecognizer:_tapGesture];
    
    _close = [UIButton buttonWithType:UIButtonTypeCustom];
    [_close withIcon:kFontIconRemove fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:kGeomDimensionsIconButton backgroundColor:kColorClear target:self selector:@selector(done)];
    [_close setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
    
    _header = [[UILabel alloc] init];
    _header.text = @"Verify Your Email";
    [_header withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2] textColor:kColorText backgroundColor:kColorClear];
    
    _actionMessage = [UILabel new];
    [_actionMessage withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorText backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
    _actionMessage.text = _action;
    
    _resendVerificationEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resendVerificationEmail withText:@"Resend Verification" fontSize:kGeomFontSizeH2 width:200 height:kGeomHeightButton backgroundColor:kColorTextActive target:self selector:@selector(resendVerification)];
    [_resendVerificationEmail setTitleColor:UIColorRGBA(kColorTextReverse) forState:UIControlStateNormal];
    
    [_backgroundView addSubview:_resendVerificationEmail];
    [_backgroundView addSubview:_close];
    [_backgroundView addSubview:_header];
    [_backgroundView addSubview:_actionMessage];

    //[DebugUtilities addBorderToViews:@[_resendVerificationEmail, _close, _header, _actionMessage, _backgroundView]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _backgroundView.center = self.view.center;
    
    CGFloat w = width(_backgroundView);
    CGFloat h = height(_backgroundView);
    
    CGRect frame = _close.frame;
    frame.origin = CGPointMake(w - CGRectGetWidth(_close.frame), 0);
    _close.frame = frame;
    
    [_header sizeToFit];
    frame.origin = CGPointMake((w - width(_header))/2, (CGRectGetHeight(_close.frame)-CGRectGetHeight(_header.frame))/2);
    frame.size = _header.frame.size;
    _header.frame = frame;
    
    frame = _resendVerificationEmail.frame;
    frame.origin = CGPointMake((w-width(_resendVerificationEmail))/2,
                               h - kGeomSpaceEdge - height(_resendVerificationEmail));
    frame.size.width = w-2*kGeomSpaceEdge;
    _resendVerificationEmail.frame = frame;
    
    CGSize s = [_actionMessage sizeThatFits:CGSizeMake(width(_backgroundView) - 2*kGeomSpaceEdge, 300)];
    _actionMessage.frame = CGRectMake((w-s.width)/2, (CGRectGetMinY(_resendVerificationEmail.frame)-CGRectGetMaxY(_close.frame))/2, s.width, s.height);
}

- (void)done {
    [_delegate unverifiedUserVCDismiss:self];
}

- (void)resendVerification {
    [OOAPI resendVerificationForCurrentUserSuccess:^(BOOL sent) {
        if (sent) {
            message(@"Verification Email Sent");
        } else {
            message(@"Verification Email Not Sent");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        message(@"Verification Email Not Sent");
    }];
}
- (void)setAction:(NSString *)action {
    if (_action == action) return;
    _action = action;
    _actionMessage.text = _action;
    [self.view setNeedsLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([presented isKindOfClass:[UnverifiedUserVC class]]) {
        ShowModalAnimator *animator = [[ShowModalAnimator alloc] init];
        animator.presenting = YES;
        animator.duration = 0.5;
        animationController = animator;
    }
    return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([dismissed isKindOfClass:[UnverifiedUserVC class]]) {
        ShowModalAnimator *animator = [[ShowModalAnimator alloc] init];
        animator.presenting = NO;
        animator.duration = 0.5;
        animationController = animator;
    }
    
    return animationController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

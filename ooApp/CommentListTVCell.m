//
//  CommentListTVCell.m
//  ooApp
//
//  Created by James Rochabrun on 20-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "CommentListTVCell.h"
#import "DebugUtilities.h"
#import "CommentObject.h"
#import "DebugUtilities.h"
#import "NSString+NSStringToDate.h"


@interface CommentListTVCell ()


@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UILabel *labelName;
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, strong) UILabel *commentDateLabel;
@property (nonatomic, strong) UILabel *commentLabel;

@end


@implementation CommentListTVCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        
        self.translatesAutoresizingMaskIntoConstraints = YES;
        
        _userView = [[OOUserView alloc] init];
        [self addSubview:_userView];
        _userView.delegate = self;
        self.autoresizesSubviews = YES;
        [self setSeparatorInset:UIEdgeInsetsZero];
        self.backgroundColor = UIColorRGBA(kColorOffBlack);
        
        _labelName = [UILabel new];
        [_labelName withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH3] textColor:kColorText backgroundColor:kColorClear];
        _labelName.adjustsFontSizeToFitWidth = NO;
        _labelName.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_labelName];
        
        _commentDateLabel = [UILabel new];
        [_commentDateLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorGrayMiddle backgroundColor:kColorClear];
        [self addSubview:_commentDateLabel];
        
        _commentLabel = [UILabel new];
        [_commentLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4] textColor:kColorOffBlack backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentNatural];
        [self addSubview:_commentLabel];
        
        //[DebugUtilities addBorderToViews:@[_userView, _labelName, _commentLabel , _commentDateLabel]];
    }
    return self;
}

- (void)presentUnverifiedMessage:(NSString *)message {
    
    UnverifiedUserVC *vc = [[UnverifiedUserVC alloc] initWithSize:CGSizeMake(250, 200)];
    vc.delegate = self;
    vc.action = message;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.transitioningDelegate = vc;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *nc = [UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject;
        if ([nc isKindOfClass:[UINavigationController class]]) {
            ((UINavigationController *)nc).delegate = vc;
        }
        
        [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:vc animated:YES completion:nil];
    });
}

- (void)unverifiedUserVCDismiss:(UnverifiedUserVC *)unverifiedUserVC {
    
    [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user {
    
    [self.delegate userTappedImageOfUser:user];
}

- (void)setUser:(UserObject *)user {
    
    if (user == _user) return;
    _user = user;
    __weak CommentListTVCell *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.userView setUser:weakSelf.user];
        weakSelf.labelName.text = [NSString stringWithFormat:@"@%@", user.username];
        [weakSelf setNeedsLayout];
    });
    
}

- (void)setComment:(CommentObject *)comment {
    
    if (comment == _comment) return;
    _comment = comment;
    
    __weak CommentListTVCell *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.commentLabel.text = weakSelf.comment.content;
        weakSelf.commentDateLabel.text = [NSString getTimeAgoString:weakSelf.comment.createdAt];
        [weakSelf setNeedsLayout];
    });
}
//
//- (void)prepareForReuse {
//    
//    [super prepareForReuse];
//    _labelName.text = nil;
//    _commentDateLabel = nil;
//    _commentLabel =  nil;
//    [_userView clear];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = _userView.frame;
    frame.size.height = kGeomDimensionsIconButton;
    frame.size.width = kGeomDimensionsIconButton;
    frame.origin.x = kGeomSpaceEdge;
    frame.origin.y = kGeomSpaceEdge;
    _userView.frame = frame;
    
    [_commentDateLabel sizeToFit];
    frame = _commentDateLabel.frame;
    frame.origin.x = width(self) - kGeomSpaceEdge - frame.size.width;
    frame.origin.y = CGRectGetMinY(_userView.frame);
    _commentDateLabel.frame = frame;

    [_labelName sizeToFit];
    frame = _labelName.frame;
    frame.origin = CGPointMake(CGRectGetMaxX(_userView.frame) + kGeomSpaceEdge, CGRectGetMinY(_userView.frame));
    _labelName.frame = frame;

    //NSLog(@"self.frame=%@, _commentdatelabel.frame = %@, labelName.Frame=%@", NSStringFromCGRect(self.frame), NSStringFromCGRect(_commentDateLabel.frame), NSStringFromCGRect(_labelName.frame));
    
    frame = _commentLabel.frame;
    frame.size.width = CGRectGetMaxX(_commentDateLabel.frame) - CGRectGetMinX(_labelName.frame) - 20;
    frame.size.height = [_commentLabel sizeThatFits:CGSizeMake(frame.size.width, 200)].height;
    frame.origin.y = CGRectGetMaxY(_labelName.frame);
    frame.origin.x = CGRectGetMaxX(_userView.frame) + kGeomSpaceCellPadding * 2;
    _commentLabel.frame = frame;
    
    [_userView layoutIfNeeded];
    
    [DebugUtilities addBorderToViews:@[_userView, _labelName, _commentLabel, _commentDateLabel]];
}

+ (CGFloat)heightForComment:(CommentObject *)comment {
    
    CGFloat minHeight = kGeomDimensionsIconButton + kGeomSpaceEdge * 2;
    UIFont *font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4];// [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGRect commentBoundingBox = [comment.content boundingRectWithSize:CGSizeMake(width([UIApplication sharedApplication].keyWindow) - (2 * kGeomSpaceEdge) -kGeomDimensionsIconButton - 20, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName : font} context:nil];
    
    font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3];
    CGRect nameBoundingBox = [@"FFF" boundingRectWithSize:CGSizeMake(width([UIApplication sharedApplication].keyWindow) - (2 * kGeomSpaceEdge) - kGeomDimensionsIconButton, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName : font} context:nil];
    
    NSString *str = NSStringFromCGRect(commentBoundingBox);
    NSLog(@"the boundingbox is %@", str);
    
    return MAX(minHeight, CGRectGetHeight(commentBoundingBox) + CGRectGetHeight(nameBoundingBox) + 2 * kGeomSpaceEdge );
}



@end















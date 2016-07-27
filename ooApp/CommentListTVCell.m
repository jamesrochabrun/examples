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

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        
        self.translatesAutoresizingMaskIntoConstraints = YES;

        _userView= [[OOUserView alloc] init];
        [self addSubview:_userView];
        _userView.delegate = self;
        self.autoresizesSubviews = YES;
        [self setSeparatorInset:UIEdgeInsetsZero];
        self.backgroundColor = UIColorRGBA(kColorOffBlack);
        
        _labelName = makeLabelLeft (self, @"Name ", kGeomFontSizeSubheader);
        _labelName.numberOfLines = 1;
        _labelName.adjustsFontSizeToFitWidth = NO;
        _labelName.lineBreakMode = NSLineBreakByTruncatingTail;
        _labelName.textColor=UIColorRGBA(kColorText);
        
        _commentDateLabel = [UILabel new];
        [_commentDateLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorGrayMiddle backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        [self addSubview:_commentDateLabel];
        
        _commentLabel = [UILabel new];
        [_commentLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4] textColor:kColorOffBlack backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByClipping textAlignment:NSTextAlignmentNatural];
        //_commentLabel.text = @"hsdbkj ckjhkhelloeojmb;kjsdbkj";
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
        ;
    }];
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user {
    [self.delegate userTappedImageOfUser:user];
}

//this its what I need to see in depth
- (void)setUserInfo:(UserObject *)userInfo {
    if (_userInfo == userInfo) return;
    _userInfo = userInfo;
    NSLog(@"_userInfo: %@ user: %@ same? %d", _userInfo, _userInfo, (_userInfo==userInfo));

    [_userView setUser:_userInfo];
    _labelName.text = [NSString stringWithFormat:@"%@ %@",
                       _userInfo.firstName ? : @"",
                       _userInfo.lastName ? : @""];
}

- (void)provideUser:(UserObject *)user {
    self.userInfo = user;
}
//////////////////////////////////////////////

- (void)provideComment:(CommentObject *)comment {
    _commentLabel.text = comment.content;
    NSString *commentCreatedAt = [NSString getTimeAgoString:comment.createdAt];
    _commentDateLabel.text = commentCreatedAt;
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
    
    CGFloat kGeomUserListVCCellMiddleGap = 7;
    CGFloat w = self.frame.size.width;
    CGFloat margin = kGeomSpaceEdge; //6
    CGFloat spacing = kGeomSpaceCellPadding; //3
    CGFloat imageSize = kGeomDimensionsIconButton; //40
    
    float x = margin + imageSize + kGeomUserListVCCellMiddleGap + kGeomSpaceCellPadding; //53
    float y = margin; //6
    float labelHeight = _labelName.intrinsicContentSize.height;
    if  (labelHeight < 1) {
        labelHeight = kGeomHeightButton; //44.0
    }
    _labelName.frame = CGRectMake(x, y, w - x - kGeomDimensionsIconButtonSmall, labelHeight);
    
    CGRect frame = _userView.frame;
    frame.size.height = imageSize;
    frame.size.width = imageSize;
    frame.origin.x = margin + spacing;
    frame.origin.y = CGRectGetMaxY(_labelName.frame);
    _userView.frame = frame;
    
    frame = _commentDateLabel.frame;
    frame.size = CGSizeMake(kGeomDimensionsIconButtonSmall, kGeomDimensionsIconButtonSmall);
    frame.origin.x = width(self) - kGeomDimensionsIconButtonSmall + kGeomInterImageGap;
    frame.origin.y = CGRectGetMaxY(_labelName.frame);
    _commentDateLabel.frame = frame;
    
    //NSLog(@"self.frame=%@, _commentdatelabel.frame = %@, labelName.Frame=%@", NSStringFromCGRect(self.frame), NSStringFromCGRect(_commentDateLabel.frame), NSStringFromCGRect(_labelName.frame));
    
    CGFloat height;
    frame = _commentLabel.frame;
    frame.size.width = _labelName.frame.size.width;
    height = [_commentLabel sizeThatFits:CGSizeMake(frame.size.width, 200)].height;
    frame.size.height = (kGeomHeightButton > height) ? kGeomHeightButton : height;
    frame.origin.y = CGRectGetMaxY(_labelName.frame) + kGeomSpaceEdge;
    frame.origin.x = CGRectGetMaxX(_userView.frame) + spacing + kGeomSpaceCellPadding;
    _commentLabel.frame = frame;
    NSLog(@"teh width is %f", _commentLabel.frame.size.width);
    
    
    [_userView layoutIfNeeded];
    
    //[DebugUtilities addBorderToViews:@[_userView, _labelName, _commentLabel, _commentDateLabel]];

}

+ (CGFloat)heightForComment:(CommentObject *)comment {

    CGFloat minHeight = 100; //kGeomHeightHorizontalListRow;
    
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGRect boundingBox = [comment.content boundingRectWithSize:CGSizeMake(230, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName : font} context:nil];
    
    NSString *str = NSStringFromCGRect(boundingBox);
    NSLog(@"the boundingbox is %@", str);
    
    return MAX(minHeight, CGRectGetHeight(boundingBox));
    
}



@end















//
//  CommentListTVCell.m
//  ooApp
//
//  Created by James Rochabrun on 20-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "CommentListTVCell.h"
#import "DebugUtilities.h"



@interface CommentListTVCell ()


@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UILabel *labelUserName;
@property (nonatomic, strong) UILabel *labelName;
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, strong) AFHTTPRequestOperation* op;
@property (nonatomic, strong) UILabel *commentDateLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@end

@implementation CommentListTVCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        
        _userView= [[OOUserView alloc] init];
        [self addSubview:_userView];
        _userView.delegate = self;
        self.autoresizesSubviews = NO;
        [self setSeparatorInset:UIEdgeInsetsZero];
        
        self.backgroundColor = UIColorRGBA(kColorOffBlack);
        
        _labelUserName = makeLabelLeft (self, @"@username", kGeomFontSizeHeader);
        _labelName = makeLabelLeft (self, @"Name ", kGeomFontSizeSubheader);
        _labelName.numberOfLines=1;
        
        _labelUserName.adjustsFontSizeToFitWidth = NO;
        _labelName.adjustsFontSizeToFitWidth = NO;
        _labelUserName.lineBreakMode = NSLineBreakByTruncatingTail;
        _labelName.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _labelUserName.textColor=UIColorRGBA(kColorText);
        _labelName.textColor=UIColorRGBA(kColorText);
        
        _commentDateLabel = [UILabel new];
        [_commentDateLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorGrayMiddle backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        _commentDateLabel.text = @"1d";
        [self addSubview:_commentDateLabel];
        
        _commentLabel = [UILabel new];
        [_commentLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4] textColor:kColorGrayMiddle backgroundColor:kColorGrayMiddle numberOfLines:0 lineBreakMode:NSLineBreakByClipping textAlignment:NSTextAlignmentLeft];
        _commentLabel.text = @"helloeojmb;kjsdbkjd cjbdjcdkjckjdc ckjhk helloeojmb;kjsdbkjd cjbdjcdkjckjdc ckjhkhelloeojmb;kjsdbkjd cjbdjcdkjckjdc ckjhkhelloeojmb;kjsdbkjd cjbdjcdkjckjdc ckjhkhelloeojmb;kjsdbkjd cjbdjcdkjckjdc ckjhkhelloeojmb;kjsdbkj";
        _commentLabel.backgroundColor = [UIColor redColor];
        [self addSubview:_commentLabel];
        
        
        //        [DebugUtilities addBorderToViews:@[_photosIcon, _photosNumber, _yumIcon, _yumNumber, _placesIcon, _placesNumber, _labelFollowing, _labelFollowers, _labelFollowersNumber, _labelFollowingNumber]];
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

- (void)fetchStats {
    __weak CommentListTVCell *weakSelf = self;
    NSUInteger userid = self.userInfo.userID;
    [OOAPI getUserStatsFor:userid success:^(UserStatsObject *object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //here 
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog  (@"STATS ERROR %@",error);
    }
     ];
    
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user {
    [self.delegate userTappedImageOfUser:user];
}

- (void)provideUser:(UserObject *)user; {
    
    NSLog(@"_userInfo: %@ user: %@ same? %d", _userInfo, user, (_userInfo==user));
    
    if (!user) return;
    
    self.userInfo = user;
    
    [_userView setUser:user];
    
    NSString *string= user.username ? [NSString stringWithFormat:@"@%@",user.username] : @"Unknown";
    _labelUserName.text = string;
    
    _labelName.text = [NSString stringWithFormat:@"%@ %@",
                       user.firstName ? : @"",
                       user.lastName ? : @""];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    _labelUserName.text=nil;
    _labelName.text=nil;
    
    [_userView clear];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    const float kGeomUserListVCCellMiddleGap= 7;
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    const float margin = kGeomSpaceEdge;
    const float spacing = kGeomSpaceCellPadding;
    float imageSize = kGeomDimensionsIconButton;
    _userView.frame = CGRectMake(0,0 , imageSize, imageSize);
    [_userView setCenter:CGPointMake(kGeomDimensionsIconButtonSmall, h/2)];
    
    float x=margin+imageSize+kGeomUserListVCCellMiddleGap;
    float y=margin;
    float labelHeight=_labelName.intrinsicContentSize.height;
    if  (labelHeight<1) {
        labelHeight= kGeomHeightButton;
    }
    _labelName.frame=CGRectMake(x, y, w-margin-x, labelHeight);
    
    y +=  labelHeight;
    _buttonFollow.frame = CGRectMake(w-margin-kGeomWidthButton, y+3,kGeomWidthButton, kGeomFollowButtonHeight);
    
    y += spacing;
    labelHeight=_labelUserName.intrinsicContentSize.height;
    if  ( labelHeight<1) {
        labelHeight= kGeomHeightButton;
    }
    
    if  (_buttonFollow.hidden ) {
        _labelUserName.frame=CGRectMake(x, y, w-margin-x, labelHeight);
    } else {
        _labelUserName.frame=CGRectMake(x, y, w-kGeomWidthButton-margin-spacing-x, labelHeight);
    }
    
    //CGRect frame = self.frame;
    CGRect frame = _commentDateLabel.frame;
    frame.size = CGSizeMake(kGeomDimensionsIconButtonSmall, kGeomDimensionsIconButtonSmall);
    frame.origin = CGPointMake(width(self) - kGeomDimensionsIconButtonSmall - kGeomInterImageGap,_userView.frame.origin.y);
    _commentDateLabel.frame = frame;
    
    CGFloat height;
    frame = _commentLabel.frame;
    frame.size.width = CGRectGetMinX(_commentDateLabel.frame) - CGRectGetMaxX(_userView.frame) - kGeomDimensionsIconButtonSmall;
    height = [_commentLabel sizeThatFits:CGSizeMake(frame.size.width, 200)].height;
    NSLog(@"height : %f", height);
    frame.size.height = (kGeomHeightButton > height) ? kGeomHeightButton : height;
    frame.origin.y = CGRectGetMaxY(_labelName.frame);
    frame.origin.x = CGRectGetMaxY(_userView.frame);
    _commentLabel.frame = frame;
    
    
    
    [_userView layoutIfNeeded];
}




@end















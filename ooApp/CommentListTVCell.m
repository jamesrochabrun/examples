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
    const float margin = kGeomSpaceEdge;
    const float spacing = kGeomSpaceCellPadding;
    float imageSize = kGeomUserListUserImageHeight;
    _userView.frame = CGRectMake(kGeomSpaceEdge, kGeomSpaceEdge, imageSize, imageSize);
    
    float x=margin+imageSize+kGeomUserListVCCellMiddleGap;
    float y=margin;
    float labelHeight=_labelUserName.intrinsicContentSize.height;
    if  (labelHeight<1) {
        labelHeight= kGeomHeightButton;
    }
    _labelUserName.frame=CGRectMake(x, y, w-margin-x, labelHeight);
    
    y +=  labelHeight;
    _buttonFollow.frame = CGRectMake(w-margin-kGeomWidthButton, y+3,kGeomWidthButton, kGeomFollowButtonHeight);
    
    y += spacing;
    labelHeight=_labelName.intrinsicContentSize.height;
    if  ( labelHeight<1) {
        labelHeight= kGeomHeightButton;
    }
    
    if  (_buttonFollow.hidden ) {
        _labelName.frame=CGRectMake(x, y, w-margin-x, labelHeight);
    } else {
        _labelName.frame=CGRectMake(x, y, w-kGeomWidthButton-margin-spacing-x, labelHeight);
    }
    
    [_userView layoutIfNeeded];
}




@end















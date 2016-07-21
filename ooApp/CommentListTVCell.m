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

@property (nonatomic, strong) UILabel *labelFollowers;
@property (nonatomic, strong) UILabel *labelFollowing;
@property (nonatomic, strong) UILabel *placesIcon;
@property (nonatomic, strong) UILabel *yumIcon;

@property (nonatomic, strong) UILabel *yumNumber;
@property (nonatomic, strong) UILabel *placesNumber;
@property (nonatomic, strong) UILabel *photosNumber;
@property (nonatomic, strong) UILabel *labelFollowersNumber;
@property (nonatomic, strong) UILabel *labelFollowingNumber;

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

- (void)verifyUnfollow:(id)sender {
    __weak CommentListTVCell *weakSelf = self;
    
    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"Really Unfollow?")
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    a.popoverPresentationController.sourceView = sender;
    a.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style: UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes"
                                                 style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [weakSelf  doUnfollow];
                                                 }];
    
    [a addAction:cancel];
    [a addAction:ok];
    
    [self.vc presentViewController:a animated:YES completion:nil];
}

- (void)doUnfollow {
    __weak CommentListTVCell *weakSelf = self;
    
    [OOAPI setFollowingUser:_userInfo
                         to: NO
                    success:^(id responseObject) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectNeedsUpdate object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOwnProfileNeedsUpdate object:nil];
                        dispatch_async(dispatch_get_main_queue(), ^{

                            
                            NSLog (@"Unfollowed user: %@", weakSelf.userInfo.username);
                        });
                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                        NSLog (@"Failed to unfollow user: %@", weakSelf.userInfo.username);
                    }];
}


//------------------------------------------------------------------------------
// Name:    userPressedFollow
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedFollow:(id)sender {
    if ( self.buttonFollow.selected) {
        [self verifyUnfollow:sender];
        return;
    }
    
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!result) {
            [self presentUnverifiedMessage:[NSString stringWithFormat:@"You will need to verify your email to follow @%@.\n\nCheck your email for a verification link.", _userInfo.username]];
        } else {
            __weak CommentListTVCell *weakSelf = self;
            [OOAPI setFollowingUser:_userInfo
                                 to: YES
                            success:^(id responseObject) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    weakSelf.buttonFollow.selected = YES;
                                    [weakSelf showFollowButton:YES];
                                    
                                    NSLog(@"SUCCESSFULLY FOLLOWED USER");
                                    NOTIFY(kNotificationOwnProfileNeedsUpdate);
                                    NOTIFY(kNotificationUserFollowingChanged);
                                    [weakSelf.delegate userTappedFollowButtonForUser:weakSelf.userInfo
                                                                           following:YES];
                                });
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                                NSLog (@"FAILED TO FOLLOW/UNFOLLOW USER");
                            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"*** Problem verifying user");
        if (error.code == kCFURLErrorNotConnectedToInternet) {
            message(@"You do not appear to be connected to the internet.");
        } else {
            message(@"There was a problem verifying your account.");
        }
        return;
    }];
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
            [weakSelf provideStats:object];
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
    
    [_photosNumber setText:@""];
    [_yumNumber setText:@""];
    [_placesNumber setText:@""];
    
    [_labelFollowers setText:@""];
    [_labelFollowing setText:@""];
    [_labelFollowersNumber setText:@""];
    [_labelFollowingNumber setText:@""];

}

- (void)provideStats:(UserStatsObject *)stats {
    NSUInteger followers = stats.totalFollowers;
    NSUInteger following = stats.totalFollowees;
    NSUInteger restaurantCount = stats.totalVenues;
    NSUInteger photosCount = stats.totalPhotos;
    NSUInteger yums = stats.totalLikes;
    
    [_labelFollowersNumber setText:stringFromUnsigned(followers)];
    [_labelFollowers setText:(followers == 1)? @"follower":@"followers"];
    
    _yumNumber.text = [NSString stringWithFormat:@"%lu", (unsigned long)yums];
    
    [_labelFollowingNumber setText:stringFromUnsigned(following)];
    [_labelFollowing setText:@"following"];
    
    [_placesNumber setText:[NSString stringWithFormat:@"%lu", (unsigned long)restaurantCount]];
    _photosNumber.text = [NSString stringWithFormat:@"%lu", (unsigned long)photosCount];
    
    [_yumIcon sizeToFit];
    [_placesIcon sizeToFit];
    [_photosNumber sizeToFit];
    [_yumNumber sizeToFit];
    [_placesNumber sizeToFit];
    
    if (_userInfo.userType == kUserTypeTrusted) {
        _yumNumber.frame = CGRectZero;
        _photosNumber.frame = CGRectZero;
    }
    
    [self setNeedsLayout];
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
    
    y += labelHeight+ spacing;
    
    labelHeight = 25;
    
    x = margin + imageSize + spacing;
    y = _userView.frame.size.height + _userView.frame.origin.y - labelHeight;
    
    CGFloat labelWidth;
    if (w > 320) {
        labelWidth = width(_buttonFollow)/2;
        _labelFollowersNumber.frame = CGRectMake(CGRectGetMinX(_buttonFollow.frame), y, labelWidth, labelHeight);
        _labelFollowers.frame = CGRectMake(CGRectGetMinX(_buttonFollow.frame), y+labelHeight, labelWidth, labelHeight);
        
        _labelFollowingNumber.frame = CGRectMake(CGRectGetMaxX(_labelFollowersNumber.frame), y, labelWidth, labelHeight);
        _labelFollowing.frame = CGRectMake(CGRectGetMaxX(_labelFollowers.frame), y + labelHeight, labelWidth, labelHeight);
    } else {
        labelWidth = width(_buttonFollow);
        _labelFollowersNumber.frame = CGRectMake(CGRectGetMinX(_buttonFollow.frame), y, labelWidth, labelHeight);
        _labelFollowers.frame = CGRectMake(CGRectGetMinX(_buttonFollow.frame), CGRectGetMaxY(_labelFollowersNumber.frame), labelWidth, labelHeight);
        
        _labelFollowingNumber.frame = CGRectMake(CGRectGetMinX(_buttonFollow.frame), CGRectGetMaxY(_labelFollowers.frame), labelWidth, labelHeight);
        _labelFollowing.frame = CGRectMake(CGRectGetMinX(_buttonFollow.frame), CGRectGetMaxY(_labelFollowingNumber.frame), labelWidth, labelHeight);
    }
    
    [_userView layoutIfNeeded];
}




@end















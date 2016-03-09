//
//  UserListTVC.m
//  ooApp
//
//  Created by Anuj Gujar on 2/9/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "UserListTVC.h"

@interface UserListTVC ()

@property (nonatomic, strong) UILabel *labelFollowers;
@property (nonatomic, strong) UILabel *labelFollowing;
@property (nonatomic, strong) UILabel *labelPlaces;
@property (nonatomic, strong) UILabel *labelPhotos;

@property (nonatomic, strong) UILabel *labelFollowersNumber;
@property (nonatomic, strong) UILabel *labelFollowingNumber;
@property (nonatomic, strong) UILabel *labelPlacesNumber;
@property (nonatomic, strong) UILabel *labelPhotosNumber;

@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UILabel *labelUserName;
@property (nonatomic, strong) UILabel *labelName;
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, strong) AFHTTPRequestOperation* op;
@end

@implementation UserListTVC

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
        
        _labelFollowers = makeLabel(self,nil, kGeomFontSizeDetail);
        _labelFollowing = makeLabel(self, nil, kGeomFontSizeDetail);
        _labelPhotos = makeIconLabel(self, kFontIconPhoto, kGeomIconSizeSmall);
        _labelPlaces = makeLabel(self, nil, kGeomFontSizeDetail);
        
        _labelFollowers.textColor = UIColorRGBA(kColorGrayMiddle);
        _labelFollowing.textColor = UIColorRGBA(kColorGrayMiddle);
        _labelPhotos.textColor = UIColorRGBA(kColorGrayMiddle);
        _labelPlaces.textColor = UIColorRGBA(kColorGrayMiddle);
        
        _labelFollowersNumber = makeLabel(self, @"", kGeomFontSizeSubheader);
        _labelFollowingNumber = makeLabel(self,  @"", kGeomFontSizeSubheader);
        _labelPhotosNumber = makeLabelLeft(self,  @"", kGeomFontSizeSubheader);
        _labelPlacesNumber = makeLabel(self,  @"", kGeomFontSizeSubheader);
        
        _labelFollowersNumber.textColor= UIColorRGBA(kColorText);
        _labelFollowingNumber.textColor= UIColorRGBA(kColorText);
        _labelPhotosNumber.textColor= UIColorRGBA(kColorText);
        _labelPlacesNumber.textColor= UIColorRGBA(kColorText);
        
        _labelUserName= makeLabelLeft (self, @"@username", kGeomFontSizeHeader);
        _labelName= makeLabelLeft (self, @"Name ", kGeomFontSizeSubheader);
        _labelName.numberOfLines=1;
        
        //        _labelName.minimumFontSize DEPRECATED
        _labelUserName.adjustsFontSizeToFitWidth = NO;
        _labelName.adjustsFontSizeToFitWidth = NO;
        _labelUserName.lineBreakMode = NSLineBreakByTruncatingTail;
        _labelName.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _labelUserName.textColor=UIColorRGBA(kColorText);
        _labelName.textColor=UIColorRGBA(kColorText);
        
        _buttonFollow = makeButton(self, @"FOLLOW", kGeomFontSizeSubheader,
                                   UIColorRGBA(kColorTextReverse),UIColorRGBA(kColorTextActive), self, @selector(userPressedFollow:), .5);
        [_buttonFollow setTitle:@"FOLLOWING" forState:UIControlStateSelected];
        [_buttonFollow setTitleColor: UIColorRGBA(kColorTextActive) forState:UIControlStateSelected];
        _buttonFollow.hidden= YES;
        _buttonFollow.layer.borderColor= UIColorRGBA(kColorTextActive).CGColor;
        
    }
    return self;
}

- (void)verifyUnfollow:(id)sender
{
    __weak  UserListTVC *weakSelf = self;
    
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

- (void)doUnfollow
{
    __weak UserListTVC *weakSelf = self;
    
    [OOAPI setFollowingUser:_userInfo
                         to: NO
                    success:^(id responseObject) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectNeedsUpdate object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOwnProfileNeedsUpdate object:nil];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.buttonFollow.selected= NO;
                            weakSelf.buttonFollow.backgroundColor= UIColorRGBA(kColorTextActive);
                            [weakSelf.delegate userTappedFollowButtonForUser: weakSelf.userInfo
                                                                   following: NO];
                            
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
- (void)userPressedFollow:(id)sender
{
    if ( self.buttonFollow.selected) {
        [self verifyUnfollow:sender];
        return;
    }
    
    __weak UserListTVC *weakSelf = self;
    [OOAPI setFollowingUser:_userInfo
                         to: YES
                    success:^(id responseObject) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.buttonFollow.selected = YES;
                            weakSelf.buttonFollow.backgroundColor = UIColorRGBA(kColorBlack);
                            
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

- (void)showFollowButton:(BOOL)following
{
    _buttonFollow.hidden = NO;
    _buttonFollow.selected = following;
    _buttonFollow.backgroundColor = following ? UIColorRGBA(kColorBlack):UIColorRGBA(kColorTextActive);
    _buttonFollow.layer.borderWidth = following ? 1:0;
    [self bringSubviewToFront:_buttonFollow];
}

- (void)fetchStats
{
    __weak UserListTVC *weakSelf = self;
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

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user
{
    [self.delegate userTappedImageOfUser:user];
}

- (void)provideUser:(UserObject *)user;
{
    
    NSLog(@"_userInfo: %@ user: %@ same? %d", _userInfo, user, (_userInfo==user));

    if (!user) return;

    self.userInfo = user;
    
    [_userView setUser:user];
    
    NSString *string= user.username ? [NSString stringWithFormat:@"@%@",user.username] : @"Unknown";
    _labelUserName.text = string;
    
    _labelName.text = [NSString stringWithFormat:@"%@ %@",
                       user.firstName ? : @"First",
                       user.lastName ? : @"Last"];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _labelUserName.text=nil;
    _labelName.text=nil;
    
    [_userView clear];
    
    [_labelPlaces setText:@""];
    [_labelFollowers setText:@""];
    [_labelFollowing setText:@""];
    [_labelPlacesNumber setText:@""];
    [_labelPhotosNumber setText:@""];
    [_labelFollowersNumber setText:@""];
    [_labelFollowingNumber setText:@""];
    
    _buttonFollow.backgroundColor = UIColorRGBA(kColorTextActive);
    _buttonFollow.selected = NO;
    _buttonFollow.hidden = YES;
}

- (void)provideStats:(UserStatsObject *)stats
{
    NSUInteger followers = stats.totalFollowers;
    NSUInteger following = stats.totalFollowees;
    NSUInteger restaurantCount = stats.totalVenues;
    NSUInteger photosCount = stats.totalPhotos;
    
    if (followers == 1) {
        [_labelFollowersNumber setText:@"1"];
        [_labelFollowers setText:@"follower"];
    } else {
        [_labelFollowersNumber setText:stringFromUnsigned(followers)];
        [_labelFollowers setText:@"followers"];
    }
    
    [_labelFollowingNumber setText:stringFromUnsigned(following)];
    [_labelFollowing setText:@"following"];
    
    if (restaurantCount == 1) {
        [_labelPlacesNumber setText:@"1"];
        [_labelPlaces setText:@"place"];
    } else {
        [_labelPlacesNumber setText:stringFromUnsigned(restaurantCount)];
        [_labelPlaces setText: @"places"];
    }
    
    [_labelPhotosNumber setText:stringFromUnsigned(photosCount)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    const float kGeomUserListVCCellMiddleGap= 7;
    
    float w = self.frame.size.width;
    const float margin = kGeomSpaceEdge;
    const float spacing = kGeomSpaceInter;
    float imageSize = kGeomUserListUserImageHeight;
    _userView.frame = CGRectMake(margin, margin, imageSize, imageSize);
    
    float x=margin+imageSize+kGeomUserListVCCellMiddleGap;
    float y=margin;
    float labelHeight=_labelUserName.intrinsicContentSize.height;
    if  ( labelHeight<1) {
        labelHeight= kGeomHeightButton;
    }
    _labelUserName.frame=CGRectMake(x, y, w-margin-x, labelHeight);
    
    y +=  labelHeight;
    _buttonFollow.frame = CGRectMake(w-margin-kGeomButtonWidth, y+3,kGeomButtonWidth, kGeomFollowButtonHeight);
    
    y += spacing;
    labelHeight=_labelName.intrinsicContentSize.height;
    if  ( labelHeight<1) {
        labelHeight= kGeomHeightButton;
    }
    
    if  (_buttonFollow.hidden ) {
        _labelName.frame=CGRectMake(x, y, w-margin-x, labelHeight);
    } else {
        _labelName.frame=CGRectMake(x, y, w-kGeomButtonWidth-margin-spacing-x, labelHeight);
    }
    
    y += labelHeight+ spacing;
    
    float iconWidth = 30;
    labelHeight = 20;
    
    x=  margin + imageSize + spacing;
    y = _userView.frame.size.height + _userView.frame.origin.y - labelHeight;
    _labelPhotos.frame=CGRectMake(x, y, iconWidth, labelHeight);
    x += iconWidth;
    _labelPhotosNumber.frame=CGRectMake(x, y, 55,  labelHeight);
    y += labelHeight+ spacing;
    
    labelHeight= 17;//  from mockup
    y = _userView.frame.size.height + _userView.frame.origin.y - 2*labelHeight;
    
    float rightAreaWidth= 150;//  from mockup
    int leftLabelWidth = (int) rightAreaWidth*4/14.;
    int rightLabelWidth = (int) rightAreaWidth*5/14.;
    x= w-rightAreaWidth;
    _labelPlacesNumber.frame=CGRectMake(x, y, leftLabelWidth, labelHeight);
    _labelPlaces.frame=CGRectMake(x, y +labelHeight, leftLabelWidth, labelHeight);
    x += leftLabelWidth;
    _labelFollowersNumber.frame=CGRectMake(x, y, rightLabelWidth, labelHeight);
    _labelFollowers.frame=CGRectMake(x, y +labelHeight, rightLabelWidth, labelHeight);
    x += rightLabelWidth;
    _labelFollowingNumber.frame=CGRectMake(x, y, rightLabelWidth, labelHeight);
    _labelFollowing.frame=CGRectMake(x, y +labelHeight, rightLabelWidth, labelHeight);
    
    [_userView layoutIfNeeded];
}

@end

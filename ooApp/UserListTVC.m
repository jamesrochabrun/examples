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
        _userView=[[OOUserView alloc]init];
        [self  addSubview: _userView];
        _userView.delegate=self;
        self.autoresizesSubviews= NO;
        [self setSeparatorInset:UIEdgeInsetsZero];
        
        self.backgroundColor=  UIColorRGB(kColorOffBlack);
        
        _labelFollowers= makeLabel(self,nil, kGeomFontSizeDetail);
        _labelFollowing= makeLabel(self, nil, kGeomFontSizeDetail);
        _labelPhotos=  makeIconLabel(self, kFontIconPhoto, kGeomIconSizeSmall);
        _labelPlaces=makeLabel( self, nil, kGeomFontSizeDetail);
        
        _labelFollowers.textColor= MIDDLEGRAY;
        _labelFollowing.textColor= MIDDLEGRAY;
        _labelPhotos.textColor= MIDDLEGRAY;
        _labelPlaces.textColor= MIDDLEGRAY;
        
        _labelFollowersNumber= makeLabel(self, @"", kGeomFontSizeSubheader);
        _labelFollowingNumber= makeLabel(self,  @"", kGeomFontSizeSubheader);
        _labelPhotosNumber= makeLabelLeft(self,  @"", kGeomFontSizeSubheader);
        _labelPlacesNumber=makeLabel( self,  @"", kGeomFontSizeSubheader);
        
        _labelFollowersNumber.textColor= WHITE;
        _labelFollowingNumber.textColor= WHITE;
        _labelPhotosNumber.textColor= WHITE;
        _labelPlacesNumber.textColor= WHITE;
        
        _labelUserName= makeLabelLeft (self, @"@username", kGeomFontSizeHeader);
        _labelName= makeLabelLeft (self, @"Name ", kGeomFontSizeSubheader);
        _labelName.numberOfLines=1;
        
        //        _labelName.minimumFontSize DEPRECATED
        _labelUserName.adjustsFontSizeToFitWidth = NO;
        _labelName.adjustsFontSizeToFitWidth = NO;
        _labelUserName.lineBreakMode = NSLineBreakByTruncatingTail;
        _labelName.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _labelUserName.textColor=WHITE;
        _labelName.textColor=WHITE;
        
        _labelFollowers.alpha=0;
        _labelFollowing.alpha=0;
        _labelPhotos.alpha=0;
        _labelPlaces.alpha=0;
        _labelFollowersNumber.alpha=0;
        _labelFollowingNumber.alpha=0;
        _labelPhotosNumber.alpha=0;
        _labelPlacesNumber.alpha=0;
        
        _buttonFollow = makeButton(self, @"FOLLOW", kGeomFontSizeSubheader,
                                   BLACK,YELLOW, self, @selector(userPressedFollow:), .5);
        [_buttonFollow setTitle:@"FOLLOWING" forState:UIControlStateSelected];
        [_buttonFollow setTitleColor: WHITE forState:UIControlStateSelected];
        _buttonFollow.hidden= YES;
        _buttonFollow.layer.borderColor= YELLOW.CGColor;
        
    }
    return self;
}

- (void) verifyUnfollow
{
    __weak  UserListTVC *weakSelf = self;
    
    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"Really Un-follow?")
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
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
                        ON_MAIN_THREAD(^{
                            
                            weakSelf.buttonFollow.selected= NO;
                            weakSelf.buttonFollow.backgroundColor= YELLOW;
                            [weakSelf.delegate userTappedFollowButtonForUser: weakSelf.userInfo
                                                                   following: NO];
                            NOTIFY( kNotificationOwnProfileNeedsUpdate);
                            
                            NSLog (@"SUCCESSFULLY UNFOLLOWED USER");
                        });
                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                        NSLog (@"FAILED TO UNFOLLOW USER");
                    }];
}

//------------------------------------------------------------------------------
// Name:    userPressedFollow
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedFollow:(id)sender
{
    if ( self.buttonFollow.selected) {
        [self verifyUnfollow];
        return;
    }
    
    __weak UserListTVC *weakSelf = self;
    [OOAPI setFollowingUser:_userInfo
                         to: YES
                    success:^(id responseObject) {
                        ON_MAIN_THREAD(^{
                            weakSelf.buttonFollow.selected= YES;
                            weakSelf.buttonFollow.backgroundColor= BLACK;
                            
                            NSLog (@"SUCCESSFULLY FOLLOWED USER");
                            NOTIFY( kNotificationOwnProfileNeedsUpdate);
                            [weakSelf.delegate userTappedFollowButtonForUser: weakSelf.userInfo
                                                                   following: YES];
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
    _buttonFollow.backgroundColor = following ? BLACK:YELLOW;
    _buttonFollow.layer.borderWidth = following ? 1:0;
    [self bringSubviewToFront:_buttonFollow];
}

- (void)fetchStats
{
    __weak UserListTVC *weakSelf = self;
    NSUInteger userid = self.userInfo.userID;
    [OOAPI getUserStatsFor:userid success:^(UserStatsObject *object) {
        ON_MAIN_THREAD(^{
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
    
    _labelFollowers.alpha = 0;
    _labelFollowing.alpha = 0;
    _labelPlaces.alpha = 0;
    _labelPhotos.alpha = 0;
    _labelFollowersNumber.alpha = 0;
    _labelFollowingNumber.alpha = 0;
    _labelPlacesNumber.alpha = 0;
    _labelPhotosNumber.alpha = 0;
    
    [_labelPlaces setText:@""];
    [_labelFollowers setText:@""];
    [_labelFollowing setText:@""];
    [_labelPlacesNumber setText:@""];
    [_labelPhotosNumber setText:@""];
    [_labelFollowersNumber setText:@""];
    [_labelFollowingNumber setText:@""];
    
    _buttonFollow.backgroundColor= YELLOW;
    _buttonFollow.selected= NO;
    _buttonFollow.hidden= YES;
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
    
    self.labelFollowers.alpha = 1;
    self.labelPhotos.alpha = 1;
    self.labelFollowing.alpha = 1;
    self.labelPlaces.alpha = 1;
    self.labelFollowersNumber.alpha = 1;
    self.labelPhotosNumber.alpha = 1;
    self.labelFollowingNumber.alpha = 1;
    self.labelPlacesNumber.alpha = 1;
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

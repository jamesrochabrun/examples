//
//  UserTVCell.m
//  ooApp
//
//  Created by Zack Smith on 9/30/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "UserTVCell.h"
#import "LocationManager.h"
#import "AppDelegate.h"
#import "OOUserView.h"

@interface UserTVCell ()
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic, strong) UILabel *header;
@property (nonatomic, strong) UILabel *subHeader1;

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) NSArray *tnConstraints;
@property (nonatomic, strong) NSMutableArray *shadowConstraints;
@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) UILabel *locationIcon;
@end

@implementation UserTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColorRGBA(kColorBlack);
        
        _userView = [[OOUserView alloc] init];
        [self addSubview:_userView];
        _userView.delegate= self;
        _header = makeLabelLeft(self, nil, kGeomFontSizeHeader);
        [_header withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear];
        
        _subHeader1 = makeLabelLeft(self, nil, kGeomFontSizeHeader);
        [_subHeader1 withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader] textColor:kColorWhite backgroundColor:kColorClear];
        
        self.separatorInset = UIEdgeInsetsZero;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    float h = height(self)*0.8;
    float w = width(self);
    float x = kGeomSpaceInter;
    _userView.frame = CGRectMake(x, (self.bounds.size.height-h)/2, h, h);
    [self bringSubviewToFront:_userView];
    x += h+kGeomSpaceInter;
    
    float requiredHeightForText = self.header.intrinsicContentSize.height+self.subHeader1.intrinsicContentSize.height + kGeomSpaceInter;
    float y = (h-requiredHeightForText)/2;
    self.header.frame = CGRectMake(x,y,w-x,self.header.intrinsicContentSize.height);
    y += self.header.frame.size.height;
    self.subHeader1.frame = CGRectMake(x, y, w-x, self.subHeader1.intrinsicContentSize.height);
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user
{
    if ( self.delegate) {
        [self.delegate userImageTapped: self.userInfo];
    }
}

- (void)setUser:(UserObject *)user
{
    // NOTE:  the contents of the user object may have changed, therefore set user always.
    self.userInfo = user;
    self.header.text = [NSString stringWithFormat:@"@%@", _userInfo.username];
    self.subHeader1.text = [NSString stringWithFormat: @"%@ %@", _userInfo.firstName,_userInfo.lastName];
    _userView.user = _userInfo;
}

- (void)prepareForReuse
{
    [self.requestOperation cancel];
    [_userView clear];
    self.header.text= nil;
}

@end

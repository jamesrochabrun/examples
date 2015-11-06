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

@interface UserTVCell ()
@property (nonatomic, strong) UserObject *userInfo;
@property (nonatomic, strong) UIImageView *thumbnail;
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
        self.backgroundColor = WHITE;
        _thumbnail = makeImageView(self, nil);
        _thumbnail.backgroundColor= GRAY;
        
        _header = makeLabelLeft(self, nil, kGeomFontSizeHeader);
        _header.font= [UIFont fontWithName:kFontLatoBoldItalic size:kGeomFontSizeHeader];
        
        _subHeader1 = makeLabelLeft(self, nil, kGeomFontSizeHeader);
        _subHeader1.font= [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader];
        
        self.separatorInset= UIEdgeInsetsZero;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    const float lowerGradientHeight =  8;
    float h = self.bounds.size.height-lowerGradientHeight;
    float w = self.bounds.size.width;
    float x= kGeomSpaceInter;
    self.thumbnail.frame= CGRectMake(x,0,h,h);
    x += h+kGeomSpaceInter;
    [ self  bringSubviewToFront: self.thumbnail];
    float requiredHeightForText=  self.header.intrinsicContentSize.height+self.subHeader1.intrinsicContentSize.height +kGeomSpaceInter;
    float y=  (h-requiredHeightForText)/2;
    self.header.frame = CGRectMake(x,y,w-x,self.header.intrinsicContentSize.height);
    y +=self.header.frame.size.height;
    self.subHeader1.frame = CGRectMake(x,y,w-x,self.subHeader1.intrinsicContentSize.height);
}

- (void)setUser:(UserObject *)user
{
    // NOTE:  the contents of the user object may have changed, therefore set user always.
    
    self.userInfo = user;
    self.thumbnail.image = APP.imageForNoProfileSilhouette;
    
    self.header.text = _userInfo.username;
    self.subHeader1.text = [NSString stringWithFormat: @"%@ %@", _userInfo.firstName,_userInfo.lastName];

    if (_userInfo.imageIdentifier) {
        __weak UserTVCell *weakSelf = self;
        self.requestOperation = [OOAPI getUserImageWithImageID: _userInfo.imageIdentifier
                                                    maxWidth:0
                                                   maxHeight:self.frame.size.height
                                                     success:^(NSString *link) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [weakSelf.thumbnail setImageWithURL:[NSURL URLWithString:link]];
                                                         });
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         ;
                                                     }];
    }
}

- (void)prepareForReuse
{
    [self.requestOperation  cancel];
    self.thumbnail.image= nil;
    self.header.text= nil;
}

@end

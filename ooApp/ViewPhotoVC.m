//
//  ViewPhotoVC.m
//  ooApp
//
//  Created by Anuj Gujar on 1/8/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ViewPhotoVC.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "RestaurantVC.h"
#import "UserObject.h"
#import "Settings.h"
#import "UserListVC.h"
#import "AppDelegate.h"
#import "ListsVC.h"
#import "ShowMediaItemAnimator.h"
#import "NavTitleObject.h"
#import "OOActivityItemProvider.h"
#import "OOFeedbackView.h"
#import "CommentObject.h"
#import "CommentListVC.h"
#import "CommentPhotoView.h"
#import "NSString+NSStringToDate.h"


@interface ViewPhotoVC ()
@property (nonatomic, strong) UIButton *captionButton;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) OOUserView *userViewButton;
@property (nonatomic, strong) UIButton *restaurantButton;
@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *subheader;

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UITapGestureRecognizer *yumPhotoTapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UserObject *user;
@property (nonatomic, strong) UINavigationController *aNC;
@property (nonatomic) CGPoint originPoint;
@property (nonatomic, strong) ViewPhotoVC *nextPhoto;
@property (nonatomic) SwipeType swipeType;
@property (nonatomic, strong) UILabel *yumIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;
@property (nonatomic) NSUInteger toTryListID;
@property (nonatomic, strong) OOFeedbackView *fv;
@property (nonatomic, strong) UIScrollView *backgroundView;
@property (nonatomic, strong) UIButton *share;
@property (nonatomic, strong) UIButton *commentCaptionButton;
@property (nonatomic, strong) UIButton *yumButton;
@property (nonatomic, strong) UIButton *seeCommentsButton;
@property (nonatomic, strong) UIButton *seeYummersButton;
@property (nonatomic, strong) UILabel *mioDateCreated;
@property (nonatomic, strong) UILabel *numYumsLabel;
@property (nonatomic, strong) UILabel *numCommentsLabel;
@property (nonatomic, strong) CommentPhotoView *commentPhotoView;
@property (nonatomic, strong) CommentPhotoView *secondCommentView;
@property (nonatomic, strong) NSMutableArray *commentsButtonArray;

#pragma testing NewLayout properties

@property (nonatomic, strong) NSMutableArray *dummyCommentsArray;


@end

static CGFloat kDismissTolerance = 20;
static CGFloat kNextPhotoTolerance = 40;

@implementation ViewPhotoVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundView = [[UIScrollView alloc] init];
        _backgroundView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        _backgroundView.alpha = kAlphaBackground;
        //[_backgroundView setBounces:NO];
        
        _iv = [[UIImageView alloc] init];
        _iv.contentMode = UIViewContentModeScaleAspectFit;
        _iv.backgroundColor = UIColorRGBA(kColorClear);
        
        _aiv = [UIActivityIndicatorView new];
        _aiv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
        _captionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captionButton withText:@"" fontSize:kGeomFontSizeH3 width:0 height:0 backgroundColor:kColorClear textColor:kColorText borderColor:kColorClear target:nil selector:nil];
        _captionButton.titleLabel.numberOfLines = 0;
        _captionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _captionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_captionButton setTitleShadowColor:UIColorRGBA(kColorBackgroundTheme) forState:UIControlStateNormal];
        [_captionButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.4)];
        
        _yumIndicator = [[UILabel alloc] init];
        [_yumIndicator withFont:[UIFont fontWithName:kFontIcons size:90] textColor:kColorBackgroundTheme backgroundColor:kColorClear];
        _yumIndicator.text = kFontIconYum;
        [_yumIndicator sizeToFit];
        _yumIndicator.alpha = 0;
        [Common addShadowTo:_yumIndicator withColor:kColorWhite];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton withIcon:kFontIconRemove fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:kGeomHeightButton backgroundColor:kColorClear target:self selector:@selector(close)];
        [_closeButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];

        _optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_optionsButton withIcon:kFontIconMoreSolid fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:kGeomHeightButton backgroundColor:kColorClear target:self selector:@selector(showOptions:)];
        [_optionsButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        
        _restaurantButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_restaurantButton withText:@"" fontSize:kGeomFontSizeH1 width:10 height:10 backgroundColor:kColorTextActive textColor:kColorTextReverse borderColor:kColorClear target:self selector:@selector(showRestaurant)];
        _restaurantButton.titleLabel.numberOfLines = 0;
        [_restaurantButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.4)];
        _restaurantButton.layer.cornerRadius = 0;
        
        _restaurantName = [UILabel new];
        [_restaurantName withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH1] textColor:kColorTextReverse backgroundColor:kColorTextActive numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        [_restaurantButton addSubview:_restaurantName];
        
        _subheader = [UILabel new];
        [_subheader withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4] textColor:kColorTextReverse backgroundColor:kColorTextActive numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        [_restaurantButton addSubview:_subheader];
        
//        _showRestaurantTapGesture = [[UITapGestureRecognizer alloc] init];
        _yumPhotoTapGesture = [[UITapGestureRecognizer alloc] init];
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    
        _userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userButton withText:@"" fontSize:kGeomFontSizeSubheader width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(showProfile)];
        [_userButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        _userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_userButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        _userButton.titleLabel.shadowColor = UIColorRGBA(kColorBackgroundTheme);

        _userViewButton = [[OOUserView alloc] init];
        
        _fv = [[OOFeedbackView alloc] initWithFrame:CGRectMake(0, 0, 110, 90) andMessage:@"oy vey" andIcon:kFontIconCheckmark];
        
        _commentCaptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UILabel *iconCaptionLabel = [UILabel new];
        [iconCaptionLabel setBackgroundColor:UIColorRGBA(kColorClear)];
        iconCaptionLabel.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
        iconCaptionLabel.text = kFontIconCaption;
        iconCaptionLabel.textColor = UIColorRGBA(kColorTextActive);
        [iconCaptionLabel sizeToFit];
        UIImage *iconCaption = [UIImage imageFromView:iconCaptionLabel];
        [_commentCaptionButton withText:@"" fontSize:kGeomFontSizeH1 width:0 height:0 backgroundColor:kColorButtonBackground textColor:kColorTextActive borderColor:kColorButtonBackground target:self selector:@selector(showComments)];
        [_commentCaptionButton setImage:iconCaption forState:UIControlStateNormal];
        _commentCaptionButton.layer.cornerRadius = 0;
        _numCommentsLabel = [UILabel new];
        [_numCommentsLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorTextActive backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentRight];
        [_commentCaptionButton addSubview:_numCommentsLabel];
        
        _mioDateCreated = [UILabel new];
        [_mioDateCreated withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorGrayMiddle backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter];
        
        _share = [UIButton buttonWithType:UIButtonTypeCustom];
        UILabel *iconLabel = [UILabel new];
        [iconLabel setBackgroundColor:UIColorRGBA(kColorClear)];
        iconLabel.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
        iconLabel.text = kFontIconShare;
        iconLabel.textColor = UIColorRGBA(kColorTextActive);
        [iconLabel sizeToFit];
        UIImage *icon = [UIImage imageFromView:iconLabel];
        [_share withText:@"" fontSize:kGeomFontSizeH1 width:0 height:0 backgroundColor:kColorButtonBackground textColor:kColorTextActive borderColor:kColorButtonBackground target:self selector:@selector(sharePressed:)];
        [_share setImage:icon forState:UIControlStateNormal];
        _share.layer.cornerRadius = 0;
        
        _yumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UILabel *iconLabelYum = [UILabel new];
        [iconLabelYum setBackgroundColor:UIColorRGBA(kColorClear)];
        iconLabelYum.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
        iconLabelYum.text = kFontIconYumOutline;
        iconLabelYum.textColor = UIColorRGBA(kColorTextActive);
        [iconLabelYum sizeToFit];
        UIImage *iconYum = [UIImage imageFromView:iconLabelYum];
        UILabel *iconLabelYumSelected = [UILabel new];
        [iconLabelYumSelected setBackgroundColor:UIColorRGBA(kColorClear)];
        iconLabelYumSelected.font = [UIFont fontWithName:kFontIcons size:kGeomIconSize];
        iconLabelYumSelected.text = kFontIconYum;
        iconLabelYumSelected.textColor = UIColorRGBA(kColorTextActive);
        [iconLabelYumSelected sizeToFit];
        UIImage *iconYumSelected = [UIImage imageFromView:iconLabelYumSelected];
        
        [_yumButton withText:@"" fontSize:kGeomFontSizeH1 width:0 height:0 backgroundColor:kColorButtonBackground textColor:kColorTextActive borderColor:kColorButtonBackground target:self selector:@selector(yumPhotoTapped)];
        [_yumButton setImage:iconYum forState:UIControlStateNormal];
        [_yumButton setImage:iconYumSelected   forState:UIControlStateSelected];
        _yumButton.layer.cornerRadius = 0;
        _numYumsLabel = [UILabel new];
        [_numYumsLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorTextActive backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentRight];
        [_yumButton addSubview:_numYumsLabel];
    
        _seeCommentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seeCommentsButton withText:@"see comments" fontSize:kGeomFontSizeSubheader width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(showComments)];
        [_seeCommentsButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        _seeCommentsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_seeCommentsButton setTitleColor:UIColorRGBA(kColorGrayMiddle) forState:UIControlStateNormal];
        _seeCommentsButton.titleLabel.shadowColor = UIColorRGBA(kColorBackgroundTheme);
        
        _seeYummersButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seeYummersButton withText:@"see yummers" fontSize:kGeomFontSizeSubheader width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(showYums)];
        [_seeYummersButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        _seeYummersButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_seeYummersButton setTitleColor:UIColorRGBA(kColorGrayMiddle) forState:UIControlStateNormal];
        _seeYummersButton.titleLabel.shadowColor = UIColorRGBA(kColorBackgroundTheme);
        
        _commentsButtonArray = [NSMutableArray new];
        CommentPhotoView *cPV;
        for (int i = 0; i <5; i++) {
            cPV = [CommentPhotoView new];
            [_commentsButtonArray addObject:cPV];
        }

         //        [DebugUtilities addBorderToViews:@[self.view]];
        [DebugUtilities addBorderToViews:@[_closeButton, _optionsButton, _restaurantName, _iv, _yumButton, _userButton, _userViewButton, _captionButton, _mioDateCreated, _seeYummersButton, _seeCommentsButton, _share , _commentCaptionButton]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_iv addSubview:_aiv];
    [self.backgroundView addSubview:_fv];
    [self.backgroundView addSubview:_yumIndicator];
    [self.backgroundView addSubview:_iv];
    [self.backgroundView addSubview:_restaurantButton];
    [self.backgroundView addSubview:_closeButton];
    [self.backgroundView addSubview:_captionButton];
    [self.backgroundView addSubview:_userButton];
    [self.backgroundView addSubview:_userViewButton];
    [self.backgroundView addSubview:_commentCaptionButton];
    [self.backgroundView addSubview:_share];
    [self.backgroundView addSubview:_seeCommentsButton];
    [self.backgroundView addSubview:_seeYummersButton];
    [self.backgroundView addSubview:_mioDateCreated];
    [self.view addSubview:_backgroundView];
    [self.backgroundView bringSubviewToFront:_fv];
    [self.backgroundView bringSubviewToFront:_yumIndicator];
    [self.backgroundView sendSubviewToBack:_backgroundView];
    [self.backgroundView addSubview:_yumButton];
    for (CommentPhotoView *cPV in _commentsButtonArray) {
        [self.backgroundView addSubview:cPV];
    }

    NSLog(@"the amount of items in the array is %lu", _commentsButtonArray.count);
    [self.view setAutoresizesSubviews:NO];
    
    //    [_showRestaurantTapGesture addTarget:self action:@selector(tapGestureRecognized:)];
    //    [_showRestaurantTapGesture setNumberOfTapsRequired:1];
    [_yumPhotoTapGesture addTarget:self action:@selector(tapGestureRecognized:)];
    [_yumPhotoTapGesture setNumberOfTapsRequired:2];
    
    //    [_showRestaurantTapGesture requireGestureRecognizerToFail:_yumPhotoTapGesture];
    //    [_backgroundView addGestureRecognizer:_showRestaurantTapGesture];
    [_backgroundView addGestureRecognizer:_yumPhotoTapGesture];
    [self.view addGestureRecognizer:_panGesture];
    
    //    [DebugUtilities addBorderToViews:@[self.view]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (!_mio) return;
    
    self.view.frame = APP.window.bounds;
    CGFloat w = width(self.view);
    //CGFloat h = height(self.view);
    CGRect frame;
    CGFloat y;
    
    _backgroundView.frame = self.view.frame;
    
    frame = _iv.frame;
    
    CGFloat imageWidth = width(self.view);
    
    CGFloat imageHeight = (imageWidth < width(self.view)) ? height(_iv) : _mio.height/_mio.width * width(self.view);
    
    frame.size.width = imageWidth;
    frame.size.height = imageHeight;
    _iv.frame = CGRectIntegral(frame);
    _iv.center = self.view.center;
    _aiv.center = CGPointMake(CGRectGetWidth(_iv.frame)/2, CGRectGetHeight(_iv.frame)/2);
    
    y = CGRectGetMidY(self.view.frame) - imageHeight/2 - kGeomDimensionsIconButton;
    
    frame = _closeButton.frame;
    frame.origin = CGPointMake(0, 0);
    _closeButton.frame = frame;
    
    y = (y < CGRectGetMaxY(_closeButton.frame)) ? CGRectGetMaxY(_closeButton.frame) : y;
    frame = _restaurantButton.frame;
    frame.size.width = w;//-2*kGeomSpaceEdge;
    frame.origin.y = CGRectGetMaxY(_closeButton.frame);// y;
    frame.origin.x = 0;//(width(self.view) - width(_restaurantButton))/2;
    frame.size.height = kGeomHeightButton;
    _restaurantButton.frame = frame;
    
    frame = _restaurantName.frame;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(_restaurantButton.frame) - 2*kGeomSpaceEdge;
    _restaurantName.frame = frame;
    
    frame = _subheader.frame;
    frame.origin.y = CGRectGetMaxY(_restaurantName.frame) + kGeomSpaceInter;
    frame.size.width = CGRectGetWidth(_restaurantButton.frame) - 2*kGeomSpaceEdge;
    _subheader.frame = frame;
    
    _iv.frame = CGRectMake(0, CGRectGetMaxY(_restaurantButton.frame) /*+ kGeomSpaceInter*/, imageWidth, imageHeight);
    
    _yumIndicator.center = _iv.center;
    
    frame = _optionsButton.frame;
    frame.origin = CGPointMake(width(self.view)-width(_optionsButton), 0);
    _optionsButton.frame = frame;
    
    frame = _userViewButton.frame;
    frame.origin.x = kGeomSpaceEdge;
    frame.size.height = (_mio.source == kMediaItemTypeOomami) ? kGeomDimensionsIconButton : 0;
    frame.size.width = kGeomDimensionsIconButton;
    frame.origin.y = CGRectGetMaxY(_iv.frame) + kGeomSpaceInter;
    _userViewButton.frame = frame;
    
    frame = _userButton.frame;
    frame.origin.y = CGRectGetMaxY(_userViewButton.frame);
    frame.origin.x = kGeomSpaceEdge;
    frame.size.height = (_mio.source == kMediaItemTypeOomami) ? kGeomDimensionsIconButton : 0;
    _userButton.frame = frame;
    
//    if (_mio.source == kMediaItemTypeOomami) {
//        [_numYums sizeToFit];
//        
//        frame = _yumButton.frame;
//        frame.size = CGSizeMake(kGeomDimensionsIconButton, kGeomDimensionsIconButton);
//        frame.origin = CGPointMake(width(self.view) - kGeomDimensionsIconButton - kGeomSpaceEdge, CGRectGetMaxY(_iv.frame)+kGeomSpaceInter);
//        _yumButton.frame = frame;
//        
//        frame = _numYums.frame;
//        frame.origin = CGPointMake(width(self.view) - width(_numYums) - kGeomSpaceEdge, CGRectGetMaxY(_yumButton.frame));
//        frame.size.height = kGeomDimensionsIconButton;
//        _numYums.frame = frame;
//        _numYums.center = CGPointMake(_yumButton.center.x, _numYums.center.y);
//    } else {
//        _yumButton.frame = CGRectZero;
//        _numYums.frame = CGRectZero;
//    }
    
    frame = _mioDateCreated.frame;
    frame.size.height = kGeomDimensionsIconButton;
    CGFloat w2 = [_mioDateCreated sizeThatFits:CGSizeMake(0, frame.size.height)].width;
    frame.size.width = (kGeomDimensionsIconButton > w2) ? kGeomDimensionsIconButton : w2;
    frame.origin = CGPointMake(CGRectGetMaxX(self.view.bounds) - kGeomDimensionsIconButton - kGeomSpaceEdge * 2, CGRectGetMaxY(_iv.frame) + kGeomSpaceInter);
    _mioDateCreated.frame = frame;
    
    CGFloat height;
    frame = _captionButton.frame;
    frame.size.width = CGRectGetMinX(_mioDateCreated.frame) - CGRectGetMaxX(_userViewButton.frame);
    height = [_captionButton.titleLabel sizeThatFits:CGSizeMake(frame.size.width, 200)].height;
    frame.size.height = (kGeomHeightButton > height) ? kGeomHeightButton : height;
    frame.origin.y = CGRectGetMinY(_userViewButton.frame) + (CGRectGetHeight(_userViewButton.frame) - frame.size.height)/2;
    frame.origin.x = (width(self.view) - frame.size.width)/2;
    _captionButton.frame = frame;
    
    _fv.center = self.view.center;
    
    CGFloat buttonWidth = (w - (kGeomSpaceInter*2))/3;
    
    //horizontal 3 buttons section
    _commentCaptionButton.frame = CGRectMake(0, CGRectGetMaxY(_userButton.frame), buttonWidth, kGeomHeightButton);
    frame = _numCommentsLabel.frame;
    frame.size.width = kGeomDimensionsIconButton;
    frame.size.height = kGeomDimensionsIconButton;
    frame.origin.y = _commentCaptionButton.frame.size.height - _numCommentsLabel.frame.size.height + kGeomSpaceEdge;
    frame.origin.x = width(_commentCaptionButton)  - width(_numCommentsLabel) - kGeomSpaceEdge;
    _numCommentsLabel.frame = frame;
    _numCommentsLabel.text = @"2";
    
    _share.frame = CGRectMake(buttonWidth + kGeomSpaceInter, CGRectGetMaxY(_userButton.frame), buttonWidth, kGeomHeightButton);
    
    _yumButton.frame = CGRectMake((buttonWidth + kGeomSpaceInter) *2, CGRectGetMaxY(_userButton.frame),buttonWidth, kGeomHeightButton);
    frame = _numYumsLabel.frame;
    frame.size.width = kGeomDimensionsIconButton;
    frame.size.height = kGeomDimensionsIconButton;
    frame.origin.y =  _yumButton.frame.size.height - _numYumsLabel.frame.size.height + kGeomSpaceEdge;
    frame.origin.x = width(_yumButton) - width(_numYumsLabel) - kGeomSpaceEdge;
    _numYumsLabel.frame = frame;

    /////////////////
    _seeCommentsButton.frame = CGRectMake(0, CGRectGetMaxY(_share.frame), buttonWidth, kGeomHeightButton);
    _seeYummersButton.frame = CGRectMake((buttonWidth + kGeomSpaceInter) *2, CGRectGetMaxY(_yumButton.frame), buttonWidth, kGeomHeightButton);
    
    //comments View
    y = CGRectGetMaxY(_seeCommentsButton.frame);
    
    for (CommentPhotoView *v in _commentsButtonArray) {
        frame = v.frame;
        frame.origin.x = 0;
        frame.origin.y = y;
        frame.size.width = self.view.frame.size.width;
        y +=  frame.size.height;
        v.frame = frame;
        NSLog(@"cpv.frame = %@", NSStringFromCGRect(v.frame));
    }
    
    CommentPhotoView *cPV = [_commentsButtonArray lastObject];
    _backgroundView.contentSize = CGSizeMake(width(self.view), CGRectGetMaxY(cPV.frame));
    
}

- (void)initializingDummyComments {
    
    
    NSDictionary *dummyComments = @{kKeyCommentContent : @"comment # 1",
                                    kKeyCommentMediaItemID : @"userMediaItem",
                                    kKeyCommentMediaItemCommentID : @"mediaItemId",
                                    kKeyCommentUserID : @"user Id1"
                                    };
    
    NSDictionary *dummyComments1 = @{kKeyCommentContent : @"comment # 2",
                                     kKeyCommentMediaItemID : @"userMediaItem",
                                     kKeyCommentMediaItemCommentID : @"mediaItemId",
                                     kKeyCommentUserID : @"user Id2"
                                     };
    NSDictionary *dummyComments2 = @{kKeyCommentContent : @"comment # 3",
                                     kKeyCommentMediaItemID : @"userMediaItem",
                                     kKeyCommentMediaItemCommentID : @"mediaItemId",
                                     kKeyCommentUserID : @"user Id3"
                                     };
    NSDictionary *dummyComments3 = @{kKeyCommentContent : @"comment # 4",
                                     kKeyCommentMediaItemID : @"userMediaItem",
                                     kKeyCommentMediaItemCommentID : @"mediaItemId",
                                     kKeyCommentUserID : @"user Id4"
                                     };
    NSDictionary *dummyComments4 = @{kKeyCommentContent : @"comment # 5",
                                     kKeyCommentMediaItemID : @"userMediaItem",
                                     kKeyCommentMediaItemCommentID : @"mediaItemId",
                                     kKeyCommentUserID : @"user Id5"
                                     };
    
    NSArray *arrayOfDummyCommentDicts = @[dummyComments, dummyComments1, dummyComments2, dummyComments3, dummyComments4];
    _dummyCommentsArray = [NSMutableArray new];
    
    for (NSDictionary *dummyCommentDict in arrayOfDummyCommentDicts) {
        CommentObject *comment = [CommentObject commentFromDict:dummyCommentDict];
        NSLog(@"the comment content is %@", comment.content);
        [_dummyCommentsArray addObject:comment];
    }
    NSLog(@"the count is %lu", self.dummyCommentsArray.count);
    
}

- (void)showComponents:(BOOL)show {
    _share.hidden =
    _optionsButton.hidden =
    _closeButton.hidden =
    _captionButton.hidden =
    _restaurantButton.hidden =
    _yumButton.hidden =
    _commentCaptionButton.hidden =
    _userButton.hidden =
    _seeCommentsButton.hidden =
    _seeYummersButton .hidden =
    _mioDateCreated.hidden =
    _userViewButton.hidden = !show;
    
    if (show) {
        if (_numYumsLabel) {
            _numYumsLabel.hidden = NO;
        } else {
            _numYumsLabel.hidden = YES;
        }
    } else {
        _numYumsLabel.hidden = YES;
    }
    
    for (CommentPhotoView *cPV in _commentsButtonArray) {
        cPV.hidden = !show;
    }
}

- (void)setComponentsAlpha:(CGFloat)alpha {
    _share.alpha =
    _optionsButton.alpha =
    _closeButton.alpha =
    _captionButton.alpha =
    _restaurantButton.alpha =
    _yumButton.hidden =
    _commentCaptionButton.hidden =
    _userButton.alpha =
    _mioDateCreated.alpha =
    _seeCommentsButton.hidden =
    _seeYummersButton .hidden = 
    _userViewButton.alpha =
    _numYumsLabel.alpha =
    _iv.alpha =
    alpha;
    
    for (CommentPhotoView *cPV in _commentsButtonArray) {
        cPV.alpha = alpha;
    }
}


#pragma end of layout james

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIImage *)shareImage {
    UIView *shareView = [UIView new];
    //shareView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    CGRect frame;
    UIImageView *iv = [UIImageView new];
    iv.frame = _iv.bounds;
    iv.image = _iv.image;
    
    if (_mio.source == kMediaItemTypeOomami) {
        UILabel *logo = [UILabel new];
        [logo withFont:[UIFont fontWithName:kFontIcons size:80] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentRight];
        logo.text = kFontIconLogoFull;
        [logo sizeToFit];
        frame = logo.frame;
        frame.size.width = CGRectGetWidth(iv.frame)-16;
        frame.origin = CGPointMake(0, height(iv) - height(logo) + 20);
        logo.frame = frame;
        [iv addSubview:logo];
        //[DebugUtilities addBorderToViews:@[logo]];
    }
    
    [shareView addSubview:iv];
    
    frame = iv.bounds;
    shareView.frame = frame;
    
    [shareView setNeedsLayout];
    
    return [UIImage imageFromView:shareView];
}

-(void)showOptions:(id)sender {
    UIAlertController *photoOptions = [UIAlertController alertControllerWithTitle:@"" message:@"What would you like to do?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    photoOptions.popoverPresentationController.sourceView = sender;
    photoOptions.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
    
    UIAlertAction *deletePhoto = [UIAlertAction actionWithTitle:@"Delete Photo"
                                                          style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                                                              __weak ViewPhotoVC *weakSelf = self;
                                                              ON_MAIN_THREAD(^{
                                                                  [weakSelf deletePhoto:_mio];
                                                              });
                                                              
                                                          }];
    UIAlertAction *shareItem = [UIAlertAction actionWithTitle:@"Share Item"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      [self sharePressed:sender];
                                                                  }];
    UIAlertAction *toggleWishlist = [UIAlertAction actionWithTitle:(_toTryListID ? @"Remove from Wishlist": @"Add to Wishlist")
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            [self toggleWishlist:sender];
                                                        }];
    UIAlertAction *addRestaurantToList = [UIAlertAction actionWithTitle:@"Add Restaurant to a List"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                             [self addToList:_restaurant];
                                                         }];
    UIAlertAction *flagPhoto = [UIAlertAction actionWithTitle:@"Flag Photo"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            [self flagPhoto:_mio];
                                                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       NSLog(@"Cancel");
                                                   }];

    UserObject *uo = [Settings sharedInstance].userObject;

    [photoOptions addAction:shareItem];
    [photoOptions addAction:toggleWishlist];
    [photoOptions addAction:addRestaurantToList];
    if (_mio.sourceUserID == uo.userID) {
        [photoOptions addAction:deletePhoto];
    } else {
        [photoOptions addAction:flagPhoto];
    }
    [photoOptions addAction:cancel];
    
    __weak ViewPhotoVC *weakSelf = self;
    
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!result) {
            [weakSelf presentUnverifiedMessage:@"You will need to verify your email to do this.\n\nCheck your email for a verification link."];
        } else {
            [weakSelf presentViewController:photoOptions animated:YES completion:^{
                ;
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

- (void)toggleWishlist:(id)sender {    
    OOAPI *api = [[OOAPI alloc] init];
    __weak ViewPhotoVC *weakSelf = self;
    
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!result) {
            [weakSelf presentUnverifiedMessage:@"To add this restaurant to your wishlist list you will need to verify your email.\n\nCheck your email for a verification link."];
        } else {
            if (!weakSelf.toTryListID) {
                _fv.icon = kFontIconCheckmark;
                _fv.message = @"Adding to Wishlist";
                [_fv show];
                [api addRestaurantsToSpecialList:@[weakSelf.restaurant] listType:kListTypeToTry success:^(id response) {
                    [weakSelf getListsForRestaurant];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    ;
                }];
            } else {
                _fv.icon = kFontIconRemove;
                _fv.message = @"Removing from Wishlist";
                [_fv show];
                [api deleteRestaurant:weakSelf.restaurant.restaurantID fromList:weakSelf.toTryListID success:^(NSArray *lists) {
                    [weakSelf getListsForRestaurant];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    ;
                }];
            }
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

- (void)getListsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak ViewPhotoVC *weakSelf = self;
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    [api getListsOfUser:user.userID
         withRestaurant:_restaurant.restaurantID
             includeAll:YES
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user:  %ld", ( long) foundLists.count);
                    weakSelf.toTryListID = 0;
                    [foundLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        ListObject *lo = (ListObject *)obj;
                        if (lo.type == kListTypeToTry) {
                            weakSelf.toTryListID = lo.listID;
                            *stop = YES;
                        }
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                    });
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                    NSLog  (@" error while getting lists for user:  %@",e);
                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                    });
                }];
}

- (void)deletePhoto:(MediaItemObject *)mio {
    NSUInteger userID = [Settings sharedInstance].userObject.userID;
    __weak ViewPhotoVC *weakSelf = self;
    
    if (mio.sourceUserID == userID) {
        [OOAPI deletePhoto:mio success:^{
            [weakSelf close];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFoodFeedNeedsUpdate object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPhotoDeleted object:mio];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
}

- (void)sharePressed:(id)sender {
    UIImage *img = [self shareImage];
    [FBSDKAppEvents logEvent:kAppEventSharePressed
                  parameters:@{kAppEventParameterValueItem:kAppEventParameterValueItem}];
    
    __weak ViewPhotoVC *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf showShare:img fromView:sender];
    });
}

- (void)showShare:(UIImage *)image fromView:(id)sender {
    NSMutableArray *items = [NSMutableArray array];
    
    OOActivityItemProvider *aip = [[OOActivityItemProvider alloc] initWithPlaceholderItem:@"Yum!"];
    aip.restaurant = _restaurant;
    [items addObject:aip];
    
    OOActivityItemProvider *aipImage = [[OOActivityItemProvider alloc] initWithPlaceholderItem:@""];
    aipImage.image = image;
    [items addObject:aipImage];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    avc.popoverPresentationController.sourceView = sender;
    avc.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
    
    if (_mio) {
        [avc setValue:[NSString stringWithFormat:@"Saw this at %@ and thought you'd like it.", _restaurant.name] forKey:@"subject"];
    } else {
        [avc setValue:[NSString stringWithFormat:@"We should go to %@", _restaurant.name] forKey:@"subject"];
    }
    [avc setExcludedActivityTypes:
     @[UIActivityTypeAssignToContact,
       UIActivityTypePostToFlickr,
       UIActivityTypeCopyToPasteboard,
       UIActivityTypePrint,
       UIActivityTypeSaveToCameraRoll,
       UIActivityTypePostToWeibo]];

    [self.navigationController presentViewController:avc animated:YES completion:^{
        ;
    }];
    
    
    avc.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
    };
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {

    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentTitle = @"F-Spot";
        content.contentDescription = [NSString stringWithFormat:@"%@  %@", @"arg1", @"arg2"];
        [content setValue:@{@"caption":@"?"} forKey:@"feedParameters"];
        //content.imageURL = [NSURL URLWithString:shareImage];
        content.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/restaurant//%lu", kWebAppHost, (unsigned long)_restaurant.restaurantID]];
//        FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
//        shareDialog.mode = FBSDKShareDialogModeNative;
//        if(shareDialog.canShow) {
//            shareDialog.mode = FBSDKShareDialogModeFeedBrowser;
//        }
//        shareDialog.shareContent = content;
//        shareDialog.delegate = self;
//
//        [shareDialog show];
        return content;
    }
    return nil;
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    
}

- (void)flagPhoto:(MediaItemObject *)mio {
    [OOAPI flagMediaItem:mio.mediaItemId success:^(NSArray *names) {
        NSLog(@"photo flagged: %lu", (unsigned long)mio.mediaItemId);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"could not flag the photo: %@", error);
    }];
}

- (void)addToList:(RestaurantObject *)restaurant {
    ListsVC *vc = [[ListsVC alloc] init];
    vc.restaurantToAdd = restaurant;
    [vc getLists];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addCaption {
    _aNC = [[UINavigationController alloc] init];

    AddCaptionToMIOVC *vc = [[AddCaptionToMIOVC alloc] init];
    vc.delegate = self;
    vc.view.frame = CGRectMake(0, 0, 40, 44);
    _mio.restaurantID = _restaurant.restaurantID; //this is a 
    vc.mio = _mio;

    [_aNC addChildViewController:vc];
    [_aNC.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorBlack)] forBarMetrics:UIBarMetricsDefault];
    [_aNC.navigationBar setTranslucent:YES];
    _aNC.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController presentViewController:_aNC animated:YES completion:^{
        _aNC.topViewController.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }];
}

- (void)textEntryFinished:(NSString *)text {
    _mio.caption = text;
    [_captionButton setTitle:text forState:UIControlStateNormal];
    [self.view setNeedsLayout];

    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)tapGestureRecognized:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)gesture;
        if (tapGesture.state == UIGestureRecognizerStateEnded) {
//            if (tapGesture == _showRestaurantTapGesture) {
//                [self showRestaurant];
//            } else if (tapGesture == _yumPhotoTapGesture) {
                [self yumPhotoTapped];
//            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self.view];
    CGRect frame = _userViewButton.frame;
    if (CGRectContainsPoint(frame, location))
        return NO;
    return YES;
}

- (void)showRestaurant {
    if ([_delegate respondsToSelector:@selector(viewPhotoVC:showRestaurant:)]) {
        [_delegate viewPhotoVC:self showRestaurant:_restaurant];
    }
}


- (void)showProfile {
    if ([_delegate respondsToSelector:@selector(viewPhotoVC:showProfile:)]) {
        [_delegate viewPhotoVC:self showProfile:_user];
    }
}

- (void)oOUserViewTapped:(OOUserView *)userView forUser:(UserObject *)user {
    [self showProfile];
}

- (void)showYums {
    UserListVC *vc = [[UserListVC alloc] init];
    vc.desiredTitle = @"Yummers";
    vc.user = _user;
    
    __weak UserListVC *weakVC = vc;
    
    [vc.view bringSubviewToFront:vc.aiv];
    [vc.aiv startAnimating];
    
    [self.navigationController pushViewController:vc animated:YES];
    [OOAPI getMediaItemYummers:_mio success:^(NSArray *users) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakVC.usersArray = users.mutableCopy;
            [weakVC.aiv stopAnimating];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakVC.aiv stopAnimating];
    }];
}

- (void)showComments {
    CommentListVC *vc = [[CommentListVC alloc] init];
    vc.desiredTitle = @"Comments";
    vc.user = _user;
    
    __weak CommentListVC *weakVC = vc;
    
    [vc.view bringSubviewToFront:vc.aiv];
    [vc.aiv startAnimating];
    
    [self.navigationController pushViewController:vc animated:YES];
    [OOAPI getMediaItemYummers:_mio success:^(NSArray *users) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakVC.usersArray = users.mutableCopy;
            [weakVC.aiv stopAnimating];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakVC.aiv stopAnimating];
    }];
}


- (void)close {
    if ([_delegate respondsToSelector:@selector(viewPhotoVCClosed:)]) {
        [_delegate viewPhotoVCClosed:self];
    }
    
    _direction = 0;
    _nextPhoto = nil;
    self.transitioningDelegate = _dismissTransitionDelegate;
    self.navigationController.delegate = _dismissNCDelegate;
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)pan:(UIGestureRecognizer *)gestureRecognizer {
    if (_panGesture != gestureRecognizer) return;

    if (_panGesture.state == UIGestureRecognizerStateBegan) {
        _swipeType = kSwipeTypeNone;
        CGPoint delta = CGPointMake([_panGesture translationInView:self.view].x, [_panGesture translationInView:self.view].y);
        
//        _interactiveController = [[UIPercentDrivenInteractiveTransition alloc] init];
        
        NSLog(@"began: %@", NSStringFromCGPoint(delta));
        _originPoint = CGPointMake([_panGesture locationInView:self.view].x, [_panGesture locationInView:self.view].y);
        
    } else if (_panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = CGPointMake([_panGesture translationInView:self.view].x, [_panGesture translationInView:self.view].y);
        
        delta.x = ([_items count] > 1)? delta.x:0;
 
//        NSLog(@"changed: %@", NSStringFromCGPoint(delta));

        //if (_swipeType == kSwipeTypeDismiss) {
            _iv.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, delta.x, delta.y);
        //}
        if (_swipeType == kSwipeTypeNone &&
            fabs(delta.y) > kDismissTolerance) {
            _swipeType = kSwipeTypeDismiss;
            [self.interactiveController cancelInteractiveTransition];
            self.interactiveController = nil;
        } else if (_swipeType != kSwipeTypeDismiss && delta.x > 55) {
//            NSLog(@"show next photo? %f", delta.x);
            if (!_nextPhoto && _nextPhoto.direction != 1) {
                _swipeType = kSwipeTypeNextPhoto;
                NSLog(@"get next photo in direction 1");
                [self.interactiveController cancelInteractiveTransition];
                if (_nextPhoto) [_nextPhoto.interactiveController cancelInteractiveTransition];
                _direction = 1;
                _nextPhoto = [self getNextVC:_direction];
                
                self.transitioningDelegate = self;
                self.navigationController.delegate = self;
                
                [self.navigationController pushViewController:_nextPhoto animated:YES];
            }
        } else if (_swipeType != kSwipeTypeDismiss && delta.x < -55) {
//            NSLog(@"show next photo? %f", delta.x);
            if (!_nextPhoto && _nextPhoto.direction != -1) {
                _swipeType = kSwipeTypeNextPhoto;
                NSLog(@"get next photo in direction -1");
                [self.interactiveController cancelInteractiveTransition];
                if (_nextPhoto) [_nextPhoto.interactiveController cancelInteractiveTransition];
                _direction = -1;
                _nextPhoto = [self getNextVC:_direction];
                
                self.transitioningDelegate = self;
                self.navigationController.delegate = self;
                
                [self.navigationController pushViewController:_nextPhoto animated:YES];
            }
        }
        
        [self.interactiveController updateInteractiveTransition:fabs(delta.x/width(self.view))];

    } else if (_panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint delta = CGPointMake([_panGesture translationInView:self.view].x, [_panGesture translationInView:self.view].y);

        NSLog(@"changed: %@ %f %f %f", NSStringFromCGPoint(delta), width(self.view), fabs(delta.x)/width(self.view), self.interactiveController.percentComplete);
        
        if (_swipeType == kSwipeTypeDismiss &&
            fabs(delta.y) > kDismissTolerance) {
            NSLog(@"dismiss photo");
//            [self.interactiveController finishInteractiveTransition];
//            _iv.transform = CGAffineTransformIdentity;
            [self close];
        } else if (_swipeType == kSwipeTypeNextPhoto &&
                   fabs(delta.x) > kNextPhotoTolerance) {
            NSLog(@"show next photo confirmed");
            [self.interactiveController finishInteractiveTransition];
        } else {
            NSLog(@"cancel transition");
            [self.interactiveController cancelInteractiveTransition];
            [UIView animateWithDuration:0.3 animations:^{
                _iv.transform = CGAffineTransformIdentity;;
            }];
            _direction = 0;
            _nextPhoto = nil;
        }
        self.interactiveController = nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([toVC isKindOfClass:[ViewPhotoVC class]] && operation == UINavigationControllerOperationPush) {
        ViewPhotoVC *vc = (ViewPhotoVC *)toVC;
        ShowMediaItemAnimator *animator = [[ShowMediaItemAnimator alloc] init];
        animator.presenting = YES;
        animator.originRect = vc.originRect;
        animator.duration = 0.35;
        animationController = animator;
    } else if ([fromVC isKindOfClass:[ViewPhotoVC class]] && operation == UINavigationControllerOperationPop) {
        ShowMediaItemAnimator *animator = [[ShowMediaItemAnimator alloc] init];
        ViewPhotoVC *vc = (ViewPhotoVC *)fromVC;
        animator.presenting = NO;
        animator.originRect = vc.originRect;
        animator.duration = 0.35;
        animationController = animator;
    } else {
        NSLog(@"*** operation=%ld, fromVC=%@ , toVC=%@", (long)operation, [fromVC class], [toVC class]);
    }
    
    return animationController;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController*)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactiveController;
}

- (ViewPhotoVC *)getNextVC:(NSUInteger)direction {
    NSInteger nextIndex = _currentIndex + (-direction);
    NSLog(@"currentIndex=%ld nextIndex=%ld", (long)_currentIndex, (long)nextIndex);
    
    if (nextIndex < 0 || nextIndex >= [_items count]) return nil;
    
    self.direction = direction;
    
    ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];
    
    __weak ViewPhotoVC *weakSelf = self;
    
    RestaurantObject *r;
    id object = [_items objectAtIndex:nextIndex];
    if ([object isKindOfClass:[RestaurantObject class]]) {
        r = (RestaurantObject *)object;
        MediaItemObject *mio = ([r.mediaItems count]) ? [r.mediaItems objectAtIndex:0] : nil;
        [self setUpNextVC:vc restaurant:r mediaItem:mio direction:direction nextIndex:nextIndex];
        return vc;
    } else if ([object isKindOfClass:[MediaItemObject class]]) {
        MediaItemObject *m = (MediaItemObject *)object;
        if (m.restaurantID == _restaurant.restaurantID) {
            r = _restaurant;
            [self setUpNextVC:vc restaurant:r mediaItem:m direction:direction nextIndex:nextIndex];
            return vc;
        } else {
            [weakSelf setUpNextVC:vc restaurant:nil mediaItem:m direction:direction nextIndex:nextIndex];
            [OOAPI getRestaurantWithID:m.restaurantID success:^(RestaurantObject *restaurant) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    vc.restaurant = restaurant;
                    [vc.view setNeedsLayout];
                });
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ;
            }];
        }
    }

    return vc;
}
             
- (ViewPhotoVC *)setUpNextVC:(ViewPhotoVC *)vc restaurant:(RestaurantObject *)restaurant mediaItem:(MediaItemObject *)mio direction:(NSInteger)direction nextIndex:(NSUInteger)nextIndex {
    
    vc.originRect = CGRectMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame), 20, 20);
    vc.mio = mio;
    vc.restaurant = restaurant;
    vc.direction = direction;
    vc.delegate = _delegate;
    vc.items = _items;
    vc.currentIndex = nextIndex;
    
    //vc.rootViewController = _rootViewController;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    vc.navigationController.delegate = self;
    
    vc.dismissNCDelegate = _dismissNCDelegate;
    vc.dismissTransitionDelegate = _dismissTransitionDelegate;
    
    return vc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN(@(object_getClassName(self)));
    
    _userViewButton.delegate = self;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.tabBarController.tabBar.hidden = YES;
    
    [self.view bringSubviewToFront:_fv];
    
//    _backgroundView.alpha = kAlphaBackground;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getListsForRestaurant];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (restaurant == _restaurant) return;

    _restaurant = restaurant;
    if (_restaurant) {
        _restaurantName.text =_restaurant.name;
    } else {
        _restaurantName.text = @"NO RESTAURANT";
    }
    
    [_restaurantName sizeToFit];
    _subheader.text = [self subheaderString];
    [_subheader sizeToFit];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (NSString *)subheaderString {
    NSString *s;
    
    NSMutableArray *components = [NSMutableArray array];
    if (_restaurant.cuisine) [components addObject:[NSString stringWithFormat:@"#%@", _restaurant.cuisine]];
    if ([_restaurant distanceOrAddressString]) [components addObject:[_restaurant distanceOrAddressString]];
    
    s = [components componentsJoinedByString:@" - "];
    
    return s;
}


- (void)setMio:(MediaItemObject *)mio {
    if (mio == _mio) return;
    _mio = mio;
    
    if (_mio.source == kMediaItemTypeOomami) {
        [_backgroundView addSubview:_optionsButton];
    } else {
        [_optionsButton removeFromSuperview];
    }
    
    UserObject *user = [Settings sharedInstance].userObject;
    
    //test date
    NSString *mioCreatedAt = [NSString getTimeAgoString:_mio.createdAt];
    _mioDateCreated.text = mioCreatedAt;
    NSLog(@"the date is %@", mioCreatedAt);
    
    if ([_mio.caption length]) {
        [_captionButton setTitle:[NSString stringWithFormat:@"%@ \n%@",_mio.caption, _mio.createdAt] forState:UIControlStateNormal];
        
    } else {
        if (_mio.sourceUserID == user.userID) {
            [_captionButton setTitle:@"+ add caption" forState:UIControlStateNormal];
        }
    }

    if (_mio.sourceUserID == user.userID) {
        [_captionButton addTarget:self action:@selector(addCaption) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_captionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    }

    OOAPI *api = [[OOAPI alloc] init];
    
    __weak UIImageView *weakIV = _iv;
    __weak ViewPhotoVC *weakSelf = self;
    [_aiv startAnimating];
    
    _requestOperation = [api getRestaurantImageWithMediaItem:_mio
                                                    maxWidth:self.view.frame.size.width
                                                   maxHeight:0 success:^(NSString *link) {
                            [weakIV setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [_aiv stopAnimating];
                                                 weakIV.image = image;
                                                 [weakIV setAlpha:1.0];
                                                 [weakSelf.view setNeedsLayout];
                                                 [weakSelf.view layoutIfNeeded];
                                                 NSLog(@"iv got image viewFrame %@", NSStringFromCGRect(weakIV.frame));
                                             });
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             NSLog(@"ERROR: failed to get image: %@", error);
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [_aiv stopAnimating];
                                             });
                                         }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: failed to get image: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_aiv stopAnimating];
        });
    }];
    
    if (_mio.source == kMediaItemTypeOomami) {
        [self updateNumYums];
      
        
        __weak ViewPhotoVC *weakSelf = self;
    
        [OOAPI getMediaItemLiked:_mio.mediaItemId byUser:[Settings sharedInstance].userObject.userID success:^(BOOL liked) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.yumButton setSelected:liked];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.yumButton setSelected:NO];
            });
        }];
        //get the state of the yum button for this user
    }
    
    if (_mio.sourceUserID) {
        __weak ViewPhotoVC *weakSelf = self;
        [OOAPI getUserWithID:_mio.sourceUserID success:^(UserObject *user) {
            _user = user;
            NSString *userName = [NSString stringWithFormat:@"@%@", user.username];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.userViewButton.user = user;
                [weakSelf.userButton setTitle:userName forState:UIControlStateNormal];
                [weakSelf.userButton sizeToFit];
                
                //test
                CommentPhotoView *c = [_commentsButtonArray firstObject];
                c.userNameButton.titleLabel.text = userName;
        
                [weakSelf.view bringSubviewToFront:_userViewButton];
                [weakSelf.view setNeedsLayout];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: failed to get user: %@", error);;
        }];
    }
}


- (void)yumPhotoTapped {
    __weak ViewPhotoVC *weakSelf = self;
    
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!result) {
            [weakSelf presentUnverifiedMessage:@"To yum this photo you will need to verify your email.\n\nCheck your email for a verification link."];
        } else {
            if ( _yumButton.isSelected) {
                NSLog(@"unlike photo");
                NSUInteger userID = [Settings sharedInstance].userObject.userID;
                [OOAPI unsetMediaItemLike:_mio.mediaItemId forUser:userID success:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.yumButton setSelected:NO];
                        [weakSelf updateNumYums];
                        NOTIFY_WITH(kNotificationUserStatsChanged, @(userID));
                        NOTIFY_WITH(kNotificationMediaItemAltered, _mio)
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"ERROR: failed to unlike photo: %@", error);;
                }];
            } else {
                NSLog(@"like photo");
                NSUInteger userID = [Settings sharedInstance].userObject.userID;
                [OOAPI setMediaItemLike:_mio.mediaItemId forUser:userID success:^{
                    [FBSDKAppEvents logEvent:kAppEventPhotoYummed];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.yumIndicator.alpha = 1;
                        [UIView animateKeyframesWithDuration:1.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                            weakSelf.yumIndicator.alpha = 0;
                        } completion:^(BOOL finished) {
                            [weakSelf.yumButton setSelected:YES];
                            [weakSelf updateNumYums];
                        }];
                        
                        NOTIFY_WITH(kNotificationUserStatsChanged, @(userID));
                        NOTIFY_WITH(kNotificationMediaItemAltered, _mio)
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"ERROR: failed to like photo: %@", error);;
                }];
            }
            
            UserObject* myself= [Settings sharedInstance].userObject;
            if (_mio.sourceUserID == myself.userID) {
                // RULE: If I like or unlike my own photo, I will need to update my profile screen.
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOwnProfileNeedsUpdate object:nil];
            }
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
    self.navigationController.delegate = vc;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:vc animated:YES completion:^{
        }];
    });
}

- (void)unverifiedUserVCDismiss:(UnverifiedUserVC *)unverifiedUserVC {
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)updateNumYums {
    __weak ViewPhotoVC *weakSelf = self;
    [OOAPI getNumMediaItemLikes:_mio.mediaItemId success:^(NSUInteger count) {
        if (count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.numYumsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
                [weakSelf.view setNeedsLayout];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                weakSelf.numYumsLabel.hidden = YES;
                [weakSelf.view setNeedsLayout];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view setNeedsLayout];
        });
    }];
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

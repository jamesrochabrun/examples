//
//  ConfirmPhotoVC.m
//  ooApp
//
//  Created by Anuj Gujar on 2/5/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ConfirmPhotoVC.h"
#import "DebugUtilities.h"

@interface ConfirmPhotoVC ()
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) UIButton *usePhoto;
@property (nonatomic, strong) UIButton *getDifferentPhoto;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

static NSString * const cellIdentifier = @"locationCell";

@implementation ConfirmPhotoVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _iv = [UIImageView new];
        _iv.contentMode = UIViewContentModeScaleAspectFit;
//        _iv.translatesAutoresizingMaskIntoConstraints = NO;
        _iv.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        
        _nto = [[NavTitleObject alloc] initWithHeader:@"Confirm Photo" subHeader:@""];
        
        _usePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [_usePhoto withText:@"Use This Photo" fontSize:kGeomFontSizeH2 width:kGeomWidthButton height:kGeomHeightButton backgroundColor:kColorTextActive textColor:kColorTextReverse borderColor:kColorBordersAndLines target:self selector:@selector(usePhoto:)];
//        _usePhoto.translatesAutoresizingMaskIntoConstraints = NO;
        
        _getDifferentPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getDifferentPhoto withText:@"Get Different Photo" fontSize:kGeomFontSizeH2 width:kGeomWidthButton height:kGeomHeightButton backgroundColor:kColorButtonBackground textColor:kColorTextActive borderColor:kColorBordersAndLines target:self selector:@selector(getDifferentPhoto:)];
//        _getDifferentPhoto.translatesAutoresizingMaskIntoConstraints = NO;
    }
//    [DebugUtilities addBorderToViews:@[_iv]];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    [self removeNavButtonForSide:kNavBarSideTypeRight];
    [self addNavButtonWithIcon:@"" target:nil action:nil forSide:kNavBarSideTypeRight isCTA:NO];
    
    [self removeNavButtonForSide:kNavBarSideTypeLeft];
    [self addNavButtonWithIcon:kFontIconRemove target:self action:@selector(getDifferentPhoto:) forSide:kNavBarSideTypeLeft isCTA:NO];

    [self.view addSubview:_iv];
    [self.view addSubview:_usePhoto];
    [self.view addSubview:_getDifferentPhoto];

    self.navTitle = _nto;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN(@(object_getClassName(self)));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)usePhoto:(id)sender {
    [_delegate confirmPhotoVCAccepted:self photoInfo:_photoInfo image:_iv.image];
}

- (void)getDifferentPhoto:(id)sender {
    BOOL getNewPhoto = (sender == _getDifferentPhoto) ? YES:NO;
    [_delegate confirmPhotoVCCancelled:self getNewPhoto:getNewPhoto];
}

//- (void)updateViewConstraints {
//    [super updateViewConstraints];
//    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"mapHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2), @"mapWidth" : @(width(self.view)), @"buttonHeight" : @(kGeomHeightButton)};
//    
//    NSDictionary *views;
//    
//    views = NSDictionaryOfVariableBindings(_iv, _getDifferentPhoto, _usePhoto);
//    
//    // Vertical layout - note the options for aligning the top and bottom of all views
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_iv(375)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_getDifferentPhoto][_usePhoto]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_iv]-(>=0)-[_usePhoto(buttonHeight)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_getDifferentPhoto(buttonHeight)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_usePhoto attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_getDifferentPhoto attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
//}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat w = width(self.view);
    CGFloat h = height(self.view);
    CGRect frame;
    
    frame = _getDifferentPhoto.frame;
    frame.origin.x = 0;
    frame.size.width = w/2;
    frame.origin.y = h - kGeomHeightButton;
    frame.size.height = kGeomHeightButton;
    _getDifferentPhoto.frame = frame;
    
    frame = _usePhoto.frame;
    frame.origin.x = CGRectGetWidth(_getDifferentPhoto.frame);
    frame.size.width = w/2;
    frame.origin.y = h - kGeomHeightButton;
    frame.size.height = kGeomHeightButton;
    _usePhoto.frame = frame;
    
    CGFloat vertical = CGRectGetMinY(_usePhoto.frame), horizontal = w;
    
    frame = _iv.frame;
    if (_iv.image.size.height > _iv.image.size.width) {
        frame.size.width = _iv.image.size.width * vertical/_iv.image.size.height;
        frame.size.height = vertical;
    } else {
        frame.size.height = _iv.image.size.height * horizontal/_iv.image.size.width;
        frame.size.width = horizontal;
    }
    frame.origin.x = (horizontal - frame.size.width)/2;
    frame.origin.y = (vertical - frame.size.height)/2;
    _iv.frame = frame;
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

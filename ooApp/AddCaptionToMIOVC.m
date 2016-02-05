//
//  AddCaptionToMIOVC.m
//  ooApp
//
//  Created by Anuj Gujar on 1/3/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "AddCaptionToMIOVC.h"
#import "OOAPI.h"

@interface AddCaptionToMIOVC ()
@property (nonatomic, strong) UIButton *isFoodButton;
@property (nonatomic, strong) UILabel *isFoodLabel;
@end

@implementation AddCaptionToMIOVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nto = [[NavTitleObject alloc] initWithHeader:@"Add a Caption" subHeader:@""];
    self.navTitle = self.nto;
    
    _isFoodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_isFoodButton withIcon:@"" fontSize:25 width:40 height:40 backgroundColor:kColorOffBlack target:self selector:@selector(toggleIsFoodItem)];
    [_isFoodButton setTitle:kFontIconCheckmark forState:UIControlStateSelected];
    [_isFoodButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
    [_isFoodButton setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorBlack)] forState:UIControlStateSelected];
    [_isFoodButton setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorOffBlack)] forState:UIControlStateNormal];
    _isFoodButton.layer.borderColor = UIColorRGBA(kColorYellow).CGColor;
    _isFoodButton.layer.borderWidth = 1;
    _isFoodButton.layer.cornerRadius = kGeomCornerRadius;
    
    _isFoodLabel = [[UILabel alloc] init];
    [_isFoodLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorWhite backgroundColor:kColorClear];
    _isFoodLabel.text = @"photo of food or drink";
    [_isFoodLabel sizeToFit];
    
    [self.view addSubview:_isFoodLabel];
    [self.view addSubview:_isFoodButton];
    _isFoodLabel.translatesAutoresizingMaskIntoConstraints = _isFoodButton.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)toggleIsFoodItem {
    _mio.isFood = !_mio.isFood;
    _isFoodButton.selected = _mio.isFood;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Use this when a photo is first uploaded (e.g. from F1, R1, P1) to set the default value. Otherwise let
//mio.isFood determine the value of the checkbox
- (void)overrideIsFoodWith:(BOOL)isFood {
    _mio.isFood = isFood;
    _isFoodButton.selected = _mio.isFood;
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    NSDictionary *metrics = @{@"height":@(2*kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonDimensions":@(25)};
    
    UIView *superview = self.view;
    UIView *textEntryBox = self.textView;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _isFoodButton, _isFoodLabel, textEntryBox);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textEntryBox]-spaceEdge-[_isFoodButton(buttonDimensions)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_isFoodButton(buttonDimensions)]-[_isFoodLabel]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_isFoodLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_isFoodButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

}

- (void)post:(UIButton *)sender
{
    __weak AddCaptionToMIOVC *weakSelf = self;
    NSDictionary *properties = @{kKeyMediaItemCaption:[self text],
                                 kKeyMediaItemIsFood:((_mio.isFood)?@1:@0)};
    [OOAPI setMediaItem:_mio.mediaItemId
             properties:properties success:^{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf.delegate textEntryFinished:[self text]];
                 });
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 ;
             }];
}

- (void)setMio:(MediaItemObject *)mio {
    if (_mio == mio) return;
    _mio = mio;
    self.defaultText = mio.caption;
    _isFoodButton.selected = _mio.isFood;
    [self.view setNeedsUpdateConstraints];
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

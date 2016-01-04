//
//  OOTextEntryVC.m
//  ooApp
//
//  Created by Anuj Gujar on 1/2/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "OOTextEntryVC.h"
#import "OOAPI.h"

@interface OOTextEntryVC ()
@property (nonatomic, strong) UIButton *postButton;
@end

@implementation OOTextEntryVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _textView = [[UITextView alloc] init];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.delegate = self;
        _textView.keyboardType = UIKeyboardTypeTwitter;
        _textView.textColor = UIColorRGBA(kColorWhite);
        _textView.backgroundColor = UIColorRGBA(kColorBlack);
        _textView.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH1];
        _textView.layer.cornerRadius = kGeomCornerRadius;
        [_textView setScrollEnabled:NO];
        [self.view addSubview:_textView];
        
        _postButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_postButton withText:@"Post" fontSize:kGeomFontSizeH2 width:50 height:40 backgroundColor:kColorOffBlack target:self selector:@selector(post)];
        [_postButton setTitleColor:UIColorRGBA(kColorWhite) forState:UIControlStateNormal];
        _postButton.translatesAutoresizingMaskIntoConstraints = NO;
        _postButton.layer.borderWidth = 0.5;
        _postButton.layer.borderColor = UIColorRGBA(kColorOffBlack).CGColor;
        _postButton.layer.cornerRadius = kGeomCornerRadius;
        _postButton.contentEdgeInsets = UIEdgeInsetsMake(kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter);
        
        [self.view addSubview:_postButton];
        self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setRightNavWithIcon:kFontIconRemove target:self action:@selector(closeTextEntry)];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_textView becomeFirstResponder];
}

- (void)setDefaultText:(NSString *)defaultText {
    if (defaultText == _defaultText) return;
    _defaultText = defaultText;
    _textView.text = _defaultText;
}

- (void)post {
}

- (void)closeTextEntry {
    [_textView resignFirstResponder];
    [_delegate textEntryFinished:self];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomDimensionsIconButton)};
    
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _textView, _postButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_textView(>=30)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_postButton(30)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_textView]-[_postButton(50)]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//
//  OOTextEntryModalVC.m
//  ooApp
//
//  Created by Anuj Gujar on 1/2/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "OOTextEntryModalVC.h"
#import "OOAPI.h"

@interface OOTextEntryModalVC ()
@property (nonatomic, strong) UIButton *postButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UINavigationBar *bar;
@property (nonatomic, assign) CGFloat spaceRequiredForButton;
@property (nonatomic, assign) CGFloat keyboardHeight;
@end

@implementation OOTextEntryModalVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _bar = [UINavigationBar new];
    [ self.view addSubview: _bar];
    
    self.nto = [[NavTitleObject alloc] initWithHeader: self.title ?: @"About you"
                                            subHeader: self.subtitle ?: @""];
    self.navTitle = self.nto;
    
    _textView = [[UITextView alloc] init];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    _textView.delegate = self;
    _textView.text = self.defaultText;
    _textView.keyboardType = UIKeyboardTypeTwitter;
    _textView.textColor = UIColorRGBA(kColorText);
    _textView.backgroundColor = UIColorRGBA(kColorCellBackground);
    _textView.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _textView.layer.cornerRadius = kGeomCornerRadius;
    [_textView setScrollEnabled:NO];
    [self.view addSubview:_textView];

    NSString *textToDisplayInTheButton = self.buttonText ?: @"Post";
//    UIFont *font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3];
//    CGSize labelSize = [textToDisplayInTheButton sizeWithAttributes:@{NSFontAttributeName: font}];
//    self.spaceRequiredForButton = labelSize.width + 2*kGeomSpaceInter;
    
    _postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_postButton withText:textToDisplayInTheButton
                 fontSize:kGeomFontSizeH3
                    width:66
                   height:40
          backgroundColor:kColorTextActive
                   target:self
                  selector:@selector(post:)];
    [_postButton setTitleColor:UIColorRGBA(kColorTextReverse) forState:UIControlStateNormal];
    [_postButton.titleLabel sizeToFit];
    _spaceRequiredForButton = width(_postButton);
    
    _postButton.titleLabel.numberOfLines= 0;
    _postButton.titleLabel.textAlignment= NSTextAlignmentCenter;
    _postButton.layer.borderWidth = 0.5;
    _postButton.layer.borderColor = UIColorRGBA(kColorBordersAndLines).CGColor;
    _postButton.layer.cornerRadius = kGeomCornerRadius;
    _postButton.contentEdgeInsets = UIEdgeInsetsMake(kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter);
    
    [self.view addSubview:_postButton];
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);

    [self removeNavButtonForSide:kNavBarSideTypeLeft];
    [self addNavButtonWithIcon:kFontIconRemove target:self action:@selector(closeTextEntry) forSide:kNavBarSideTypeLeft isCTA:NO];
    
    [self removeNavButtonForSide:kNavBarSideTypeRight];
    [self addNavButtonWithIcon:@"" target:nil action:nil forSide:kNavBarSideTypeRight isCTA:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN(@(object_getClassName(self)));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];

    [_textView becomeFirstResponder];
}

- (NSString*)text;
{
    return _textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString= [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (_textLengthLimit) {
        return newString.length < _textLengthLimit;
    } else {
        return YES;
    }
}

- (void)setDefaultText:(NSString *)defaultText
{
    if (defaultText == _defaultText) return;
    _defaultText = defaultText;
    _textView.text = _defaultText;
}

- (void)post:(UIButton *)sender
{
    [_textView resignFirstResponder];
    [_delegate textEntryFinished:[self text]];
    [self dismissViewControllerAnimated:YES completion: NULL];
}

- (void)closeTextEntry
{
    [_textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion: NULL];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(2*kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(_spaceRequiredForButton)};
    
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _textView, _postButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_textView(>=60)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_textView]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect frame = _postButton.frame;
    CGFloat h = height(self.view);
    
    frame.origin.x = 0;
    frame.origin.y = h - _keyboardHeight - kGeomHeightButton;
    frame.size.height = kGeomHeightButton;
    frame.size.width = width(self.view);
    _postButton.frame = frame;
}

- (void)keyboardShown:(NSNotification *)not {
    NSDictionary* info = [not userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _keyboardHeight = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
    ? kbSize.width : kbSize.height;
    
}

@end

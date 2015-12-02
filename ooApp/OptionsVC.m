//
//  OptionsVC.m
//  ooApp
//
//  Created by Anuj Gujar on 11/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OptionsVC.h"
#import "NavTitleObject.h"

@interface OptionsVC ()
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation OptionsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _nto = [[NavTitleObject alloc] initWithHeader:@"Options" subHeader:nil];
    self.navTitle = _nto;
    
    _tableView = [[UITableView alloc] init];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = UIColorRGBA(kColorGray);
    [self.view addSubview:_tableView];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton withText:@"close" fontSize:12 width:100 height:40 backgroundColor:kColorBlue target:self selector:@selector(closeOptions)];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_closeButton];
    
    
    [self.moreButton addTarget:self action:@selector(closeOptions) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView, _closeButton);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.view setNeedsUpdateConstraints];
}

- (void)closeOptions {

    [_delegate optionsVCDismiss:self];
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

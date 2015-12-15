//
//  ManageTagsVC.m
//  ooApp
//
//  Created by Anuj Gujar on 11/21/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ManageTagsVC.h"
#import "TagObject.h"
#import "OOAPI.h"
#import "Settings.h"
#import "NavTitleObject.h"

@interface ManageTagsVC ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSMutableSet *usersTags;
@end

static NSString * const cellIdentifier = @"tagCell";

@implementation ManageTagsVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _tableView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _tableView = [[UITableView alloc] init];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:_tableView];
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Manage Tags" subHeader:nil];
    [self setNavTitle:nto];
    
    [self setRightNavWithIcon:@"" target:nil action:nil];
//    self.moreButton.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getAllTags];
}

- (void)getAllTags {
    __weak ManageTagsVC *weakSelf = self;
    [OOAPI getTagsForUser:0 success:^(NSArray *tags) {
        _tags = tags;
        [weakSelf getUsersTags];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)getUsersTags {
    NSUInteger userID = [Settings sharedInstance].userObject.userID;
    __weak ManageTagsVC *weakSelf = self;
    [OOAPI getTagsForUser:userID success:^(NSArray *tags) {
        _usersTags = [NSMutableSet setWithCapacity:[tags count]];
        [tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_usersTags addObject:obj];
        }];
        ON_MAIN_THREAD(^{
            [weakSelf.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonDimensions":@(kGeomDimensionsIconButton)};
    
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _tableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tags count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    TagObject *tag = [_tags objectAtIndex:indexPath.row];

    cell.textLabel.text = tag.term;
    [cell.textLabel setTextColor:UIColorRGBA(kColorWhite)];
    cell.accessoryType = [self isUserTag:tag] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    return cell;
}

- (BOOL)isUserTag:(TagObject *)tag {
    return [_usersTags containsObject:tag];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TagObject *tag = [_tags objectAtIndex:indexPath.row];
    
    NSUInteger userID = [[Settings sharedInstance] userObject].userID;
    __weak ManageTagsVC *weakSelf = self;
    
    if ([self isUserTag:tag]) { //already a user tag so unset
        [OOAPI unsetTag:tag.tagID forUser:userID success:^{
            [weakSelf getUsersTags];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakSelf getUsersTags];
        }];
    } else { //not a user tag so set it
        [OOAPI setTag:tag.tagID forUser:userID success:^{
            [weakSelf getUsersTags];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakSelf getUsersTags];
        }];
    }
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

//
//  OptionsVC.m
//  ooApp
//
//  Created by Anuj Gujar on 11/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OptionsVC.h"
#import "NavTitleObject.h"
#import "OOAPI.h"
#import "Settings.h"
#import "TagObject.h"

@interface OptionsVC ()
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSMutableSet *usersTags;
@end

static NSString * const cellIdentifier = @"tagCell";

@implementation OptionsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _nto = [[NavTitleObject alloc] initWithHeader:@"Hungry?" subHeader:@"What are you in the mood for?"];
    self.navTitle = _nto;
    
    _tableView = [[UITableView alloc] init];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    _tableView.backgroundColor = UIColorRGBA(kColorGray);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [self setRightNavWithIcon:kFontIconRemove target:self action:@selector(closeOptions)];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.view setNeedsUpdateConstraints];
    [self getAllTags];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)getAllTags {
    __weak OptionsVC *weakSelf = self;
    [OOAPI getTagsForUser:0 success:^(NSArray *tags) {
        _tags = tags;
        ON_MAIN_THREAD(^{
            [weakSelf.tableView reloadData];
        });
        [weakSelf getUsersTags];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)getUsersTags {
    NSUInteger userID = [Settings sharedInstance].userObject.userID;
    __weak OptionsVC *weakSelf = self;
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
    __weak OptionsVC *weakSelf = self;
    
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

- (void)closeOptions {
    [_delegate optionsVCDismiss:self withTags:_usersTags];
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

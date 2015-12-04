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
#import "TagTileCVCell.h"
#import "OptionsVCCVL.h"
#import "OOStripHeader.h"

@interface OptionsVC ()
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *tags;

@end

static NSString * const kOptionsLocationCellIdentifier = @"LocationCellIdentifier";
static NSString * const kOptionsPriceCellIdentifier = @"PriceCellIdentifier";
static NSString * const kOptionsTagsCellIdentifier = @"TagsCellIdentifier";
static NSString * const kOptionsTagsHeaderIdentifier = @"TagsHeaderIdentifier";

@implementation OptionsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _nto = [[NavTitleObject alloc] initWithHeader:@"Hungry?" subHeader:@"What are you in the mood for?"];
    self.navTitle = _nto;

    OptionsVCCVL *cvl = [[OptionsVCCVL alloc] init];
    cvl.delegate = self;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:cvl];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.allowsMultipleSelection = YES;
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kOptionsLocationCellIdentifier];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kOptionsPriceCellIdentifier];
    [_collectionView registerClass:[TagTileCVCell class] forCellWithReuseIdentifier:kOptionsTagsCellIdentifier];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:@"header" withReuseIdentifier:kOptionsTagsHeaderIdentifier];

    _collectionView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);

    [self.view addSubview:_collectionView];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _usersTags = [NSMutableSet set];
    
    [self setRightNavWithIcon:kFontIconRemove target:self action:@selector(closeOptions)];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_collectionView);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_collectionView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
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
            [weakSelf.collectionView reloadData];
        });
//        [weakSelf getUsersTags];
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
            [weakSelf.collectionView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

#pragma mark - Collection View stuff

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case kOptionsSectionTypeLocation:
            return 0;
            break;
        case kOptionsSectionTypePrice:
            return 0;
            break;
        case kOptionsSectionTypeTags:
            return [_tags count];
            break;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
    switch (indexPath.section) {
        case kOptionsSectionTypeLocation: {
            UICollectionViewCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kOptionsLocationCellIdentifier forIndexPath:indexPath];
            //[DebugUtilities addBorderToViews:@[cvc]];
            return cvc;
            break;
        }
        case kOptionsSectionTypePrice: {
            UICollectionViewCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kOptionsPriceCellIdentifier forIndexPath:indexPath];
            cvc.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
            //[DebugUtilities addBorderToViews:@[cvc]];
            return cvc;
            break;
        }
        case kOptionsSectionTypeTags: {
            TagTileCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:kOptionsTagsCellIdentifier forIndexPath:indexPath];
            
            TagObject *tag = [_tags objectAtIndex:indexPath.row];
            cvc.tagObject = tag;
            cvc.selected = [self isUserTag:tag];
            
            //[DebugUtilities addBorderToViews:@[cvc]];
            return cvc;
            break;
        }
        default:
            break;
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kOptionsSectionTypeNumberOfSections;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(OptionsVCCVL *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case kOptionsSectionTypeLocation:
            return 100;
            break;
        case kOptionsSectionTypePrice:
            return 50;
            break;
        case kOptionsSectionTypeTags: {
//            TagObject *to = [_tags objectAtIndex:indexPath.row];
            CGFloat height = 35;
            return height;
            break;
        }
        default:
            return 0;
            break;
    }
    return 0;
}

- (BOOL)isUserTag:(TagObject *)tag {
    return [_usersTags containsObject:tag];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kOptionsSectionTypeTags) {
        TagObject *tag = [_tags objectAtIndex:indexPath.row];
        
        if ([self isUserTag:tag]) { //already a user tag so unset
            [_usersTags removeObject:tag];
        } else { //not a user tag so set it
            [_usersTags addObject:tag];
        }

    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reuseView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kOptionsTagsHeaderIdentifier forIndexPath:indexPath];
    
    [[reuseView viewWithTag:111] removeFromSuperview];

    if (indexPath.section == kOptionsSectionTypeTags) {
        OOStripHeader *header = [[OOStripHeader alloc] init];
        header.name = @"Cuisine:";
        header.frame = CGRectMake(0, 0, width(self.view), kGeomStripHeaderHeight);
        header.tag = 111;
        [collectionView bringSubviewToFront:reuseView];
        [reuseView addSubview:header];
        [header setNeedsLayout];
    }
    return reuseView;
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

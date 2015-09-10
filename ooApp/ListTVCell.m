//
//  ListTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 8/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListTVCell.h"
#import "DebugUtilities.h"
#import "OOAPI.h"
#import "ListCVFL.h"
#import "ListCVCell.h"
#import "UIImageView+AFNetworking.h"
#import "LocationManager.h"

@interface ListTVCell ()

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) NSArray *restaurants;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *cvl;
@property (nonatomic, strong) UICollectionView *featuredCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *fcvl;

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end


static NSString * const RestaurantCellIdentifier = @"RestaurantCell";
static NSString * const FeaturedRestaurantCellIdentifier = @"FeaturedRestaurantCell";

@implementation ListTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _listItem = [[ListObject alloc] init];
        _name = [[UILabel alloc] init];
        [_name withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear];
        
        _cvl = [[ListCVFL alloc] init];
        [_cvl setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [_cvl setItemSize:CGSizeMake(kGeomHeightListCell, kGeomHeightListCell)];

        _fcvl = [[ListCVFL alloc] init];
        [_fcvl setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [_fcvl setItemSize:CGSizeMake(kGeomHeightFeaturedCellWidth, kGeomHeightFeaturedCellHeight)];

        [self addSubview:_name];
        
        _name.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColorRGBA(kColorOffBlack);
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        [self layout];
        
//        [DebugUtilities addBorderToViews:@[_name,_actionButton]];
    }
    
    return self;
}

- (void)layout {
    
    CGSize labelSize = [@"Abc" sizeWithAttributes:@{NSFontAttributeName:_name.font}];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightListRow), @"labelY":@((kGeomHeightListRow-kGeomHeightListCell-labelSize.height)/2), @"buttonY":@(kGeomHeightListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _name);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(labelY)-[_name]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=10)-[_name]-(>=10)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_name
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_name.superview
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.f constant:0.f]];

}

- (void)prepareForReuse
{
    self.requestOperation= nil;
    
    // AFNetworking
//    [self.backgroundImage cancelImageRequestOperation];
    
    // AFNetworking
    [self.requestOperation cancel ];
    self.requestOperation= nil;
}

- (void)setListItem:(ListObject *)listItem
{
    _listItem = listItem;
    _name.text = listItem.name;
    [self getRestaurants];
}

- (void)getRestaurants
{
    OOAPI *api = [[OOAPI alloc] init];
    
    self.requestOperation = [api getRestaurantsWithKeyword:_listItem.name andLocation:[[LocationManager sharedInstance] currentUserLocation] success:^(NSArray *r) {
        _restaurants = r;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self gotRestaurants];
        });
    } failure:^(NSError *err) {
        ;
    }];
}

- (void)gotRestaurants
{
    NSLog(@"%@: %tu", _listItem.name, [_restaurants count]);

//    [self addSubview:_collectionView];
    if (_listItem.listType == kListTypeFeatured) {
        self.featuredCollectionView.delegate = self;
        self.featuredCollectionView.dataSource = self;
        [self.featuredCollectionView reloadData];
    } else {
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView reloadData];
    }
//    [DebugUtilities addBorderToViews:@[self.collectionView] withColors:kColorNavyBlue];
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma Collection View delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_restaurants count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListCVCell *restaurantCell;
    if (_listItem.listType == kListTypeFeatured) {
        restaurantCell = [collectionView dequeueReusableCellWithReuseIdentifier:FeaturedRestaurantCellIdentifier forIndexPath:indexPath];
    } else {
        restaurantCell = [collectionView dequeueReusableCellWithReuseIdentifier:RestaurantCellIdentifier forIndexPath:indexPath];
    }
    restaurantCell.restaurant = [_restaurants objectAtIndex:indexPath.row];
    return restaurantCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPat
{
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

#pragma lazy load some stuff

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kGeomHeightListRow-kGeomHeightListCell, self.frame.size.width, self.frame.size.height-(kGeomHeightListRow-kGeomHeightListCell)) collectionViewLayout:_cvl];
        [_collectionView registerClass:[ListCVCell class] forCellWithReuseIdentifier:RestaurantCellIdentifier];
        _collectionView.backgroundColor = UIColorRGBA(kColorOffBlack);
        [self addSubview:_collectionView];
        [self bringSubviewToFront:_name];
    }
    return _collectionView;
}

- (UICollectionView *)featuredCollectionView
{
    if (!_featuredCollectionView) {
        _featuredCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kGeomHeightFeaturedRow-kGeomHeightFeaturedCellHeight, self.frame.size.width, self.frame.size.height-(kGeomHeightFeaturedRow-kGeomHeightFeaturedCellHeight)) collectionViewLayout:_fcvl];
        [_featuredCollectionView registerClass:[ListCVCell class] forCellWithReuseIdentifier:FeaturedRestaurantCellIdentifier];
        [self addSubview:_featuredCollectionView];
        [self bringSubviewToFront:_name];
    }
    return _featuredCollectionView;
}

@end

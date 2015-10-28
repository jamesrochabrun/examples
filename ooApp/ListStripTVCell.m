//
//  ListStripTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 8/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListStripTVCell.h"
#import "DebugUtilities.h"
#import "OOAPI.h"
#import "ListCVFL.h"
#import "TileCVCell.h"
#import "UIImageView+AFNetworking.h"
#import "LocationManager.h"
#import "RestaurantVC.h"
#import "OOStripHeader.h"

@interface ListStripTVCell ()

//@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) OOStripHeader *nameHeader;
@property (nonatomic, strong) NSArray *restaurants;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *cvl;
@property (nonatomic, strong) UICollectionView *featuredCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *fcvl;

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end


static NSString * const RestaurantCellIdentifier = @"RestaurantCell";
static NSString * const FeaturedRestaurantCellIdentifier = @"FeaturedRestaurantCell";

@implementation ListStripTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _requestOperation = nil;
        _listItem = [[ListObject alloc] init];
        
        _nameHeader = [[OOStripHeader alloc] init];
        
        _cvl = [[ListCVFL alloc] init];
        [_cvl setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [_cvl setItemSize:CGSizeMake(kGeomHeightStripListCell, kGeomHeightStripListCell)];

        _fcvl = [[ListCVFL alloc] init];
        [_fcvl setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        [self addSubview:_nameHeader];
        
        _nameHeader.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"strip_gradient.png"]];
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        [self layout];
        
        
//        [DebugUtilities addBorderToViews:@[_name,_actionButton]];
    }
    
    return self;
}

- (void)prepareForReuse
{
    // NOTE:  for some reason this is not been called.
    
    [super prepareForReuse];
    
    self.listItem = nil;
//    self.name.text =  nil;
    _nameHeader.name = nil;
    
    // AFNetworking
    [self.requestOperation cancel];
    self.requestOperation = nil;
    
}

- (void)layout {
    
//    CGSize labelSize = [@"Abc" sizeWithAttributes:@{NSFontAttributeName:_nameHeader.font}];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"labelY":@((kGeomHeightStripListRow-kGeomHeightStripListCell)/2), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _nameHeader);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(labelY)-[_nameHeader(27)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_nameHeader]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameHeader
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_nameHeader.superview
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.f constant:0.f]];

}

- (void)setListItem:(ListObject *)listItem
{
    if (_listItem == listItem) return;
    
    if (_listItem == kListDisplayTypeFeatured) {
        [_featuredCollectionView reloadData];
    } else {
        [_collectionView reloadData];
    }
    _listItem = listItem;
    _nameHeader.name = _listItem.name;
    _restaurants = nil;
    if (_listItem)
        [self getRestaurants];
}

- (void)getRestaurants
{
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak ListStripTVCell *weakSelf=self;
    if (_listItem.type == kListTypeToTry ||
        _listItem.type == kListTypeFavorites ||
        _listItem.type == kListTypeUser) {
        self.requestOperation = [api getRestaurantsWithListID:_listItem.listID success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(NSError *err) {
            ;
        }];
    } else {
        self.requestOperation = [api getRestaurantsWithKeyword:_listItem.name
                                                   andLocation:[[LocationManager sharedInstance] currentUserLocation]
                                                     andFilter:@""
                                                    andOpenOnly:NO
                                                          andSort:kSearchSortTypeBestMatch
                                                       success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(NSError *err) {
            ;
        }];
    }
}

- (void)gotRestaurants
{
    NSLog(@"%@: %lu", _listItem.name, [_restaurants count]);
    if (![_restaurants count]) {
        NSLog (@"LIST CALLED %@ HAS ZERO RESTAURANTS",_listItem.name);
    }
    //    [self addSubview:_collectionView];
    if (_listItem.listDisplayType == kListDisplayTypeFeatured) {
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
    TileCVCell *restaurantCell;
    if (collectionView == _featuredCollectionView) {
        restaurantCell = [collectionView dequeueReusableCellWithReuseIdentifier:FeaturedRestaurantCellIdentifier forIndexPath:indexPath];
    } else {
        restaurantCell = [collectionView dequeueReusableCellWithReuseIdentifier:RestaurantCellIdentifier forIndexPath:indexPath];
    }
    restaurantCell.restaurant = [_restaurants objectAtIndex:indexPath.row];
    return restaurantCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
    
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    vc.title = trimString(restaurant.name);
    vc.restaurant = restaurant;
    [_navigationController pushViewController:vc animated:YES];
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == _featuredCollectionView) {
        return 0;
    } else {
        return 3;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}




#pragma lazy load some stuff

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kGeomSpaceEdge, kGeomHeightStripListRow-kGeomHeightStripListCell, self.frame.size.width-2*kGeomSpaceEdge, self.frame.size.height-(kGeomHeightStripListRow-kGeomHeightStripListCell)) collectionViewLayout:_cvl];
        [_collectionView registerClass:[TileCVCell class] forCellWithReuseIdentifier:RestaurantCellIdentifier];
        _collectionView.backgroundColor = UIColorRGBA(kColorClear);
        [self addSubview:_collectionView];
        [self bringSubviewToFront:_nameHeader];
    }
    return _collectionView;
}

- (UICollectionView *)featuredCollectionView
{
    if (!_featuredCollectionView) {
        [_fcvl setItemSize:CGSizeMake(self.frame.size.width-2*kGeomSpaceEdge, kGeomHeightFeaturedCellHeight)];
        _featuredCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kGeomSpaceEdge, kGeomHeightFeaturedRow-kGeomHeightFeaturedCellHeight, self.frame.size.width-2*kGeomSpaceEdge, self.frame.size.height-(kGeomHeightFeaturedRow-kGeomHeightFeaturedCellHeight)) collectionViewLayout:_fcvl];
        [_featuredCollectionView registerClass:[TileCVCell class] forCellWithReuseIdentifier:FeaturedRestaurantCellIdentifier];
        _featuredCollectionView.backgroundColor = UIColorRGBA(kColorClear);
        _featuredCollectionView.pagingEnabled = YES;
        [self addSubview:_featuredCollectionView];
        [self bringSubviewToFront:_nameHeader];
    }
    return _featuredCollectionView;
}

@end

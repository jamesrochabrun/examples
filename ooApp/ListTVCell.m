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
#import "TileCVCell.h"
#import "UIImageView+AFNetworking.h"
#import "LocationManager.h"
#import "RestaurantVC.h"

@interface ListTVCell ()

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIView *line;
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
        _requestOperation = nil;
        _listItem = [[ListObject alloc] init];
        
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorRGBA(kColorOffWhite);
        
        _name = [[UILabel alloc] init];
        [_name withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeSubheader] textColor:kColorBlack backgroundColor:kColorClear];
        
        _cvl = [[ListCVFL alloc] init];
        [_cvl setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [_cvl setItemSize:CGSizeMake(kGeomHeightStripListCell, kGeomHeightStripListCell)];

        _fcvl = [[ListCVFL alloc] init];
        [_fcvl setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        [self addSubview:_name];
        [self addSubview:_line];
        
        _name.translatesAutoresizingMaskIntoConstraints = _line.translatesAutoresizingMaskIntoConstraints = NO;
        
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
    self.name.text =  nil;
    
    // AFNetworking
    [self.requestOperation cancel];
    self.requestOperation = nil;
    
}

- (void)layout {
    
    CGSize labelSize = [@"Abc" sizeWithAttributes:@{NSFontAttributeName:_name.font}];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"labelY":@((kGeomHeightStripListRow-kGeomHeightStripListCell-labelSize.height)/2), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _name, _line);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(labelY)-[_name]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_line(1)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spaceEdge)-[_name]-[_line]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
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
    _name.text = [listItem.name uppercaseString];
    _restaurants = nil;
    if (listItem)
        [self getRestaurants];
}

- (void)getRestaurants
{
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak ListTVCell *weakSelf=self;
    if (_listItem.type == kOOAPIListTypeFavorites) {
        self.requestOperation = [api getRestaurantsWithListID:[_listItem.listID integerValue] success:^(NSArray *r) {
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
                                                    andOpenOnly:NO
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
    NSLog(@"%@: %tu", _listItem.name, [_restaurants count]);
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
    [_navigationController pushViewController:vc animated:YES];
    vc.restaurant = restaurant;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == _featuredCollectionView) {
        return 10;
    } else {
        return 2;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}




#pragma lazy load some stuff

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kGeomHeightStripListRow-kGeomHeightStripListCell, self.frame.size.width, self.frame.size.height-(kGeomHeightStripListRow-kGeomHeightStripListCell)) collectionViewLayout:_cvl];
        [_collectionView registerClass:[TileCVCell class] forCellWithReuseIdentifier:RestaurantCellIdentifier];
        _collectionView.backgroundColor = UIColorRGBA(kColorClear);
        [self addSubview:_collectionView];
        [self bringSubviewToFront:_name];
    }
    return _collectionView;
}

- (UICollectionView *)featuredCollectionView
{
    if (!_featuredCollectionView) {
        [_fcvl setItemSize:CGSizeMake(self.frame.size.width-2*kGeomSpaceEdge, kGeomHeightFeaturedCellHeight)];
        _featuredCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kGeomHeightFeaturedRow-kGeomHeightFeaturedCellHeight, self.frame.size.width, self.frame.size.height-(kGeomHeightFeaturedRow-kGeomHeightFeaturedCellHeight)) collectionViewLayout:_fcvl];
        [_featuredCollectionView registerClass:[TileCVCell class] forCellWithReuseIdentifier:FeaturedRestaurantCellIdentifier];
        _featuredCollectionView.backgroundColor = UIColorRGBA(kColorClear);
        _featuredCollectionView.pagingEnabled = YES;
        [self addSubview:_featuredCollectionView];
        [self bringSubviewToFront:_name];
    }
    return _featuredCollectionView;
}

@end

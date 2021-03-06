//
//  ListStripCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 8/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListStripCVCell.h"
#import "DebugUtilities.h"
#import "OOAPI.h"
#import "ListCVFL.h"
#import "TileCVCell.h"
#import "UIImageView+AFNetworking.h"
#import "LocationManager.h"
#import "RestaurantVC.h"
#import "OOStripHeader.h"

@interface ListStripCVCell ()

//@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) OOStripHeader *nameHeader;
@property (nonatomic, strong) NSArray *restaurants;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *cvl;
@property (nonatomic, strong) UICollectionView *featuredCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *fcvl;

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) NSArray *constraintsToRemember;

@property (nonatomic, strong) UILabel *noRestautantsMessage;

@end

static NSString * const RestaurantCellIdentifier = @"RestaurantCell";
static NSString * const FeaturedRestaurantCellIdentifier = @"FeaturedRestaurantCell";

@implementation ListStripCVCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _requestOperation = nil;
        _listItem = [[ListObject alloc] init];
        
        _cvl = [[ListCVFL alloc] init];
        [_cvl setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        _fcvl = [[ListCVFL alloc] init];
        [_fcvl setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        _nameHeader = [[OOStripHeader alloc] init];
        [self addSubview:_nameHeader];
        _nameHeader.translatesAutoresizingMaskIntoConstraints = NO;
        
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
//        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _noRestautantsMessage = [[UILabel alloc] init];
        [_noRestautantsMessage withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3] textColor:kColorGrayMiddle backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        [self addSubview:_noRestautantsMessage];
        _noRestautantsMessage.translatesAutoresizingMaskIntoConstraints = NO;
        _noRestautantsMessage.hidden = YES;
//        [DebugUtilities addBorderToViews:@[_nameHeader]];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(listAltered:)
                       name:kNotificationListAltered
                     object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)listAltered:(NSNotification *)not {
    id list = [not object];
    
    if ([list isKindOfClass:[ListObject class]]) {
        ListObject *l = (ListObject *)list;
        if (l.listID == _listItem.listID) {
            [self setListItem:l];
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _restaurants= nil;
    self.listItem = nil;
//    self.name.text =  nil;
    _nameHeader.name = nil;
    
    // AFNetworking
    [self.requestOperation cancel];
    self.requestOperation = nil;
    
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"labelY":@((kGeomHeightStripListRow-kGeomHeightStripListCell)-27), @"spaceEdge":@(kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"leftSpacing":@((width(self)-width(_nameHeader))/2)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _nameHeader, _noRestautantsMessage);
    
    if (_listItem.listDisplayType == kListDisplayTypeFeatured) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_nameHeader(27)]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

        [self removeConstraints:_constraintsToRemember];
        _constraintsToRemember = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leftSpacing)-[_nameHeader]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];

        [self addConstraints:_constraintsToRemember];
        
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_nameHeader
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeCenterY
                             multiplier:1
                             constant:0]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-labelY-[_nameHeader(27)]-(>=0)-[_noRestautantsMessage]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_nameHeader]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_noRestautantsMessage
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeCenterY
                             multiplier:1
                             constant:27/2]];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_noRestautantsMessage]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}

- (void)setListItem:(ListObject *)listItem
{
//    if (_listItem == listItem) return;
    
    _listItem = listItem;
    _nameHeader.name = _listItem.listName;
    
    if (_listItem.listDisplayType == kListDisplayTypeFeatured) {
        [_collectionView removeFromSuperview];
        _collectionView = nil;
        [self.featuredCollectionView reloadData];
        _nameHeader.backgroundColor = UIColorRGBA(kColorClear);
        _nameHeader.icon = @"";
        [_nameHeader setFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader]];
    } else {
        [_featuredCollectionView removeFromSuperview];
        _featuredCollectionView = nil;
        [self.collectionView reloadData];
        _nameHeader.backgroundColor = UIColorRGBA(kColorStripHeader);
        _nameHeader.icon = kFontIconList;
        [_nameHeader setFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH3]];
    }

    NSLog(@"nameHeader after setting %@ rect=%@", _nameHeader.name, NSStringFromCGRect(_nameHeader.frame));
    [self setNeedsUpdateConstraints];
    
    _restaurants = nil;
    if (_listItem)
        [self getRestaurants];
}

- (void)getRestaurants
{
    OOAPI *api = [[OOAPI alloc] init];
    
    _noRestautantsMessage.hidden = YES;
    
    __weak ListStripCVCell *weakSelf=self;
    if (_listItem.type == kListTypeToTry ||
        _listItem.type == kListTypeFavorites ||
        _listItem.type == kListTypeYumList ||
        _listItem.type == kListTypePlaceIveBeen ||
        _listItem.type == kListTypeUser) {
        
        self.requestOperation = [api getRestaurantsWithListID:_listItem.listID
                                                  andLocation:[LocationManager sharedInstance].currentUserLocation
                                                      success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            ;
        }];
    } else if (_listItem.type == kListTypeTrending||
               _listItem.type == kListTypePopular) {

        self.requestOperation = [api getRestaurantsFromSystemList:_listItem.type success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            ;
        }];
    } else {
        self.requestOperation = [api getRestaurantsWithKeywords:((_listItem.type == kListTypeJustForYou) ? @[@"restaurants"] : @[_listItem.name])
                                                   andLocation:[[LocationManager sharedInstance] currentUserLocation]
                                                     andFilter:@""
                                                    andRadius:3000
                                                    andOpenOnly:NO
                                                          andSort:kSearchSortTypeBestMatch
                                                       minPrice:0
                                                       maxPrice:3
                                                         isPlay:(_listItem.type == kListTypeJustForYou) ? YES : NO
                                                       success:^(NSArray *r) {
            weakSelf.restaurants = r;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf gotRestaurants];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            ;
        }];
    }
}

- (void)gotRestaurants
{
    NSLog(@"%@: %lu", _listItem.name, (unsigned long)[_restaurants count]);
    
    if (![_restaurants count]) {
        if (_userContext.userID == [Settings sharedInstance].userObject.userID) {
            if (_listItem.type == kListTypePlaceIveBeen) {
                _noRestautantsMessage.text = [NSString stringWithFormat:@"When you upload a restaurant photo, we'll add the restaurant to the \'%@\' list.", _listItem.listName];
            } else if (_listItem.type == kListTypeYumList) {
                _noRestautantsMessage.text = [NSString stringWithFormat:@"When you Yum a photo in the food feed the restaurant will be added to your Yum list."];
            } else {
                _noRestautantsMessage.text = [NSString stringWithFormat:@"You have not yet added restaurants to this list."];
            }
        } else {
            if (_listItem.type == kListTypePlaceIveBeen) {
                _noRestautantsMessage.text = [NSString stringWithFormat:@"@%@ hasn't been uploading any photos of food at restaurants.", _userContext.username];
            } else if (_listItem.type == kListTypeYumList) {
                _noRestautantsMessage.text = [NSString stringWithFormat:@"@%@ hasn't yummed any photos yet. Upload a yummy photo so that @%@ can get into the game.", _userContext.username, _userContext.username];
            } else {
                _noRestautantsMessage.text = [NSString stringWithFormat:@"@%@ has not yet added restaurants to %@", _userContext.username,  _listItem.name];
            }
        }

        _noRestautantsMessage.hidden = NO;
    }
    
    if (_listItem.listDisplayType == kListDisplayTypeFeatured) {
        self.featuredCollectionView.delegate = self;
        self.featuredCollectionView.dataSource = self;
        [self.featuredCollectionView reloadData];
    } else {
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView reloadData];
    }
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];
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

    restaurantCell.displayType = _listItem.listDisplayType;
    restaurantCell.restaurant = [_restaurants objectAtIndex:indexPath.row];
    return restaurantCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantObject *restaurant = [_restaurants objectAtIndex:indexPath.row];
    
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    vc.title = trimString(restaurant.name);
    vc.restaurant = restaurant;
    ANALYTICS_EVENT_UI(@"RestaurantVC-from-ListStripCVCell");
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
        [_cvl setItemSize:CGSizeMake(kGeomHeightStripListCell*1.3, kGeomHeightStripListCell)];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kGeomSpaceEdge, kGeomHeightStripListRow-kGeomHeightStripListCell, self.frame.size.width-2*kGeomSpaceEdge, self.frame.size.height-(kGeomHeightStripListRow-kGeomHeightStripListCell)) collectionViewLayout:_cvl];
        [_collectionView registerClass:[TileCVCell class] forCellWithReuseIdentifier:RestaurantCellIdentifier];
        _collectionView.backgroundColor = UIColorRGBA(kColorClear);
//        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_collectionView];
        [self bringSubviewToFront:_nameHeader];
    }
    return _collectionView;
}

- (UICollectionView *)featuredCollectionView
{
    if (!_featuredCollectionView) {
        [_fcvl setItemSize:CGSizeMake(self.frame.size.width-2*kGeomSpaceEdge, kGeomHeightFeaturedRow-2*kGeomSpaceEdge)];
        _featuredCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kGeomSpaceEdge, kGeomSpaceInter, self.frame.size.width-2*kGeomSpaceEdge, self.frame.size.height-kGeomSpaceInter) collectionViewLayout:_fcvl];
        [_featuredCollectionView registerClass:[TileCVCell class] forCellWithReuseIdentifier:FeaturedRestaurantCellIdentifier];
        _featuredCollectionView.backgroundColor = UIColorRGBA(kColorClear);
        _featuredCollectionView.pagingEnabled = YES;
        [self addSubview:_featuredCollectionView];
        [self bringSubviewToFront:_nameHeader];
    }
    return _featuredCollectionView;
}

@end

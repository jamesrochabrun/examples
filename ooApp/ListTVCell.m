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

@interface ListTVCell ()

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIView *foregroundView;
@property (nonatomic, strong) NSArray *restaurants;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *cvl;

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end


static NSString * const RestaurantCellIdentifier = @"RestaurantCell";

@implementation ListTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _listItem = [[ListObject alloc] init];
        _backgroundImage = [[UIImageView alloc] init];
        _name = [[UILabel alloc] init];
        [_name withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear];
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_actionButton setTitle:kFontIconMeet forState:UIControlStateNormal];
        [_actionButton setTitleColor:UIColorRGBA(kColorWhite) forState:UIControlStateNormal];
        [_actionButton setTitleColor:UIColorRGBA(kColorButtonSelected) forState:UIControlStateHighlighted];
        [_actionButton.titleLabel setFont:[UIFont fontWithName:kFontIcons size:20]];
        
        _foregroundView = [[UIView alloc] init];
        _foregroundView.backgroundColor = UIColorRGBA(kColorStripOverlay);

        _cvl = [[ListCVFL alloc] init];
        [_cvl setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [_cvl setMinimumInteritemSpacing:0];

        [_cvl setItemSize:CGSizeMake(kGeomHeightListCell, kGeomHeightListCell)];
        
        [self addSubview:_backgroundImage];
        [self addSubview:_foregroundView];
        [self addSubview:_actionButton];
        [self addSubview:_name];
        
        _foregroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        _name.translatesAutoresizingMaskIntoConstraints = NO;
        
        //set the selected color for the cell
//        UIView *bgColorView = [[UIView alloc] init];
//        bgColorView.backgroundColor = UIColorRGBA(kColorCellSelected);
//        [self setSelectedBackgroundView:bgColorView];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColorRGBA(kColorWhite);
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        [self layout];
        
//        [DebugUtilities addBorderToViews:@[_backgroundImage, _foregroundView, _name,_actionButton]];
    }
    
    return self;
}

- (void)layout {
    
    CGSize labelSize = [@"Abc" sizeWithAttributes:@{NSFontAttributeName:_name.font}];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightListRow), @"labelY":@((kGeomHeightListRow-labelSize.height)/2), @"buttonY":@(kGeomHeightListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"listHeight":@(kGeomHeightListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _foregroundView, _backgroundImage, _name, _actionButton);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_foregroundView(height)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_name]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(buttonY)-[_actionButton]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_foregroundView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=10)-[_actionButton]-(spaceEdge)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
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
    [self.backgroundImage cancelImageRequestOperation];
    
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
    
    self.requestOperation= [api getRestaurantsWithKeyword:_listItem.name andLocation:CLLocationCoordinate2DMake(37.7833,-122.4167) success:^(NSArray *r) {
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
    [_restaurants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"rest name = %@",  [(RestaurantObject *)obj name]);
    }];
//    [self addSubview:_collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
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


- (void)deselectRow {
//    [_collectionView removeFromSuperview];
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
    ListCVCell *restaurantCell = [collectionView dequeueReusableCellWithReuseIdentifier:RestaurantCellIdentifier forIndexPath:indexPath];
    restaurantCell.restaurant = [_restaurants objectAtIndex:indexPath.row];
    return restaurantCell;
}

#pragma lazy load some stuff

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, self.frame.size.height-20) collectionViewLayout:_cvl];
        [_collectionView registerClass:[ListCVCell class] forCellWithReuseIdentifier:RestaurantCellIdentifier];
        [self addSubview:_collectionView];
        [self bringSubviewToFront:_name];
    }
    return _collectionView;
}

@end

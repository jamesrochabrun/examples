//
//  ListTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 10/1/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ListTVCell.h"
#import "MediaItemObject.h"

@interface ListTVCell()

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSArray *lists;

@end

@implementation ListTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton withIcon:kFontIconAdd fontSize:15 width:40 height:40 backgroundColor:kColorClear target:self selector:@selector(toggleListInclusion)];
        _addButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_addButton];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self layout];
}

- (void)layout {
    [super layout];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _addButton);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_addButton]-(>=10)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=100)-[_addButton]-spaceInter-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_addButton.superview
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];
}

- (void)toggleListInclusion {
    OOAPI *api =[[OOAPI alloc] init];
    __weak ListTVCell *weakSelf = self;
    
    if (_onList) {
        //remove from list
        [api deleteRestaurant:[_restaurant.restaurantID integerValue] fromList:[_list.listID integerValue] success:^(NSArray *lists) {
            [weakSelf getListsForRestaurant];
        } failure:^(NSError *error) {
            ;
        }];
    } else {
        //add to list
        [api addRestaurants:@[_restaurant] toList:[_list.listID integerValue] success:^(id response) {
            [weakSelf getListsForRestaurant];
        } failure:^(NSError *error) {
            ;
        }];
    }
}

- (void)getListsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak ListTVCell *weakSelf = self;
    [api getListsOfUser:0 withRestaurant:[_restaurant.restaurantID integerValue]
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user:  %ld", ( long) foundLists.count);
                    _lists = foundLists;
                    ON_MAIN_THREAD( ^{
                        [weakSelf updateAddButton];
                    });
                }
                failure:^(NSError *e) {
                    NSLog  (@" error while getting lists for user:  %@",e);
                }];
}

- (void)updateAddButton {
    __block BOOL onLine = NO;
    [_lists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ListObject *lo = (ListObject *)obj;
        if (lo.listID == _list.listID) {
            onLine = YES;
            *stop = YES;
        }
    }];
    
    [self setOnList:onLine];
}

- (void)setOnList:(BOOL)onList {
    if (onList == _onList) return;
    _onList = onList;
    [_addButton setTitle:((_onList) ? kFontIconRemove : kFontIconAdd) forState:UIControlStateNormal];
}

- (void)setList:(ListObject *)list {
    if (list == _list) return;
    _list = list;
    self.thumbnail.image = nil;
    self.header.text = _list.name;
    [self getListsForRestaurant];
    
    OOAPI *api = [[OOAPI alloc] init];

    if (_list.mediaItem) {
        self.requestOperation = [api getRestaurantImageWithImageRef:_list.mediaItem.reference maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.thumbnail setImageWithURL:[NSURL URLWithString:link]];
            });
        } failure:^(NSError *error) {
            ;
        }];
    }

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  ListTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 10/1/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ListTVCell.h"
#import "MediaItemObject.h"
#import "DebugUtilities.h"
#import "Settings.h"

@interface ListTVCell()

//@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSArray *lists;

@end

@implementation ListTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_addButton withIcon:kFontIconAdd fontSize:15 width:40 height:40 backgroundColor:kColorClear target:nil selector:nil];
//        _addButton.translatesAutoresizingMaskIntoConstraints = NO;
//        [self addSubview:_addButton];
//        [DebugUtilities addBorderToViews:@[_addButton]];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];

    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonHeight":@(kGeomHeightButton)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview);//, _addButton);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_addButton(buttonHeight)]-(>=10)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=100)-[_addButton(buttonHeight)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addButton
//                                                     attribute:NSLayoutAttributeCenterY
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:_addButton.superview
//                                                     attribute:NSLayoutAttributeCenterY
//                                                    multiplier:1.f constant:0.f]];
}

- (void)toggleListInclusion {
    OOAPI *api =[[OOAPI alloc] init];
    __weak ListTVCell *weakSelf = self;
    
    if (_onList) {
        //remove from list
        [api deleteRestaurant:_restaurantToAdd.restaurantID fromList:_list.listID success:^(NSArray *lists) {
            [weakSelf getListsForRestaurant];
        } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
            ;
        }];
    } else {
        //add to list
        [api addRestaurants:@[_restaurantToAdd] toList:_list.listID success:^(id response) {
            [weakSelf getListsForRestaurant];
        } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
            ;
        }];
    }
}

- (void)getListsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak ListTVCell *weakSelf = self;
    
    UserObject *userInfo = [Settings sharedInstance].userObject;

    [api getListsOfUser:userInfo.userID withRestaurant:_restaurantToAdd.restaurantID
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user:  %ld", ( long) foundLists.count);
                    _lists = foundLists;
                    ON_MAIN_THREAD( ^{
                        [weakSelf updateAddButton];
                    });
                }
                failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                    NSLog  (@" error while getting lists for user:  %@",e);
                }];
}

- (void)updateAddButton {
    __block BOOL onList = NO;
    [_lists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ListObject *lo = (ListObject *)obj;
        if (lo.listID == _list.listID) {
            onList = YES;
            *stop = YES;
        }
    }];
    
    [self setOnList:onList];
}

- (void)setOnList:(BOOL)onList {
    if (onList == _onList) return;
    _onList = onList;
    [self.actionButton setTitle:((_onList) ? kFontIconRemove : kFontIconAdd) forState:UIControlStateNormal];
}

- (void)setList:(ListObject *)list {
    if (list == _list) return;
    _list = list;
    self.thumbnail.image = nil;
    self.header.text = _list.name;
    if (_list.numRestaurants == 1) {
        self.subHeader1.text = [NSString stringWithFormat:@"%lu restaurant", (unsigned long)_list.numRestaurants];
    } else if (_list.numRestaurants) {
        self.subHeader1.text = [NSString stringWithFormat:@"%lu restaurants", (unsigned long)_list.numRestaurants];
    } else {
        self.subHeader1.text = @"";
    }

    if (_restaurantToAdd) {
        [self.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.actionButton addTarget:self action:@selector(toggleListInclusion) forControlEvents:UIControlEventTouchUpInside];
        [self getListsForRestaurant];
    } else if (_listToAddTo) {
        [self.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.actionButton addTarget:self action:@selector(addAllRestaurantsFromList) forControlEvents:UIControlEventTouchUpInside];
    } else {
        
    }

    //get the list's image
    OOAPI *api = [[OOAPI alloc] init];

    if (_list.mediaItem) {
        self.requestOperation = [api getRestaurantImageWithImageRef:_list.mediaItem.reference maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.thumbnail setImageWithURL:[NSURL URLWithString:link]];
            });
        } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
            ;
        }];
    }

}

- (void)addAllRestaurantsFromList {
    OOAPI *api = [[OOAPI alloc] init];
    [api getRestaurantsWithListID:_list.listID success:^(NSArray *restaurants) {
        [api addRestaurants:restaurants toList:_listToAddTo.listID success:^(id response) {
            ;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

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
#import "LocationManager.h"

@interface ListTVCell()

@property (nonatomic,strong) UIButton *buttonAddAll;

@end

@implementation ListTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.icon.text = kFontIconList;
        [self.actionButton setTitle:@"" forState:UIControlStateNormal];
    }
    return self;
}


//- (void)addTheAddAllButton
//{
//    _buttonAddAll= makeButton(self,  @"ADD ALL", kGeomFontSizeHeader,
//                              UIColorRGBA(kColorWhite), UIColorRGBA(kColorClear), self,
//                              @selector(userPressedAddAll:) , 1);
//    _buttonAddAll.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [self bringSubviewToFront:_buttonAddAll];
//}

//- (void)userPressedAddAll:(id)sender
//{
//    NSLog  (@"USER PRESSED ADD ALL BUTTON");
//    [self.delegate userPressedAddAllForList:self.listToAddTo ];
//}

- (void)updateConstraints {
    [super updateConstraints];

    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonHeight":@(kGeomHeightButton)};
    
    if  ( self.buttonAddAll) {
        
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _buttonAddAll);
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=0)-[_buttonAddAll(>=80)]-(spaceEdge)-|"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    [ self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_buttonAddAll(buttonHeight)]-|"
                                             options:NSLayoutFormatAlignAllCenterY
                                             metrics:metrics
                                               views:views]];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.buttonAddAll removeFromSuperview];
    self.buttonAddAll = nil;
    self.listToAddTo = nil;
    self.thumbnail.image = nil;
}

- (void)toggleListInclusion {
    OOAPI *api =[[OOAPI alloc] init];
    __weak ListTVCell *weakSelf = self;
    
    if (_onList) {
        //remove from list
        [api deleteRestaurant:_restaurantToAdd.restaurantID fromList:_list.listID success:^(NSArray *lists) {
            [weakSelf getListsForRestaurant];
            OOAPI *apiInner = [[OOAPI alloc] init];
            [apiInner getList:_list.listID success:^(ListObject *list) {
                weakSelf.list.numRestaurants = list.numRestaurants;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ;
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRestaurantListsNeedsUpdate object:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    } else {
        //add to list
        [OOAPI addRestaurants:@[_restaurantToAdd] toList:_list.listID success:^(id response) {
            [weakSelf getListsForRestaurant];
            OOAPI *apiInner = [[OOAPI alloc] init];
            [apiInner getList:_list.listID success:^(ListObject *list) {
                weakSelf.list.numRestaurants = list.numRestaurants;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ;
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRestaurantListsNeedsUpdate object:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
}

- (void)setLists:(NSArray *)lists {
    if (_lists == lists) return;
    _lists = lists;
    [self updateAddButton];
}

- (void)getListsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak ListTVCell *weakSelf = self;
    
    UserObject *userInfo = [Settings sharedInstance].userObject;

    [api getListsOfUser:userInfo.userID
         withRestaurant:_restaurantToAdd.restaurantID
             includeAll:YES
                success:^(NSArray *foundLists) {
                    NSLog (@" number of lists for this user: %ld", (long) foundLists.count);
                    ON_MAIN_THREAD( ^{
                        weakSelf.lists = foundLists;
                    });
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                    NSLog  (@" error while getting lists for user:  %@",e);
                }];
}

- (void)updateAddButton {
    if (!_list || !_lists) return;
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
    [self.actionButton setTitle:((_onList) ? kFontIconCheckmark : @"") forState:UIControlStateNormal];
}

- (void)setList:(ListObject *)list {
    if (list == _list) return;
    _list = list;
    
    [self updateAddButton];
    
    //self.thumbnail.image = nil;
    self.header.text = [_list listName];
    [self updateRestaurantCount];
    
    if (_restaurantToAdd) {
        self.actionButton.hidden = NO;
        [self.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.actionButton addTarget:self action:@selector(toggleListInclusion) forControlEvents:UIControlEventTouchUpInside];
//        [self getListsForRestaurant];
    } else if (_listToAddTo) {
        self.actionButton.hidden = NO;
        [self.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.actionButton addTarget:self action:@selector(addAllRestaurantsFromList) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.actionButton.hidden = YES;
    }

    //get the list's image
    OOAPI *api = [[OOAPI alloc] init];

    if (_list.mediaItem && !self.thumbnail.image) {
        __weak UIImageView *weakIV = self.thumbnail;
        __weak ListTVCell *weakSelf = self;
        
        self.requestOperation = [api getRestaurantImageWithImageRef:_list.mediaItem.reference maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            [self.thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                    placeholderImage:nil
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 ON_MAIN_THREAD(^ {
                                                     [weakIV setAlpha:0.0];
                                                     weakIV.image = image;
                                                     [UIView beginAnimations:nil context:NULL];
                                                     [UIView setAnimationDuration:0.3];
                                                     [weakIV setAlpha:1.0];
                                                     [UIView commitAnimations];
                                                     [weakSelf setNeedsUpdateConstraints];
                                                     [weakSelf setNeedsLayout];
                                                 });
                                             }
                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 ;
                                             }];            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }

}

- (void)updateRestaurantCount {
    if (_list.numRestaurants == 1) {
        self.subHeader1.text = [NSString stringWithFormat:@"%lu restaurant", (unsigned long)_list.numRestaurants];
    } else if (_list.numRestaurants) {
        self.subHeader1.text = [NSString stringWithFormat:@"%lu restaurants", (unsigned long)_list.numRestaurants];
    } else {
        self.subHeader1.text = @"";
    }
}

- (void)addAllRestaurantsFromList {
    OOAPI *api = [[OOAPI alloc] init];
    [api getRestaurantsWithListID:_list.listID
                          andLocation:[LocationManager sharedInstance].currentUserLocation
                          success:^(NSArray *restaurants) {
        [OOAPI addRestaurants:restaurants toList:_listToAddTo.listID success:^(id response) {
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

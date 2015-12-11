//
//  ListTVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 10/1/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ObjectTVCell.h"
#import "ListObject.h"

@protocol ListTVCellDelegate
- (void) userPressedAddAllForList: (ListObject*)list;

@end

@interface ListTVCell : ObjectTVCell

@property (nonatomic, strong) ListObject *list;
@property (nonatomic) BOOL onList;

- (void) addTheAddAllButton;


@property (nonatomic, strong) RestaurantObject *restaurantToAdd;
@property (nonatomic, strong) ListObject *listToAddTo;

@property (nonatomic,weak) id <ListTVCellDelegate>delegate;
@end

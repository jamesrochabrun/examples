//
//  SearchVC.h
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"
#import "ListObject.h"
#import "EventObject.h"
#import "ViewPhotoVC.h"
#import "RestaurantTVCell.h"
//#import "OptionsVC.h"
//#import "ChangeLocationVC.h"

@interface SearchVC : BaseVC <UITableViewDataSource,
                                UITableViewDelegate,
                                //OptionsVCDelegate,
                                //ChangeLocationVCDelegate,
                                ViewPhotoVCDelegate,
                                UISearchBarDelegate,
                                UINavigationControllerDelegate,
                                UIViewControllerTransitioningDelegate,
                                ObjectTVCellDelegate>

@property (nonatomic, strong) ListObject *listToAddTo;
@property (nonatomic, strong) EventObject *eventBeingEdited;

- (void)getRestaurants;

@end


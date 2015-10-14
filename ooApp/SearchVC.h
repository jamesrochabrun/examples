//
//  SearchVC.h
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface SearchVC : BaseVC <UISearchBarDelegate>
@property (nonatomic,assign) BOOL addingRestaurantsToEvent;
@end


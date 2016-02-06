//
//  SearchVC.h
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "EventObject.h"
#import "UserTVCell.h"
//#import "OOTextEntryModalVC.h"
#import "ChangeLocationVC.h"

@interface SearchVC : BaseVC <UISearchBarDelegate, UserTVCellDelegate, ChangeLocationVCDelegate>
@property (nonatomic,strong) EventObject *eventBeingEdited;

@end


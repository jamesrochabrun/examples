//
//  DropDownListTVC.h
//  ooApp
//
//  Created by Anuj Gujar on 11/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropDownListTVC;

@protocol DropDownListTVCDelegate

- (void)dropDownList:(DropDownListTVC *)dropDownList optionTapped:(id)object;

@end

@interface DropDownListTVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSUInteger currentOptionID;
@property (nonatomic, weak) id<DropDownListTVCDelegate> delegate;

- (void)scrollToCurrent;

@end

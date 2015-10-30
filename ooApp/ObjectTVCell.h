//
//  ObjectTVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OOAPI.h"
#import "UIImageView+AFNetworking.h"

@interface ObjectTVCell : UITableViewCell

@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *header;
@property (nonatomic, strong) UILabel *subHeader1;
@property (nonatomic, strong) UILabel *subHeader2;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UIButton *actionButton;

- (void)hideShadow;
- (void)showShadow;

@end

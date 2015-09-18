//
//  HorizonalTVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "HorizonalTVCell.h"

@interface HorizonalTVCell ()

@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UILabel *header;
@property (nonatomic, strong) UILabel *subHeader1;
@property (nonatomic, strong) UILabel *subHeader2;

@end

@implementation HorizonalTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

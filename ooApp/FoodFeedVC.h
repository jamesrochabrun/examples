//
//  FoodFeedVC.h
//  ooApp
//
//  Created by Anuj Gujar on 12/16/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "BaseVC.h"
#import "FoodFeedVCCVL.h"
#import "PhotoCVCell.h"
#import "RestaurantPickerTVC.h"

@interface FoodFeedVC : BaseVC <FoodFeedVCCollectionViewDelegate, UICollectionViewDataSource, PhotoCVCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RestaurantPickerTVCDelegate>

- (void)selectAll;

@end

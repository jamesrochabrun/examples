//
//  PhotoCVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 10/14/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItemObject.h"

@class PhotoCVCell;

@protocol PhotoCVCellDelegate
- (void)photoCell:(PhotoCVCell *)photoCell deletePhoto:(MediaItemObject *)mio;
- (void)photoCell:(PhotoCVCell *)photoCell showPhotoOptions:(MediaItemObject *)mio;
@end

@interface PhotoCVCell : UICollectionViewCell

@property (nonatomic, strong) MediaItemObject *mediaItemObject;
@property (nonatomic, weak) id<PhotoCVCellDelegate> delegate;

- (void)showActionButton:(BOOL)show;
@end

//
//  AddCaptionToMIOVC.h
//  ooApp
//
//  Created by Anuj Gujar on 1/3/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "OOTextEntryVC.h"
#import "MediaItemObject.h"

@interface AddCaptionToMIOVC : OOTextEntryVC

@property (nonatomic, strong) MediaItemObject *mio;

- (void)overrideIsFoodWith:(BOOL)isFood;

@end

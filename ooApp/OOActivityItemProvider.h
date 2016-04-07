//
//  OOActivityItemProvider.h
//  ooApp
//
//  Created by Anuj Gujar on 10/27/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantObject.h"
#import "MediaItemObject.h"
#import "ListObject.h"

@interface OOActivityItemProvider : UIActivityItemProvider <UIActivityItemSource>


@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, strong) ListObject *list;
@property (nonatomic, strong) MediaItemObject *mio;

@end

@interface OOActivityIcon : UIActivity

@end

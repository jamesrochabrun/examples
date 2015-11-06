//
//  EventTVCell.h
//  ooApp
//
//  Created by Zack Smith on 10/5/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ObjectTVCell.h"
#import "EventObject.h"
#import "OOStripHeader.h"
#import "ParticipantsView.h"

@protocol EventTVCellDelegate <NSObject>
- (void) userTappedOnProfilePicture: (NSUInteger)userid;
@end

@interface EventTVCell : ObjectTVCell <ParticipantsViewDelegate>

- (void)setEvent:(EventObject *)eo;
- (void)updateHighlighting:(BOOL)highlighted;
- (void)setIsFirst;
- (void)setMessageMode:(NSString *)message;

@property (nonatomic,strong) OOStripHeader *nameHeader;
@property (nonatomic,assign) id <EventTVCellDelegate> delegate;
@end

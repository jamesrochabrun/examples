#import "EventObject.h"

@protocol ParticipantsViewDelegate
- (void) userPressedButtonForProfile: (NSUInteger)userid;
@end

@interface ParticipantsView:UIView
- (void)clearFaces;
- (void) setEvent: (EventObject*)event;
@property (nonatomic,weak) id <ParticipantsViewDelegate> delegate;
@end

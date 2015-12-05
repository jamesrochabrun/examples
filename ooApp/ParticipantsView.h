#import "EventObject.h"
#import "OOUserView.h"

@protocol ParticipantsViewDelegate
- (void) userPressedButtonForProfile: (NSUInteger)userid;
@end

@interface ParticipantsView:UIView <OOUserViewDelegate>
- (void)clearFaces;
- (void) setEvent: (EventObject*)event;
@property (nonatomic,weak) id <ParticipantsViewDelegate> delegate;
@end

#import "ParticipantsView.h"

@interface ParticipantsView()
@property (nonatomic,strong) EventObject*event;

@property (nonatomic,strong) NSMutableArray* viewsForFaces;
@property (nonatomic,strong)  UILabel* labelEllipsis;
@end

@implementation ParticipantsView

- (instancetype) init
{
    self = [super init];
    if (self) {
        _labelEllipsis= makeLabel(self,  @"...", kGeomFontSizeHeader);

//        self.backgroundColor= YELLOW;
    }
    return self;
}

- (void) setEvent: (EventObject*)event
{
    if  (!event) {
        return;
    }
    
    _event= event;
    
    if  ([self.event totalUsers ] ) {
        if (_viewsForFaces ) {
            for (UIView* v  in  _viewsForFaces) {
                [v removeFromSuperview];
            }
            [self.viewsForFaces removeAllObjects];
        }
        float availableWidth= self.frame.size.width;
        if  (!availableWidth) {
            return;
        }
        NSInteger nBubbles= (availableWidth-2*kGeomSpaceEdge)/(kGeomFaceBubbleDiameter +kGeomFaceBubbleSpacing);
        self.viewsForFaces= makeImageViewsForUsers (self, event.users, nBubbles);
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [ super layoutSubviews];
    
    if ( self.viewsForFaces.count) {
        float w= self.frame.size.width;
        NSUInteger count=self.viewsForFaces.count;
        NSUInteger totalPeople=  [self.event totalUsers ];
        float y=kGeomSpaceEdge;
        float x= (w-count*kGeomFaceBubbleDiameter-(count-1)*kGeomFaceBubbleSpacing)/2;
        NSInteger i= 0;
        for (UIImageView*iv  in self.viewsForFaces) {
            if  (i >= _viewsForFaces.count-1  && _viewsForFaces.count < totalPeople  ) {
                _labelEllipsis.frame=CGRectMake(x, y, kGeomFaceBubbleDiameter, kGeomFaceBubbleDiameter);
                iv.frame= CGRectZero;
            } else {
                iv.frame= CGRectMake(x, y, kGeomFaceBubbleDiameter, kGeomFaceBubbleDiameter);
                _labelEllipsis.frame=CGRectZero;
            }
            x+= kGeomFaceBubbleDiameter+kGeomFaceBubbleSpacing;
            i++;
        }
    }

}

@end

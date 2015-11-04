
#import "PieView.h"

@interface PieView  ()
@property (nonatomic,assign) NSUInteger hour;
@end

@implementation PieView

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.backgroundColor= WHITE;
        self.opaque= YES;
        self.layer.borderColor= BLACK.CGColor;
        self.layer.borderWidth= 2;
    }
    return self;
    
}

- (void)drawRect: (CGRect) rect
{
    [ super  drawRect: rect];
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor (context, 0,0,0, 0);

    float  radius= w/2;
    CGContextBeginPath (context);
    CGContextMoveToPoint (context, w/2,h/2);
    CGContextAddLineToPoint (context, w/2,0);
    float  angle= (_hour%12)/12. * M_PI *2 ;
    CGContextAddArc (context, w/2, h/2, radius, -M_PI/2, angle-M_PI/2, YES);
    CGContextAddLineToPoint (context, w/2, h/2);

    CGContextSetRGBFillColor (context, 0,0,0, 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

- (void) setHour:(NSUInteger)h;
{
    _hour=h;
    [self setNeedsDisplay];
}
@end

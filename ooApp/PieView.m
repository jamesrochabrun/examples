
#import "PieView.h"

@interface PieView  ()
@property (nonatomic,assign) NSUInteger hour;
@end

@implementation PieView

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.backgroundColor= UIColorRGBA(kColorClear);
        self.layer.borderColor= UIColorRGBA(kColorBlack).CGColor;
        self.layer.borderWidth= 1;
    }
    return self;
    
}

- (void)drawRect: (CGRect) rect
{
    [ super  drawRect: rect];

    float w= self.frame.size.width;
    float h= self.frame.size.height;
    float  radius= w/2;
    
    self.layer.cornerRadius= radius;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath (context);
    CGContextSetRGBFillColor (context, 1,1,0, 1);
    CGContextAddArc (context, w/2, h/2, radius, 0, M_PI*2, YES);
    CGContextClosePath(context);
    CGContextFillPath(context);

    CGContextBeginPath (context);
    CGContextMoveToPoint (context, w/2,h/2);
    CGContextAddLineToPoint (context, w/2,0);
    float  angle= (_hour%12)/12. * M_PI *2 ;
    if ( angle == 0) {
        angle= -.025;// @12pm/am Create an upward line.
    }
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

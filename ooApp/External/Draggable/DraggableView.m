//
//  DraggableView.m
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle


#import "DraggableView.h"
#import "OOAPI.h"

@interface DraggableView ()
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) NSArray *mediaItems;
@end

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize overlayView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        
        _name = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.frame.size.width, 100)];
        _name.text = @"no info given";
        [_name setTextAlignment:NSTextAlignmentCenter];
        _name.textColor = UIColorRGBA(kColorWhite);
        _name.translatesAutoresizingMaskIntoConstraints = NO;
        
        _thumbnail = [[UIImageView alloc] init];
        _thumbnail.backgroundColor = UIColorRGBA(kColorBlack);
        _thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        _thumbnail.clipsToBounds = YES;
        _thumbnail.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.backgroundColor = UIColorRGBA(kColorOffBlack);
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        
        [self addGestureRecognizer:panGestureRecognizer];
        [self addSubview:_name];
        [self addSubview:_thumbnail];
        
        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 0, 100, 100)];
        overlayView.alpha = 0;
        [self addSubview:overlayView];
        //self.clipsToBounds = YES;
    }
    return self;
}

-(void)setupView
{
    self.layer.cornerRadius = kGeomCornerRadius;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

//- (void)updateConstraints {
//    [super updateConstraints];
//    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"imageWidth":@(120), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter":@(kGeomSpaceInter), @"spaceInterX2":@(2*kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"iconButtonDimensions":@(kGeomDimensionsIconButton), @"actionButtonWidth":@((width(self)- 2*kGeomSpaceInter)/3)};
//    
//    UIView *superview = self;
//    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _name, _thumbnail);
//    
//    // Vertical layout - note the options for aligning the top and bottom of all views
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[_name(30)]-(>=spaceInter)-[_thumbnail]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_thumbnail]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_name]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    
//    //name line
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_name
//                         attribute:NSLayoutAttributeCenterX
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:self
//                         attribute:NSLayoutAttributeCenterX
//                         multiplier:1
//                         constant:0]];
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_thumbnail
//                         attribute:NSLayoutAttributeCenterY
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:self
//                         attribute:NSLayoutAttributeCenterY
//                         multiplier:1
//                         constant:0]];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout];
}

- (void)updateLayout {
    CGRect frame;
    
    frame = _name.frame;
    frame.origin = CGPointMake(0, 0);
    frame.size = CGSizeMake(width(self) - 20, 100);
    _name.frame = frame;
    
    frame = _thumbnail.frame;
    frame.origin = CGPointMake(0, CGRectGetMaxY(_name.frame));
    frame.size = CGSizeMake(width(self), height(self) - frame.origin.y);
    _thumbnail.frame = frame;
    
    NSLog(@"selfFrame=%@, tnFrame=%@, nameFrame=%@", NSStringFromCGRect(self.frame), NSStringFromCGRect(_thumbnail.frame), NSStringFromCGRect(_name.frame));
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
- (void)updateOverlay:(CGFloat)distance
{
//    CGRect frame = overlayView.frame;
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
//        frame.origin = CGPointMake(width(self) - width(overlayView) -  20, 20);
    } else {
        overlayView.mode = GGOverlayViewModeLeft;
//        frame.origin = CGPointMake(20, 20);
    }
//    overlayView.frame = frame;
    
    overlayView.center = self.center;
    
    overlayView.alpha = MIN(fabs(distance)/100, 0.9);
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
- (void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
- (void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"TODO: add to don't show again list");
}

- (void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     } completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"TODO: add to wish list");
}

- (void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     } completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
    _name.text = restaurant.name;
    [self getRestaurant];
}

- (void)getRestaurant {
    __weak DraggableView *weakSelf = self;
    OOAPI *api = [[OOAPI alloc] init];
    
    [api getRestaurantWithID:_restaurant.googleID source:kRestaurantSourceTypeGoogle success:^(RestaurantObject *restaurant) {
        _restaurant = restaurant;
        ON_MAIN_THREAD(^ {
            [weakSelf updateCard:restaurant];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)getMediaItemsForRestaurant {
    OOAPI *api =[[OOAPI alloc] init];
    __weak DraggableView *weakSelf = self;
    [api getMediaItemsForRestaurant:_restaurant success:^(NSArray *mediaItems) {
        _mediaItems = mediaItems;
        ON_MAIN_THREAD(^{
            [weakSelf gotMediaItems];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)gotMediaItems {
    OOAPI *api = [[OOAPI alloc] init];
    __weak UIImageView *weakIV  = _thumbnail;
    __weak DraggableView *weakSelf = self;
    
    if ([_mediaItems count]) {
        MediaItemObject *mio = [_mediaItems objectAtIndex:0];
        _requestOperation = [api getRestaurantImageWithMediaItem:mio maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                        placeholderImage:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                     weakIV.image = image;

                                                     ON_MAIN_THREAD(^ {
                                                         [weakSelf setNeedsUpdateConstraints];
                                                         [weakSelf setNeedsLayout];
                                                     });
                                                 }
                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                     ON_MAIN_THREAD(^ {
                                                         weakIV.image = [UIImage imageNamed:@"background-image.jpg"];
                                                         [weakSelf setNeedsUpdateConstraints];
                                                         [weakSelf setNeedsLayout];
                                                     });
                                                 }];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ON_MAIN_THREAD(^ {
                weakIV.image = [UIImage imageNamed:@"background-image.jpg"];
                [weakSelf setNeedsUpdateConstraints];
                [weakSelf setNeedsLayout];
            });
        }];
    } else {
        _thumbnail.image = [UIImage imageNamed:@"background-image.jpg"];
    }
}

- (void)updateCard:(id)object {
    if ([object isKindOfClass:[RestaurantObject class]]) {
        RestaurantObject *r = (RestaurantObject *)object;
        [self getMediaItemsForRestaurant];
    }
    
}


@end

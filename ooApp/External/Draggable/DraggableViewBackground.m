//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "OOAPI.h"
#import "LocationManager.h"
#import "RestaurantVC.h"
#import "RestaurantObject.h"
#import "TagObject.h"

@interface DraggableViewBackground ()

@property (nonatomic, strong) NSArray *playItems;
@property (nonatomic, strong) UIButton *xButton;
@property (nonatomic, strong) UIButton *tryButton;
@property (nonatomic, strong) NSArray *tags;

- (void)gotPlayItems;

@end

@implementation DraggableViewBackground {
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
}

//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1

@synthesize allCards; //%%% all the cards

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        
        __weak DraggableViewBackground *weakSelf = self;
        [OOAPI getTagsForUser:0 success:^(NSArray *tags) {
            _tags = tags;
            ON_MAIN_THREAD(^{
                [weakSelf getPlayItems:nil];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
    return self;
}

- (void)getPlayItems:(TagObject *)tag {
    
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak DraggableViewBackground *weakSelf = self;
    

    NSMutableArray *keywords = [NSMutableArray array];
    u_int32_t count = (u_int32_t)[_tags count];

    TagObject *to; //choose three terms
    to = [_tags objectAtIndex:(NSUInteger)arc4random_uniform(count) % count];
    [keywords addObject:to.term];
    to = [_tags objectAtIndex:(NSUInteger)arc4random_uniform(count) % count];
    [keywords addObject:to.term];
    to = [_tags objectAtIndex:(NSUInteger)arc4random_uniform(count) % count];
    [keywords addObject:to.term];
    
    CGFloat radius = (NSUInteger)arc4random_uniform(20000) % 20000 + 2500; //choose value between 2500 and 22500;
    
    [api getRestaurantsWithKeywords:keywords
                        andLocation:[[LocationManager sharedInstance] currentUserLocation]
                          andFilter:@""
                          andRadius:radius
                        andOpenOnly:NO
                            andSort:kSearchSortTypeBestMatch
                           minPrice:0
                           maxPrice:3
                             isPlay:YES
                            success:^(NSArray *r) {
                                weakSelf.playItems = r;
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf gotPlayItems];
                                });
                            } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
                                ;
                            }];
}

- (void)gotPlayItems {
    [self unloadCards];
    [self loadCards];
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
    self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);

    _xButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_xButton withIcon:kFontIconRemove fontSize:kGeomPlayIconSize width:kGeomPlayButtonSize height:kGeomPlayButtonSize backgroundColor:kColorClear
               target:self selector:@selector(swipeLeft)];
    [_xButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];

    _tryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_tryButton withIcon:kFontIconToTry fontSize:kGeomPlayIconSize width:kGeomPlayButtonSize height:kGeomPlayButtonSize backgroundColor:kColorClear
               target:self selector:@selector(swipeRight)];
    [_tryButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
    
    _xButton.translatesAutoresizingMaskIntoConstraints = _tryButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    _tryButton.layer.borderColor = _xButton.layer.borderColor = UIColorRGBA(kColorYellow).CGColor;
    _tryButton.layer.borderWidth = _xButton.layer.borderWidth = 1;
    
    [self addSubview:_xButton];
    [self addSubview:_tryButton];
}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    CGFloat cardWidth = width(self) - 30, cardHeight = height(self) - kGeomPlayButtonSize - 50;
    
    DraggableView *draggableView = [[DraggableView alloc] initWithFrame:CGRectMake((self.frame.size.width - cardWidth)/2, 15, cardWidth, cardHeight)];
//    draggableView.restaurant = ((RestaurantObject *)[_playItems objectAtIndex:index]);
    draggableView.delegate = self;

    return draggableView;
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonDimensions":@(kGeomPlayButtonSize)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _xButton, _tryButton);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_xButton(buttonDimensions)]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tryButton(buttonDimensions)]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_xButton(buttonDimensions)]-(>=0)-[_tryButton(buttonDimensions)]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_infoButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_xButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_infoButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if ([_playItems count] > 0) {
        NSInteger numLoadedCardsCap =(([_playItems count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[_playItems count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[_playItems count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                newCard.restaurant = ((RestaurantObject *)[_playItems objectAtIndex:i]);
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _xButton.layer.cornerRadius = width(_xButton)/2;
    _tryButton.layer.cornerRadius = width(_tryButton)/2;
}

- (void)unloadCards {
    [allCards removeAllObjects];
    [loadedCards enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DraggableView *dv = (DraggableView *)obj;
        [dv removeFromSuperview];
    }];
    [loadedCards removeAllObjects];
}

//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    
    OOAPI *api = [[OOAPI alloc] init];
    if (c.restaurant) {
        [api addRestaurantsToSpecialList:@[c.restaurant] listType:kListTypeNotNow success:^(id response) {
            NSLog(@"%@ added to notnow", c.restaurant.name);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Could not add %@ to notnow: %@", c.restaurant.name, error);
        }];
    }
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        DraggableView *card = [allCards objectAtIndex:cardsLoadedIndex];
        card.restaurant = (RestaurantObject *)[_playItems objectAtIndex:cardsLoadedIndex];
        [loadedCards addObject:card];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
}

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    
    OOAPI *api = [[OOAPI alloc] init];
    if (c.restaurant) {
        [api addRestaurantsToSpecialList:@[c.restaurant] listType:kListTypeToTry success:^(id response) {
            NSLog(@"%@ added to wishlist", c.restaurant.name);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Could not add %@ to wishlist: %@", c.restaurant.name, error);
        }];
    }
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        DraggableView *card = [allCards objectAtIndex:cardsLoadedIndex];
        card.restaurant = (RestaurantObject *)[_playItems objectAtIndex:cardsLoadedIndex];
        [loadedCards addObject:card];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
    //TODO Add to wishlist

}

- (void)showCurrentObject {
    DraggableView *card = [loadedCards objectAtIndex:0];
    
    if (card.restaurant) {
        RestaurantVC *vc = [[RestaurantVC alloc] init];
        ANALYTICS_EVENT_UI(@"RestaurantVC-from-Draggable");
        vc.restaurant = card.restaurant;
        [_presentingVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)cardTapped:(DraggableView *)draggableView withObject:(id)object {
    if ([object isKindOfClass:[RestaurantObject class]]) {
        RestaurantVC *vc = [[RestaurantVC alloc] init];
        ANALYTICS_EVENT_UI(@"RestaurantVC-from-Draggable");
        vc.restaurant = (RestaurantObject*)object;
        [_presentingVC.navigationController pushViewController:vc animated:YES];
    }
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

@end

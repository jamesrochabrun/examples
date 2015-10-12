//
//  EventParticipantVC.m
//  ooApp
//
//  Created by Zack S on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "EventParticipantVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"
#import "ListTVCell.h"
#import "EventWhenVC.h"

@interface EventParticipantVC ()
@property (nonatomic,strong)  UIButton* buttonSubmitVote;
@property (nonatomic,strong)  UITableView * table;
@property (nonatomic,strong)  UILabel* label;
@end

@implementation EventParticipantVC
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: _eventName ?:  @"MISSING EVENT NAME" subHeader:  nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= [UIColor lightGrayColor];
    _table= makeTable( self.view,  self);
#define TABLE_REUSE_IDENTIFIER  @"participantsCell"  
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:TABLE_REUSE_IDENTIFIER];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    _label= makeLabelLeft( self.view,  @"THIS IS A TEMPORARY SCREEN", 12);
    _buttonSubmitVote= makeButton(self.view,  @"SUBMIT\rVOTE", kGeomFontSizeHeader,
                                  BLACK, CLEAR, self, @selector(doSubmitVote:), 1);
}

- (void) userPressedCancel: (id) sender
{
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

//------------------------------------------------------------------------------
// Name:    doSubmitVote
// Purpose:
//------------------------------------------------------------------------------
- (void)doSubmitVote: (id) sender
{
    message( @"you pressed submit.");
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose:
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    float spacing= kGeomSpaceEdge;
    
    _table.frame=  self.view.bounds;
#define kGeomEventParticipantBoxHeight 175
#define kGeomEventParticipantRestaurantHeight 100
    
    _buttonSubmitVote.frame=  CGRectMake((w-kGeomButtonWidth)/2,kGeomEventParticipantBoxHeight-kGeomHeightButton-margin,kGeomButtonWidth,kGeomHeightButton);
    
    _label.frame = CGRectMake(0,0,w, 40);

}

@end

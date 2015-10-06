//
//  EventCoordinatorVC.m
//  ooApp
//
//  Created by Zack S on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "EventCoordinatorVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"

@interface EventCoordinatorVC ()
@property (nonatomic,strong)  UIButton* buttonSubmit;
@property (nonatomic,strong)  UITableView* table;
@end

@implementation EventCoordinatorVC
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: _eventName ?:  @"MISSING EVENT NAME" subHeader:  nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= [UIColor lightGrayColor];
    _table= makeTable(self.view,  self);
    
#define TABLE_REUSE_IDENTIFIER  @"eventCoordinator"
    [_table registerClass: [UITableViewCell class] forCellReuseIdentifier:TABLE_REUSE_IDENTIFIER];
    self.automaticallyAdjustsScrollViewInsets= NO;
    
    _buttonSubmit= makeButton(self.view,  @"SUBMIT EVENT", kGeomFontSizeHeader, RED, CLEAR, self, @selector(doSubmit:), 1);
    _buttonSubmit.titleLabel.numberOfLines= 0;
    _buttonSubmit.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    self.navigationItem.rightBarButtonItem= [[UIBarButtonItem  alloc] initWithTitle: @"CANCEL"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action: @selector(userPressedCancel:)];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

//------------------------------------------------------------------------------
// Name:    doClearCache
// Purpose:
//------------------------------------------------------------------------------
- (void)doClearCache: (id) sender
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    if  ([UIImageView respondsToSelector:@selector(sharedImageCache)] ) {
        id foo = [UIImageView sharedImageCache];
        if  (foo ) {
            if  ([foo respondsToSelector:@selector( removeAllObjects)] ) {
                [ foo performSelector:@selector( removeAllObjects) withObject:nil];
            }
        }
    }
    
    message( @"cache cleared.");
}

//------------------------------------------------------------------------------
// Name:    doSubmit
// Purpose:
//------------------------------------------------------------------------------
- (void)doSubmit: (id) sender
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

    _table.frame=  self.view.bounds;
    
    float x=  margin, y=  margin;
    _buttonSubmit.frame=  CGRectMake(w-kGeomButtonWidth,y,kGeomButtonWidth,kGeomHeightButton);
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell=  [[UITableViewCell  alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:TABLE_REUSE_IDENTIFIER ];
    }
    NSString* name= nil;
    NSInteger row= indexPath.row;
   
    cell.textLabel.text= name;
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return LOCAL(@"Testing...");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* name= nil;
    NSInteger row= indexPath.row;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

@end

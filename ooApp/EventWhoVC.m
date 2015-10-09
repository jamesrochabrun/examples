//
//  EventWhoVC.m
//  ooApp
//
//  Created by Zack Smith on 10/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "EventWhoVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"

@interface  EventWhoTableCell ()
@property (nonatomic,strong) UIButton *radioButton;
@property (nonatomic,strong)  UILabel *labelName;
@property (nonatomic,strong)  UIImageView *imageViewThumbnail;
@end

@implementation EventWhoTableCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        _radioButton= makeButton(self,  @"NO", kGeomFontSizeDetail, BLACK, GREEN, self, @selector(userPressRadioButton:), 0);
        [_radioButton setTitle:  @"YES" forState:UIControlStateSelected];
        
        _imageViewThumbnail= makeImageView(self,  @"No-Profile_Image.png");
        _imageViewThumbnail.layer.borderWidth= 1;
        _imageViewThumbnail.layer.borderColor= GRAY.CGColor;
        
        _labelName= makeLabelLeft(self, nil, kGeomFontSizeHeader);
        
        self.textLabel.hidden= YES;
        self.imageView.hidden= YES;
    }
    return self;
}

- (void)prepareForReuse
{
    _labelName.text= nil;
    _imageViewThumbnail.image=  nil;
    _radioButton.selected= NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    float x= 0;
    _imageViewThumbnail.frame = CGRectMake(x,0,h,h); x += h;
    _labelName.frame = CGRectMake(x,0,w-x-kGeomButtonWidth,h);
    _radioButton.frame = CGRectMake(w-kGeomButtonWidth,0,kGeomButtonWidth,h);
    
}

- (void)setName: (NSString*)string
{
    self.labelName.text= string;
}

- (void)userPressRadioButton: (id) sender
{
    message( @"you pressed the radio button");
}

@end

@interface EventWhoVC ()
@property (nonatomic,strong)UILabel* labelEventDateHeader;
@property (nonatomic,strong)UIButton* buttonAddEmail;
@property (nonatomic,strong)UITableView* table;
@property (nonatomic,strong)UIButton* buttonInvite;
@property (nonatomic,strong) NSMutableArray *arrayOfParticipants;
@end

@implementation EventWhoVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    self.view.autoresizesSubviews= NO;
    
    self.arrayOfParticipants= [NSMutableArray new];
    [_arrayOfParticipants addObject:  @"first"];
    [_arrayOfParticipants addObject:  @" second"];
    [_arrayOfParticipants addObject:  @" third"];
    [_arrayOfParticipants addObject:  @" fourth"];
    [_arrayOfParticipants addObject:  @"someone@someplace.net"];
    [_arrayOfParticipants addObject:  @"sjobs@Apples.com"];

    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"INVITE TO EVENT" subHeader: nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= WHITE;

    self.labelEventDateHeader= makeLabel( self.view,  @"WHEN IS THIS?", kGeomFontSizeHeader);
    self.buttonAddEmail=makeButton(self.view, @"INVITE BY EMAIL", kGeomFontSizeHeader,  BLACK, CLEAR,
                                    self, @selector(userPressedInviteByEmail:), 1);
    self.buttonInvite=makeButton(self.view, @"INVITE", kGeomFontSizeHeader,  BLACK, CLEAR,
                                    self, @selector(userPressedInvite:), 2);
    
    self.table= makeTable( self.view,  self);
#define PARTICIPANTS_TABLE_REUSE_IDENTIFIER  @"whomToInviteCell"
    [_table registerClass:[EventWhoTableCell class] forCellReuseIdentifier:PARTICIPANTS_TABLE_REUSE_IDENTIFIER];
    
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem  alloc]
                                            initWithTitle: @"BACK"
                                            style:UIBarButtonItemStylePlain
                                            target: self
                                            action:@selector(userPressedBack:)];
    
    //  fetch the usernames from the backend..
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

- (void)userPressedBack: (id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userPressedInviteByEmail: (id) sender
{
}

- (void)userPressedInvite: (id) sender
{
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    float  spacing=  kGeomSpaceInter;

    float  y=  0;

    float tableHeight= h-2*kGeomHeightButton- 2*spacing;
    _table.frame = CGRectMake(0,y,w,tableHeight);
    y+= tableHeight+ spacing;
    _buttonAddEmail.frame = CGRectMake(margin,y,w-2*margin, kGeomHeightButton);
    y += kGeomHeightButton+ spacing;
    _buttonInvite.frame = CGRectMake((w-kGeomButtonWidth)/2,y,kGeomButtonWidth,kGeomHeightButton);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventWhoTableCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:PARTICIPANTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
 
    NSString* name= nil;
    NSInteger row= indexPath.row;
    @synchronized(_arrayOfParticipants) {
        if  (row  < _arrayOfParticipants.count) {
            name=  _arrayOfParticipants[row];
        }
    }
    
    [cell setName: name];
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return LOCAL(@"Choose who should attend:");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightButton;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* name= nil;
    NSInteger row= indexPath.row;
    @synchronized(_arrayOfParticipants) {
        if  ( row  < _arrayOfParticipants.count) {
            name=  _arrayOfParticipants[row];
        }
    }
    if ( name) {
//        _fieldUsername.text= name;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  total;
    @synchronized(_arrayOfParticipants) {
        total= _arrayOfParticipants.count;
    }
    return  total;
}


@end

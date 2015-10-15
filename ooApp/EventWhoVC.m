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
#import "GroupObject.h"
#import "EventWhoVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"
#import "GroupObject.h"

@interface  EventWhoTableCell ()
@property (nonatomic,strong) UIButton *radioButton;
@property (nonatomic,strong)  UILabel *labelName;
@property (nonatomic,strong)  UIImageView *imageViewThumbnail;
@property (nonatomic,strong) UserObject* user;
@property (nonatomic,strong) GroupObject* group;
@property (nonatomic,strong) NSString *imageIdentifierString;
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@end

@implementation EventWhoTableCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        _radioButton= makeButton(self,  @"NO", kGeomFontSizeDetail, RED, CLEAR, self, @selector(userPressRadioButton:), 0);
        [_radioButton setTitle:  @"YES" forState:UIControlStateSelected];
        [_radioButton setTitleColor:GREEN forState:UIControlStateSelected];

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
    [_operation cancel];
    self.operation= nil;
    
    _labelName.text= nil;
    _imageViewThumbnail.image=  nil;
    _radioButton.selected= NO;
    self.group= nil;
    self.user= nil;
    self.imageIdentifierString= nil;
}

- (void) specifyUser:  (UserObject*)user;
{
    self.group= nil;
    self.user=  user;
    
    if  (user.firstName && [user.firstName isKindOfClass:[NSString class]]  && user.firstName.length) {
        _labelName.text= [NSString stringWithFormat: @"%@ %@",user.firstName, user.lastName];
    } else {
        _labelName.text= user.email; // NOTE: This is for the email–only case.
    }
    
    if ( user.imageIdentifier) {
        self.imageIdentifierString= user.imageIdentifier;
        self.operation= [OOAPI getUserImageWithImageID:_imageIdentifierString
                              maxWidth:0
                             maxHeight:self.frame.size.height
                               success:^(NSString *imageRefs) {
                                   ON_MAIN_THREAD( ^{
                                       [_imageViewThumbnail setImageWithURL:[NSURL URLWithString: imageRefs ]];
                                   });
                               } failure:^(NSError *e) {
                                   NSLog(@"");
                               }];
    }
}

- (void) specifyGroup:  (GroupObject*)group;
{
    self.user= nil;
    self.group=  group;
    
    if  (group.name ) {
        _labelName.text= group.name;
    } else {
        _labelName.text= [NSString stringWithFormat: @"Unnamed group #%ld", group.groupID];
    }
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

- (void) setRadioButtonState: (BOOL)isSet
{
    _radioButton.selected= isSet;
}

- (void)userPressRadioButton: (id) sender
{
    _radioButton.selected= !_radioButton.selected;
    
    if ( _viewController) {
        [_viewController radioButtonChanged:  _radioButton.selected
                                        for: _group ?: _user];
    }
}

@end

//==============================================================================

@interface EventWhoVC ()
@property (nonatomic,strong)UILabel* labelEventDateHeader;
@property (nonatomic,strong)UIButton* buttonAddEmail;
@property (nonatomic,strong)UITableView* table;
@property (nonatomic,strong)UIButton* buttonInvite;
@property (nonatomic,strong) NSMutableArray *arrayOfPotentialParticipants;
@property (nonatomic,strong)  NSMutableSet *participants;

@end

@implementation EventWhoVC

UserObject* makeEmailOnlyUserObject(NSString* email)
{
    UserObject*user= [[UserObject alloc] init];
    user.email= trimString(email);
    return  user;
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    self.view.autoresizesSubviews= NO;
    
    self.arrayOfPotentialParticipants= [NSMutableArray new];
    self.participants= [NSMutableSet new];
    
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
    
    self.navigationItem.leftBarButtonItem= nil;

    __weak EventWhoVC *weakSelf = self;
    
#if 0
    [OOAPI getGroupsWithSuccess:^(NSArray *groups) {
        //        NSLog  (@" groups for this user=  %@", groups);
        NSLog  (@"USER HAS %lu GROUPS.",groups.count);
        @synchronized(weakSelf.arrayOfPotentialParticipants) {
            for (id object in groups) {
                [self.arrayOfPotentialParticipants  addObject: object];
                [self.participants addObject:  object ];
            }
        }
        [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
    }
                        failure:^(NSError *e) {
                            NSLog (@"FAILED TO FETCH LIST OF GROUPS FOR USER.");
                        }];
#endif
    
    // RULE: Find out what users are already attached to this events.         
    [OOAPI getParticipantsInEvent:APP.eventBeingEdited
                          success:^(NSArray *users) {
                              BOOL somethingChanged= NO;
                              @synchronized(weakSelf.arrayOfPotentialParticipants) {
                                  for (UserObject* user  in  users) {
                                      if (![weakSelf.participants containsObject:user ]) {
                                          [weakSelf.participants addObject: user];
                                          somethingChanged= YES;
                                      }
                                      if (![weakSelf.arrayOfPotentialParticipants containsObject:user ]) {
                                          [weakSelf.arrayOfPotentialParticipants addObject: user];
                                          somethingChanged= YES;
                                      }
                                  }
                              }
                              if (somethingChanged ) {
                                  [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
                              }
                          } failure:^(NSError *e) {
                              NSLog (@"FAILED TO GET LIST OF EVENT PARTICIPANTS.");
                          }];
    
    // RULE: Find out more users we could potentially attach this event.
    
    [OOAPI getFollowingWithSuccess:^(NSArray *users) {
        NSLog  (@"USER IS FOLLOWING %lu USERS.",users.count);
        @synchronized(weakSelf.arrayOfPotentialParticipants) {
            for (id object in users) {
                [self.arrayOfPotentialParticipants  addObject: object];
            }
        }
        [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
    }
                           failure:^(NSError *e) {
                               NSLog (@"FAILED TO FETCH LIST OF USERS THAT USER IS FOLLOWING.");
                           }];
    
}

- (void)reloadTable
{
    @synchronized(_arrayOfPotentialParticipants) {
        [_table reloadData];
    }
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

- (void)userPressedInviteByEmail: (id) sender
{
    UIAlertView* alert= [ [UIAlertView  alloc] initWithTitle:LOCAL(@"New Participant")
                                                     message: LOCAL(@"Enter and email address")
                                                    delegate:  self
                                           cancelButtonTitle: LOCAL(@"Cancel")
                                           otherButtonTitles: LOCAL(@"Add"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

//------------------------------------------------------------------------------
// Name:    clickedButtonAtIndex
// Purpose:
//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if  (1==buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex: 0];
        NSString *string = trimString(textField.text);
        if  (string.length ) {
            string = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] uppercaseString]];
        }
        
        if (!isValidEmailAddress(string)) {
            message( @"Not a valid email address.");
            return;
        }
        
        @synchronized(_arrayOfPotentialParticipants) {
            UserObject *user= makeEmailOnlyUserObject(string);
            [_arrayOfPotentialParticipants  addObject: user];
            [_participants  addObject: user];
        }
        [_table reloadData];
    }
}

- (void) uploadParticipants
{
    
    NSMutableArray *array= [NSMutableArray new];
    for (UserObject* user  in  _participants) {
        [array addObject: user];
    }
    
    [OOAPI setParticipantsInEvent: APP.eventBeingEdited
                               to: array
                          success:^{
                              NSLog  (@"ADDED USERS TO EVENT");
                              message( @"Stored users to event.");
                          } failure:^(NSError *e) {
                              NSLog  (@"FAILED TO ADD USERS TO EVENT %@",e);
                          }];
}

- (void)userPressedInvite: (id) sender
{
    [self uploadParticipants];
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
 
    id  object= nil;
    NSInteger row= indexPath.row;
    @synchronized(_arrayOfPotentialParticipants) {
        if  (row  < _arrayOfPotentialParticipants.count) {
             object=  _arrayOfPotentialParticipants[row];
        }
    }
    
    [ cell setRadioButtonState: [_participants containsObject:  object]];

    cell.viewController=  self;
    if  ([object isKindOfClass:[GroupObject class]] ) {
        [cell specifyGroup: object];
    } else {
        [cell specifyUser: object];

    }

    return cell;
}

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSInteger numberOfSections= 1+_arrayOfGroups.count;
//    NSString *name=  @"?";
//    if  ( section==  numberOfSections-1 ) {
//        name=LOCAL(@"Test names:");
//    } else {
//        GroupObject *g= _arrayOfGroups[section];
//        name= g.name ?:  @"There is no name.";
//    }
//    return name;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightButton;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* name= nil;
    NSInteger row= indexPath.row;
    @synchronized(_arrayOfPotentialParticipants) {
        if  ( row  < _arrayOfPotentialParticipants.count) {
            name=  _arrayOfPotentialParticipants[row];
        }
    }
    if ( name) {
        //        _fieldUsername.text= name;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  total;
    @synchronized(_arrayOfPotentialParticipants) {
        total= _arrayOfPotentialParticipants.count;
    }
    return  total;
}

- (void) radioButtonChanged: (BOOL)value for: (id)object;
{
    if ( value) {
        [_participants  addObject: object];
    }else {
        [_participants  removeObject: object];
    }
    
    [self uploadParticipants];
    
    NSLog  (@" set=  %@",_participants);
}
@end

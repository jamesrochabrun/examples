//
//  EventWhoVC.m E6, E6A, E6B
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
#import "OOUserView.h"
#import "ProfileVC.h"

@interface  EventWhoTableCell ()
@property (nonatomic, strong) UIButton *radioButton;
@property (nonatomic, strong) UILabel *labelName;
@property (nonatomic, strong) UILabel *labelUserName;
@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic, strong) UserObject* user;
@property (nonatomic, strong) GroupObject* group;
@property (nonatomic, strong) NSString *imageIdentifierString;
@property (nonatomic, strong) NSString *imageURLForFacebook;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@end

@implementation EventWhoTableCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
//        _viewShadow= makeView(self, WHITE);
//        addShadowTo(_viewShadow);
        
        self.backgroundColor= UIColorRGBA(kColorOffBlack);

        _radioButton= makeButton(self, kFontIconEmptyCircle, kGeomIconSize, WHITE, CLEAR, self, @selector(userPressRadioButton:), 0);
        [_radioButton setTitle:kFontIconCheckmarkCircle forState:UIControlStateSelected];
        _radioButton.titleLabel.font= [UIFont fontWithName:kFontIcons size: kGeomFontSizeHeader];
        
        _userView=[[OOUserView alloc] init];
        [ self  addSubview: _userView];
        
        _labelName= makeLabelLeft(self, nil, kGeomFontSizeHeader);
        _labelName.textColor= WHITE;
        
        _labelUserName= makeLabelLeft(self, nil, kGeomFontSizeHeader);
        _labelUserName.textColor= WHITE;
        
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
    _labelUserName.text= nil;
    _userView.user=  nil;
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
        _labelUserName.text= [NSString stringWithFormat: @"@%@",user.username];
    } else {
        _labelName.text= user.email; // NOTE: This is for the email–only case.
        _labelUserName.text=  @"x";
    }
    
    _userView.user= user;
}

- (void) specifyGroup:  (GroupObject*)group;
{
    self.user= nil;
    self.group=  group;
    
    if  (group.name ) {
        _labelName.text= group.name;
    } else {
        _labelName.text= [NSString stringWithFormat: @"Unnamed group #%ld",(long) group.groupID];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    const float  margin= kGeomSpaceEdge;
    float y;
    float availableHeight=h-2*margin;
    
    // RULE: If this row will simply be an email address, then we completely hide the image.
    if  (!self.group && self.user && !self.user.firstName ) {
        _userView.hidden= YES;
        _viewShadow.frame = CGRectMake(margin,margin, w-kGeomSpaceEdge*2, availableHeight);
        
        _labelName.frame = CGRectMake( margin, 0,w- margin-kGeomButtonWidth, kGeomHeightEventWhoTableCellImageHeight);
        _labelUserName.frame= CGRectZero;
        
        _radioButton.frame = CGRectMake(w-kGeomButtonWidth, margin,kGeomButtonWidth,availableHeight);
    } else {
        _viewShadow.frame = CGRectMake( margin, margin, w- margin*2,availableHeight);
        float x=  margin;
        _userView.hidden= NO;
        float imageDimension= h-2*kGeomSpaceEdge;
        _userView.frame = CGRectMake(x, margin,imageDimension,imageDimension);
        
        x +=imageDimension+ margin;
        y= h/5;
        [_labelName sizeToFit];
        [_labelUserName sizeToFit];
        _labelName.frame = CGRectMake( x,y,w-kGeomSpaceEdge-kGeomButtonWidth,_labelName.frame.size.height);
        y += _labelName.frame.size.height +kGeomSpaceInter;
        _labelUserName.frame = CGRectMake( x,y,w-kGeomSpaceEdge-kGeomButtonWidth,_labelUserName.frame.size.height);

        _radioButton.frame = CGRectMake(w-kGeomButtonWidth, margin,kGeomButtonWidth,availableHeight);
    }
    
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
@property (nonatomic,strong) NSMutableOrderedSet *setOfPotentialParticipants;
@property (nonatomic,strong)  NSMutableOrderedSet *participants;
@property (atomic, assign) BOOL  busy;

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
    ENTRY;
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    
    self.setOfPotentialParticipants= [NSMutableOrderedSet new];
    self.participants= [NSMutableOrderedSet new];
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"INVITE TO EVENT" subHeader: nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= UIColorRGBA(kColorOffBlack);
    
    self.labelEventDateHeader= makeLabel( self.view,  @"WHEN IS THIS?", kGeomFontSizeHeader);
    self.buttonAddEmail=makeButton(self.view, @"INVITE BY EMAIL", kGeomFontSizeHeader,  WHITE, CLEAR,
                                   self, @selector(userPressedInviteByEmail:), 1);
    
    self.table= makeTable( self.view,  self);
#define PARTICIPANTS_TABLE_REUSE_IDENTIFIER  @"whomToInviteCell"
    [_table registerClass:[EventWhoTableCell class] forCellReuseIdentifier:PARTICIPANTS_TABLE_REUSE_IDENTIFIER];
    _table.backgroundColor= UIColorRGBA(kColorOffBlack);

    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
}

- (void)done:(id)sender
{
    // RULE: If the server interaction is still happening then we have to wait until our data gets through.
    if  (!self.busy) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self performSelector:@selector(done:)  withObject:nil afterDelay:.33];
    }
}

- (BOOL)emailAlreadyInArray: (NSString*)emailString
{
    if  (!emailString) {
        return NO;
    }
    emailString= [ emailString lowercaseString];
    
    for (UserObject* user  in  _setOfPotentialParticipants) {
        if ( [[user.email lowercaseString] isEqualToString: emailString ]) {
            return YES;
        }
    }
    return NO;
}

- (void)reloadTable
{
    @synchronized(_setOfPotentialParticipants) {
        [_table reloadData];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));

    __weak EventWhoVC *weakSelf = self;
    
#if 0
    [OOAPI getGroupsWithSuccess:^(NSArray *groups) {
        //        NSLog  (@" groups for this user=  %@", groups);
        NSLog  (@"USER HAS %lu GROUPS.",groups.count);
        @synchronized(weakSelf.setOfPotentialParticipants) {
            for (id object in groups) {
                [self.setOfPotentialParticipants  addObject: object];
            }
        }
        [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
    }
                        failure:^(NSError *e) {
                            NSLog (@"FAILED TO FETCH LIST OF GROUPS FOR USER.");
                        }];
#endif
    
    // RULE: Find out what users are already attached to this events.
    [self.eventBeingEdited refreshUsersFromServerWithSuccess:^{
        [_participants removeAllObjects];
        self.participants= [[ NSMutableOrderedSet alloc] initWithSet: self.eventBeingEdited.users.set];
        [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
        
    } failure:^{
        NSLog (@"FAILED TO DETERMINE USERS ALREADY ATTACHED TO6 EVENT");
    }];
    
    if  (self.editable) {
        UserObject* user= [Settings sharedInstance].userObject;
        
        // RULE: Identify follower users we could potentially attach this event.
        [OOAPI getFollowersOf: user.userID
                      success:^(NSArray *users) {
                          NSLog  (@"USER IS FOLLOWED BY %lu USERS.", ( unsigned long)users.count);
                          @synchronized(weakSelf.setOfPotentialParticipants) {
                              for (UserObject* user in users) {
                                  if (![weakSelf.setOfPotentialParticipants containsObject:user ]) {
                                      [weakSelf.setOfPotentialParticipants  addObject: user];
                                  }
                              }
                          }
                          [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                          NSLog (@"FAILED TO FETCH LIST OF USERS THAT USER IS FOLLOWING.");
                      }];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)userPressedInviteByEmail: (id) sender
{
    UIAlertView* alert= [ [UIAlertView  alloc] initWithTitle: LOCAL(@"EMAIL ADDRESS")
                                                     message:nil
                                                    delegate:  self
                                           cancelButtonTitle: LOCAL(@"Cancel")
                                           otherButtonTitles: LOCAL(@"ADD"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeEmailAddress];
    [[alert textFieldAtIndex:0]  becomeFirstResponder];
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
        
        if (!isValidEmailAddress(string)) {
            message( @"Not a valid email address.");
            return;
        }
        
        if  ([self emailAlreadyInArray: string] ) {
            RUN_AFTER(250,^{
                message(LOCAL( @"That user is already in the list."));
            })
            return;
        }
        
        __weak EventWhoVC *weakSelf = self;
        [OOAPI lookupUserByEmail:string
                         success:^(UserObject *user) {
                             if  (user) {
                                 [weakSelf addUser: user];
                             } else {
                                 [weakSelf addTheirEmailAddress: string];
                             }
                             
                         } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                             [weakSelf addTheirEmailAddress: string];
                         }];
    }
}

- (void)addUser: (UserObject*)user
{
    @synchronized(_setOfPotentialParticipants) {
        [_setOfPotentialParticipants  addObject: user];
    }
    [_table reloadData];
    [_table scrollToRowAtIndexPath:
     [NSIndexPath indexPathForRow:_setOfPotentialParticipants.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)addTheirEmailAddress: (NSString*)emailAddress
{
    if ( !self.editable) {
        return;
    }
    
    @synchronized(_setOfPotentialParticipants) {
        UserObject *user= makeEmailOnlyUserObject(emailAddress);
        [_setOfPotentialParticipants  addObject: user];
    }
    [_table reloadData];
    
    [_table scrollToRowAtIndexPath:
     [NSIndexPath indexPathForRow:_setOfPotentialParticipants.count-1 inSection:0]
                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    
    float tableHeight= h-kGeomHeightButton-2*spacing;
    _table.frame = CGRectMake(0,y,w,tableHeight);
    y+= tableHeight+ spacing;
    _buttonAddEmail.frame = CGRectMake(margin,y,w-2*margin, kGeomHeightButton);
    y += kGeomHeightButton+ spacing;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventWhoTableCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:PARTICIPANTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    UserObject* object= nil;
    NSInteger row= indexPath.row;
    @synchronized(_setOfPotentialParticipants) {
        if  (row  < _setOfPotentialParticipants.count) {
            object=  _setOfPotentialParticipants[row];
        }
    }
    
    BOOL inList= NO;
    for (UserObject* user  in  _participants) {
        if (object.userID>0 &&  user.userID == object.userID) {
            inList= YES;
            break;
        }
        if ( [user.email isEqualToString:object.email ]) {
            inList= YES;
            break;
        }
    }
    [ cell setRadioButtonState: inList];
    
    cell.viewController=  self;
    if  ([object isKindOfClass:[GroupObject class]] ) {
    } else {
        [cell specifyUser: object];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightEventWhoTableCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserObject* user= nil;
    NSInteger row= indexPath.row;
    @synchronized(_setOfPotentialParticipants) {
        if  ( row  < _setOfPotentialParticipants.count) {
            user=  _setOfPotentialParticipants[row];
        }
    }
    if ( user) {
        ProfileVC* vc= [[ProfileVC alloc] init];
        vc.userID= user.userID;
        vc.userInfo=user;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  total;
    @synchronized(_setOfPotentialParticipants) {
        total= _setOfPotentialParticipants.count;
    }
    return  total;
}

- (void) radioButtonChanged: (BOOL)value for: (id)object;
{
    if (!object) {
        return;
    }
    if  (!self.editable) {
        return;
    }
    
    if ( value) {
        [_participants  addObject: object];
    }else {
        [_participants  removeObject: object];
    }
    
    [self.delegate userDidAlterEventParticipants];
    self.busy=YES;
    __weak EventWhoVC *weakSelf = self;
    [OOAPI setParticipationOf:object
                      inEvent:self.eventBeingEdited
                           to:value
                      success:^(NSInteger eventID) {
                          NSLog  (@"SUCCESS");
                          weakSelf.busy= NO;
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                          weakSelf.busy= NO;
                          NSLog  (@"FAILURE  %@",e);
                          if ( value) {
                              [_participants  removeObject: object];
                              // XX:  need to update radio button is well
                          }
                      }];
    
}
@end

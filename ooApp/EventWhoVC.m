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
#import "ProfileVC.h"

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
        _radioButton= makeButton(self, kFontIconRemove, kGeomFontSizeDetail, BLACK, CLEAR, self, @selector(userPressRadioButton:), 0);
        [_radioButton setTitle:kFontIconCheckmark forState:UIControlStateSelected];
        _radioButton.titleLabel.font= [UIFont fontWithName:kFontIcons size: kGeomFontSizeHeader];
        
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
                               } failure:^(AFHTTPRequestOperation* operation, NSError *e) {
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
        _labelName.text= [NSString stringWithFormat: @"Unnamed group #%ld",(long) group.groupID];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    
    // RULE: If this row will simply be an email address, then we completely hide the image.
    if  (!self.group && self.user && !self.user.firstName ) {
        _imageViewThumbnail.hidden= YES;
        _labelName.frame = CGRectMake(kGeomSpaceEdge,0,w-kGeomSpaceEdge-kGeomButtonWidth,h);
        _radioButton.frame = CGRectMake(w-kGeomButtonWidth,0,kGeomButtonWidth,h);
    } else {
        float x= kGeomSpaceEdge;
        _imageViewThumbnail.hidden= NO;
        float imageDimension= h-2*kGeomSpaceEdge;
        _imageViewThumbnail.frame = CGRectMake(x,kGeomSpaceEdge,imageDimension,imageDimension);
        x += imageDimension+kGeomSpaceInter ;
        _labelName.frame = CGRectMake(x,0,w-x-kGeomButtonWidth,h);
        _radioButton.frame = CGRectMake(w-kGeomButtonWidth,0,kGeomButtonWidth,h);
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
@property (nonatomic,strong) NSMutableArray *arrayOfPotentialParticipants;
@property (nonatomic,strong)  NSMutableOrderedSet *participants;

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
    // Do any additional setup after loading the view, typically from a nib.    
    
    self.view.autoresizesSubviews= NO;
    
    self.arrayOfPotentialParticipants= [NSMutableArray new];
    self.participants= [NSMutableOrderedSet new];
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"INVITE TO EVENT" subHeader: nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= WHITE;

    self.labelEventDateHeader= makeLabel( self.view,  @"WHEN IS THIS?", kGeomFontSizeHeader);
    self.buttonAddEmail=makeButton(self.view, @"INVITE BY EMAIL", kGeomFontSizeHeader,  BLACK, CLEAR,
                                    self, @selector(userPressedInviteByEmail:), 1);
    
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
            }
        }
        [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
    }
                        failure:^(NSError *e) {
                            NSLog (@"FAILED TO FETCH LIST OF GROUPS FOR USER.");
                        }];
#endif
    
    // RULE: Find out what users are already attached to this events.
    [APP.eventBeingEdited refreshUsersFromServerWithSuccess:^{
        [_participants removeAllObjects];
        self.participants= [[ NSMutableOrderedSet alloc] initWithSet: APP.eventBeingEdited.users.set];
        [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
        
    } failure:^{
        NSLog (@"FAILED TO DETERMINE USERS ALREADY ATTACHED TO6 EVENT");
    }];

    // RULE: Identify follower users we could potentially attach this event.
    [OOAPI getFollowingWithSuccess:^(NSArray *users) {
        NSLog  (@"USER IS FOLLOWING %lu USERS.", ( unsigned long)users.count);
        @synchronized(weakSelf.arrayOfPotentialParticipants) {
            for (id object in users) {
                [self.arrayOfPotentialParticipants  addObject: object];
            }
        }
        [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
    }
                           failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                               NSLog (@"FAILED TO FETCH LIST OF USERS THAT USER IS FOLLOWING.");
                           }];
    
    // XX:  just at all the users
    [  OOAPI getAllUsersWithSuccess:^(NSArray *users) {
        @synchronized(weakSelf.arrayOfPotentialParticipants) {
            for (UserObject* user  in  users) {
                if (![weakSelf.arrayOfPotentialParticipants containsObject:user ]) {
                    [weakSelf.arrayOfPotentialParticipants addObject: user];
                }
            }
            [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
            
        }
        
    }
                            failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                                NSLog  (@"CANNOT GET USER LISTING.  %@",error);
                            }];
}

- (BOOL)emailAlreadyInArray: (NSString*)emailString
{
    if  (!emailString) {
        return NO;
    }
    emailString= [ emailString lowercaseString];
    
    for (UserObject* user  in  _arrayOfPotentialParticipants) {
        if ( [[user.email lowercaseString] isEqualToString: emailString ]) {
            return YES;
        }
    }
    return NO;
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
                             
                         } failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                             [weakSelf addTheirEmailAddress: string];
                         }];
    }
}

- (void)addUser: (UserObject*)user
{
    @synchronized(_arrayOfPotentialParticipants) {
        [_arrayOfPotentialParticipants  addObject: user];
    }
    [_table reloadData];
    [_table scrollToRowAtIndexPath:
        [NSIndexPath indexPathForRow:_arrayOfPotentialParticipants.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)addTheirEmailAddress: (NSString*)emailAddress
{
    @synchronized(_arrayOfPotentialParticipants) {
        UserObject *user= makeEmailOnlyUserObject(emailAddress);
        [_arrayOfPotentialParticipants  addObject: user];
    }
    [_table reloadData];
    
    [_table scrollToRowAtIndexPath:
     [NSIndexPath indexPathForRow:_arrayOfPotentialParticipants.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    @synchronized(_arrayOfPotentialParticipants) {
        if  (row  < _arrayOfPotentialParticipants.count) {
             object=  _arrayOfPotentialParticipants[row];
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
//    inList= [_participants containsObject: object];
    [ cell setRadioButtonState: inList];

    cell.viewController=  self;
    if  ([object isKindOfClass:[GroupObject class]] ) {
//        [cell specifyGroup: object];
    } else {
        [cell specifyUser: object];

    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightButton;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserObject* user= nil;
    NSInteger row= indexPath.row;
    @synchronized(_arrayOfPotentialParticipants) {
        if  ( row  < _arrayOfPotentialParticipants.count) {
            user=  _arrayOfPotentialParticipants[row];
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
    @synchronized(_arrayOfPotentialParticipants) {
        total= _arrayOfPotentialParticipants.count;
    }
    return  total;
}

- (void) radioButtonChanged: (BOOL)value for: (id)object;
{
    if (!object) {
        return;
    }
    
    if ( value) {
        [_participants  addObject: object];
      }else {
        [_participants  removeObject: object];
    }
    
    NSLog  (@" set=  %@",_participants);
    NSLog (@"OBJ %@", object);
    
    [OOAPI setParticipationOf:object
                      inEvent:APP.eventBeingEdited
                                to:value
                           success:^(NSInteger eventID) {
                               NSLog  (@"SUCCESS");
                           } failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                               NSLog  (@"FAILURE  %@",e);
                               if ( value) {
                                   [_participants  removeObject: object];
                                   // XX:  need to update radio button is well
                               }
                           }];

}
@end

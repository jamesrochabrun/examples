//
//  PlayVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "PlayVC.h"
#import "DraggableViewBackground.h"
#import "OOAPI.h"
#import "Settings.h"
#import "TagObject.h"

@interface PlayVC ()
@property (nonatomic, strong) NavTitleObject *nto;
@property (nonatomic, strong) DraggableViewBackground *draggableBackround;
@end

@implementation PlayVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _nto = [[NavTitleObject alloc] initWithHeader:@"Play" subHeader:@"restaurants and bars"];
    self.navTitle = _nto;
    
    CGRect frame = CGRectMake(0, 0, width(self.view), height(self.view) - 64);
    _draggableBackround = [[DraggableViewBackground alloc] initWithFrame:frame];
    _draggableBackround.presentingVC = self;
    [self.view addSubview:_draggableBackround];
    [self populateOptions];
}

- (void)populateOptions {
    __weak PlayVC *weakSelf = self;
    
    self.dropDownList.delegate = self;
    
    [OOAPI getTagsForUser:[Settings sharedInstance].userObject.userID success:^(NSArray *tags) {
        weakSelf.dropDownList.options = tags;
        ON_MAIN_THREAD(^{
            [self.navTitleView setDDLState:YES]; 
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropDownList:(DropDownListTVC *)dropDownList optionTapped:(id)object {
    if (![object isKindOfClass:[TagObject class]]) return;
    TagObject *tag = (TagObject *)object;
    [_draggableBackround getPlayItems:tag];
    
    _nto.subheader = [NSString stringWithFormat:@"#%@", tag.term];
    self.navTitle = _nto;
    
    [self displayDropDown:NO];
}

@end

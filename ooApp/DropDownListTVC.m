//
//  DropDownListTVC.m
//  ooApp
//
//  Created by Anuj Gujar on 11/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "DropDownListTVC.h"
#import "TagObject.h"

@interface DropDownListTVC ()

@end

@implementation DropDownListTVC

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kGeomHeightDropDownListRow*kNumDropDownListRows) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight =  kGeomHeightDropDownListRow;
    _tableView.scrollEnabled = YES;
    _tableView.scrollsToTop = NO;
    [self.view addSubview:_tableView];
    
    _tableView.backgroundColor = UIColorRGBA(kColorBlack);
}

- (void)setOptions:(NSArray *)options {
    if (_options == options) return;
    _options = options;
    [self.view setNeedsLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect frame = _tableView.frame;
    frame.size.height = ([_options count] < kNumDropDownListRows) ? kGeomHeightDropDownListRow * [_options count] :kGeomHeightDropDownListRow*kNumDropDownListRows;
    _tableView.frame = frame;
    
    self.view.frame = frame;
}

- (void)scrollToCurrent {
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self getCurrentRow] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (NSInteger)getCurrentRow {
    int i = 0;
    for (TagObject *t in _options) {
        if (t.tagID == _currentOptionID) return i;
        i++;
    }
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ddlCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.textColor = UIColorRGBA(kColorWhite);
        cell.textLabel.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        cell.textLabel.font = [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader];
        cell.textLabel.numberOfLines = 0;

        cell.detailTextLabel.highlightedTextColor = UIColorRGBA(kColorYellow);
    }
    
    // Configure the cell...
    id object = [_options objectAtIndex:indexPath.row];
    NSUInteger theID;
    
    if ([object isKindOfClass:[TagObject class]]) {
        TagObject *o = (TagObject *)object;
        cell.textLabel.text = o.term;
        theID = o.tagID;
    } else {
        ListObject *o = (ListObject *)object;
        cell.textLabel.text = o.name;
        theID = o.listID;
    }

    if (_currentOptionID == theID) {
        cell.detailTextLabel.highlighted = YES;
        cell.contentView.backgroundColor = UIColorRGBA(kColorOffBlack);
    } else {
        cell.detailTextLabel.highlighted = NO;
        cell.contentView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate dropDownList:self optionTapped:[_options objectAtIndex:indexPath.row]];
}

@end

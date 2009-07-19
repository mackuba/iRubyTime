// -------------------------------------------------------
// ShowActivityDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "Project.h"
#import "ShowActivityDialogController.h"
#import "Utils.h"

#define ACTIVITY_FIELD_CELL_TYPE @"ActivityFieldCell"
#define DELETE_ACTIVITY_CELL_TYPE @"DeleteActivityCell"

@interface ShowActivityDialogController ()
- (UITableViewCell *) tableView: (UITableView *) table fieldCellForRow: (NSInteger) row;
- (void) deleteActivityClicked;
@end

@implementation ShowActivityDialogController

OnDeallocRelease(activity, originalActivity, connector);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) anActivity connector: (RubyTimeConnector *) aConnector {
  self = [super initWithStyle: UITableViewStyleGrouped];
  if (self) {
    activity = [anActivity copy];
    originalActivity = [anActivity retain];
    connector = [aConnector retain];
    self.title = @"Activity details";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
  }
  return self;
}

- (void) viewDidLoad {
  self.tableView.allowsSelectionDuringEditing = YES;
  self.tableView.scrollEnabled = false;
  cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                               target: self
                                                               action: @selector(cancelClicked)];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) deleteActivityClicked {
  
}

- (void) cancelClicked {
  [activity release];
  activity = [originalActivity copy];
  [self.tableView reloadData];
  [self setEditing: NO animated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
  return 2;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  if (section == 0) {
    return 4; // TODO: 5 if activity author is displayed too
  } else {
    return (self.editing ? 1 : 0);
  }
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  if (path.section == 0) {
    //if (path.row == 3) {
    //  return commentsCell;
    //} else {
      return [self tableView: table fieldCellForRow: path.row];
    //}
  } else {
    UITableViewCell *cell = [table cellWithStyle: UITableViewCellStyleDefault andIdentifier: DELETE_ACTIVITY_CELL_TYPE];
    cell.textLabel.text = @"Delete activity";
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.textColor = [UIColor colorWithRed: 0.7 green: 0.0 blue: 0.0 alpha: 1.0];
    return cell;
  }
}

- (UITableViewCell *) tableView: (UITableView *) table fieldCellForRow: (NSInteger) row {
  UITableViewCell *cell = [table cellWithStyle: UITableViewCellStyleValue1 andIdentifier: ACTIVITY_FIELD_CELL_TYPE];
  switch(row) {
    case 0:
      cell.textLabel.text = @"Date";
      cell.detailTextLabel.text = activity.dateAsString;
      break;

    case 1:
      cell.textLabel.text = @"Project";
      cell.detailTextLabel.text = activity.project.name;
      break;

    case 2:
      cell.textLabel.text = @"Length";
      cell.detailTextLabel.text = [activity hourString];
      break;
      
    default:
      cell.textLabel.text = @"Comments";
      cell.detailTextLabel.text = activity.comments;
  }
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

- (UITableViewCellEditingStyle) tableView: (UITableView *) table
            editingStyleForRowAtIndexPath: (NSIndexPath *) path {
  return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView: (UITableView *) table
         shouldIndentWhileEditingRowAtIndexPath: (NSIndexPath *) path {
  return NO;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) path {
  [tableView deselectRowAtIndexPath: path animated: YES];
  /*UIViewController *controller;
  switch (path.row) {
    case 0: controller = [self activityDateDialogController]; break;
    case 1: controller = [self projectChoiceController]; break;
    case 2: controller = [self activityCommentsDialogController]; break;
    default: return;
  }
  [self.navigationController pushViewController: controller animated: YES];*/
}

- (void) setEditing: (BOOL) editing animated: (BOOL) animated {
  [super setEditing: editing animated: animated];
  [self.tableView beginUpdates];
  [self.tableView setEditing: editing animated: animated];
  NSArray *indexes = RTArray(RTIndex(1, 0));
  if (editing) {
    self.navigationItem.leftBarButtonItem = cancelButton;
    [self.tableView insertRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  } else {
    self.navigationItem.leftBarButtonItem = nil;
    [self.tableView deleteRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  }
  [self.tableView endUpdates];
}

@end

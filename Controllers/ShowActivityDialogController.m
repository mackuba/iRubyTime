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

@interface ShowActivityDialogController ()
- (UITableViewCell *) tableView: (UITableView *) table fieldCellForRow: (NSInteger) row;
@end

@implementation ShowActivityDialogController

OnDeallocRelease(activity, connector);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) anActivity connector: (RubyTimeConnector *) aConnector {
  self = [super initWithStyle: UITableViewStyleGrouped];
  if (self) {
    activity = [anActivity retain];
    connector = [aConnector retain];
    self.title = @"Activity details";
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  return 4;  // TODO: 5 if activity author is displayed too
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  //if (path.row == 3) {
  //  return commentsCell;
  //} else {
    return [self tableView: table fieldCellForRow: path.row];
  //}
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
  return cell;
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  //return (path.row == 3) ? 92 : 44;
  return 44;
}

/*- (UITableViewCellAccessoryType) tableView: (UITableView *) table
          accessoryTypeForRowWithIndexPath: (NSIndexPath *) path {
  return UITableViewCellAccessoryDisclosureIndicator;
}*/

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

@end

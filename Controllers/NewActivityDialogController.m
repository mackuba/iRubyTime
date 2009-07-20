// -------------------------------------------------------
// NewActivityDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "NewActivityDialogController.h"

@implementation NewActivityDialogController

SynthesizeAndReleaseLater(activityLengthPicker);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector nibName: @"NewActivityDialog"];
  if (self) {
    activity = [[Activity alloc] init];

    if (connector.activities.count > 0) {
      activity.minutes = [[connector valueForKeyPath: @"activities.@avg.minutes"] intValue];
      activity.project = [[connector.activities objectAtIndex: 0] project];
    } else {
      activity.minutes = 7 * 60;
      activity.project = [connector.projects objectAtIndex: 0];
    }
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  tableView.scrollEnabled = false;
  activityLengthPicker.countDownDuration = activity.minutes * 60;
  NSInteger precision = activityLengthPicker.minuteInterval;
  activity.minutes = activity.minutes / precision * precision;
}

- (void) setupToolbar {
  [super setupToolbar];
  UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
  back.title = @"Back";
  
  self.navigationItem.leftBarButtonItem = cancelButton;
  self.navigationItem.rightBarButtonItem = saveButton;
  self.navigationItem.backBarButtonItem = back;
  self.navigationItem.title = @"New activity";

  [back release];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) executeSave {
  [connector createActivity: activity];
}

- (void) cancelClicked {
  Notify(@"newActivityDialogCancelled");
}

- (IBAction) timeChanged {
  activity.minutes = activityLengthPicker.countDownDuration / 60;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return 3;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  if (path.row == 2) {
    return commentsCell;
  } else {
    UITableViewCell *cell = [self tableView: table fieldCellForRow: path.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
  }
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return (path.row == 2) ? COMMENTS_CELL_HEIGHT : STANDARD_CELL_HEIGHT;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  [self pushHelperControllerForPath: path];
}

- (UIViewController *) helperControllerForRow: (NSInteger) row {
  switch (row) {
    case 0: return [self activityDateDialogController];
    case 1: return [self projectChoiceController];
    case 2: return [self activityCommentsDialogController];
    default: return nil;
  }
}

@end

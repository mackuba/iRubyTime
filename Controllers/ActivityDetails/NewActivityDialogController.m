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

- (id) initWithConnector: (RubyTimeConnector *) rtConnector andActivityManager: (ActivityManager *) manager {
  self = [super initWithConnector: rtConnector nibName: @"NewActivityDialog" activityManager: manager];
  if (self) {
    activity = [[Activity alloc] init];

    if (manager.activities.count > 0) {
      activity.minutes = [[manager.activities valueForKeyPath: @"@avg.minutes"] intValue];
      activity.project = [[manager.activities objectAtIndex: 0] project];
    } else {
      activity.minutes = 7 * 60;
      activity.project = [[Project list] objectAtIndex: 0];
    }
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  [self initializeLengthPicker: activityLengthPicker usingActivity: activity];
  tableView.scrollEnabled = false;
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
  Notify(ActivityDialogCancelledNotification);
}

- (IBAction) timeChanged {
  activity.minutes = activityLengthPicker.countDownDuration / 60;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (IntArray *) rowTypesInSection: (NSInteger) section {
  return [IntArray arrayOfSize: 3 integers: DateRow, ProjectRow, CommentsRow];
}

- (UITableViewCell *) cellForRowType: (RowType) rowType {
  UITableViewCell *cell = [super cellForRowType: rowType];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

- (CGFloat) heightForRowOfType: (RowType) rowType {
  return (rowType == CommentsRow) ? COMMENTS_CELL_HEIGHT : STANDARD_CELL_HEIGHT;
}

@end

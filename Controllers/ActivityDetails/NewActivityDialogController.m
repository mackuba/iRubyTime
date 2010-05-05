// -------------------------------------------------------
// NewActivityDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "NewActivityDialogController.h"

@implementation NewActivityDialogController

@synthesize activityLengthPicker;
PSReleaseOnDealloc(activityLengthPicker);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector
          defaultProject: (Project *) project
           defaultLength: (NSInteger) minutes {
  self = [super initWithConnector: rtConnector nibName: @"NewActivityDialog"];
  if (self) {
    activity = [[Activity alloc] init];
    activity.minutes = minutes;
    activity.project = project;
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
  PSNotify(ActivityDialogCancelledNotification);
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

// -------------------------------------------------------
// ActivityDateDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityDateDialogController.h"
#import "Utils.h"

@implementation ActivityDateDialogController

@synthesize tableView, activityDatePicker;
OnDeallocRelease(tableView, activityDatePicker, activity);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) newActivity {
  self = [super initWithNibName: @"ActivityDateDialog" bundle: [NSBundle mainBundle]];
  if (self) {
    activity = newActivity;
    self.title = @"Choose date";
  }
  return self;
}

- (void) viewWillAppear: (BOOL) animated {
  [activityDatePicker setDate: activity.date animated: NO];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (IBAction) dateChanged {
  activity.date = activityDatePicker.date;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  return 0;
  // TODO: add some buttons setting date to today, yesterday etc.
}

@end

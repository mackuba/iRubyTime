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
PSReleaseOnDealloc(tableView, activityDatePicker, activity);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) newActivity {
  self = [super initWithNibName: @"ActivityDateDialog" bundle: [NSBundle mainBundle]];
  if (self) {
    activity = [newActivity retain];
    self.title = @"Choose date";
  }
  return self;
}

- (void) viewWillAppear: (BOOL) animated {
  [activityDatePicker setDate: activity.date animated: NO];
  [activityDatePicker setMaximumDate: [NSDate date]];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation {
  return (PSiPadDevice ? YES : (orientation == UIInterfaceOrientationPortrait));
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (IBAction) dateChanged {
  activity.date = activityDatePicker.date;
}

- (IBAction) setToToday {
  activity.date = [NSDate date];
  [activityDatePicker setDate: activity.date animated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  return 0;
}

@end

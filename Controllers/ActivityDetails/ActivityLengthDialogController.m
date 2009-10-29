// -------------------------------------------------------
// ActivityLengthDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityLengthDialogController.h"
#import "Utils.h"

@implementation ActivityLengthDialogController

@synthesize activityLengthPicker;
OnDeallocRelease(activityLengthPicker, activity);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) anActivity {
  self = [super initWithNibName: @"ActivityLengthDialog" bundle: [NSBundle mainBundle]];
  if (self) {
    activity = [anActivity retain];
    self.title = @"Activity length";
  }
  return self;
}

- (void) viewWillAppear: (BOOL) animated {
  [self initializeLengthPicker: activityLengthPicker usingActivity: activity];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (IBAction) timeChanged {
  activity.minutes = activityLengthPicker.countDownDuration / 60;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  return 0;
}

@end

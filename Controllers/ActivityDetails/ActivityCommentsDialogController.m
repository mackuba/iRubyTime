// -------------------------------------------------------
// ActivityDateDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityCommentsDialogController.h"
#import "Utils.h"

@implementation ActivityCommentsDialogController

@synthesize textView, textCell;
PSReleaseOnDealloc(activity, textView, textCell);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) newActivity {
  self = [super initWithNibName: @"ActivityCommentsDialog" bundle: [NSBundle mainBundle]];
  if (self) {
    activity = [newActivity retain];
    self.title = @"Activity comments";
  }
  return self;
}

- (void) viewDidLoad {
  textView.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void) viewWillAppear: (BOOL) animated {
  [super viewWillAppear: animated];
  textView.text = activity.comments;
  [textView becomeFirstResponder];
}

- (void) textViewDidChange: (UITextView *) view {
  activity.comments = textView.text;
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation {
  return RTiPad;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return 1;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  return textCell;
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return textCell.frame.size.height;
}

@end

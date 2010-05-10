// -------------------------------------------------------
// DateRangeController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityDateFormatter.h"
#import "DateRangeController.h"
#import "SearchFormController.h"
#import "Utils.h"

static UIColor *dateColor = nil;


@implementation DateRangeController

@synthesize tableView, datePicker;
PSReleaseOnDealloc(tableView, datePicker);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithDelegate: (id) aDelegate {
  self = [super initWithNibName: @"DateRangeDialog" bundle: [NSBundle mainBundle]];
  if (self) {
    delegate = aDelegate;
    self.title = @"Choose date range";
  }
  return self;
}

- (void) viewDidLoad {
  [datePicker setMaximumDate: [NSDate date]];
}

- (void) viewWillAppear: (BOOL) animated {
  [super viewWillAppear: animated];
  NSIndexPath *selection = [tableView indexPathForSelectedRow];
  if (!selection) {
    [tableView reloadData];
    [tableView selectRowAtIndexPath: PSIndex(0, 0) animated: NO scrollPosition: UITableViewScrollPositionNone];
    [datePicker setDate: [delegate startDate] animated: NO];
  }
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation {
  return RTiPad;
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (NSInteger) currentSelection {
  return [[tableView indexPathForSelectedRow] row];
}

- (IBAction) dateChanged {
  NSInteger selectedRow = [self currentSelection];
  if (selectedRow == 0) {
    [delegate setStartDate: datePicker.date];
  } else {
    [delegate setEndDate: datePicker.date];
  }
  [tableView reloadData];
  [tableView selectRowAtIndexPath: PSIndex(0, selectedRow) animated: NO scrollPosition: UITableViewScrollPositionNone];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (BOOL) datesAreCorrect {
  NSDate *startDate = [delegate startDate];
  NSDate *endDate = [delegate endDate];
  return [startDate psIsEarlierOrSameDay: endDate];
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return 2;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [tableView psGenericCellWithStyle: UITableViewCellStyleValue1];
  NSDate *displayedDate;
  if (path.row == 0) {
    cell.textLabel.text = @"From date";
    displayedDate = [delegate startDate];
  } else {
    cell.textLabel.text = @"To date";
    displayedDate = [delegate endDate];
  }
  if (!dateColor) {
    dateColor = [cell.detailTextLabel.textColor retain];
  }
  cell.detailTextLabel.textColor = [self datesAreCorrect] ? dateColor : [UIColor redColor];
  cell.detailTextLabel.text = [[ActivityDateFormatter sharedFormatter] formatDate: displayedDate withAliases: NO];
  cell.accessoryType = UITableViewCellAccessoryNone;
  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  if (path.row == 0) {
    [datePicker setDate: [delegate startDate] animated: YES];
  } else {
    [datePicker setDate: [delegate endDate] animated: YES];
  }
}

@end

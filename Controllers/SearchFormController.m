// -------------------------------------------------------
// SearchFormController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "ActivityDateFormatter.h"
#import "DateRangeController.h"
#import "Project.h"
#import "RecordChoiceController.h"
#import "RubyTimeConnector.h"
#import "SearchFormController.h"
#import "User.h"
#import "Utils.h"

#define SEARCH_FORM_CELL_TYPE @"SearchFormCell"

typedef enum { ProjectRow, UserRow, DateRangeRow } RowType;

@interface SearchFormController ()
- (NSDate *) dateOneMonthAgo;
- (void) clearSubcontrollers;
- (UIViewController *) subcontrollerForRowType: (RowType) rowType;
@end


@implementation SearchFormController

@synthesize dateRangeCell, startDateLabel, endDateLabel, user, project, startDate, endDate;
OnDeallocRelease(dateRangeCell, startDateLabel, endDateLabel, startDate, endDate,
  project, user, subcontrollers);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStyleGrouped];
  if (self) {
    project = nil;
    user = nil;
    endDate = [[NSDate date] retain];
    startDate = [[self dateOneMonthAgo] retain];
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"magnifying-glass.png"];
    self.title = @"Search";
    [[NSBundle mainBundle] loadNibNamed: @"DateRangeCell" owner: self options: nil];
    [self clearSubcontrollers];
  }
  return self;
}

- (NSDate *) dateOneMonthAgo {
  NSDateComponents *minusOneMonth = [[NSDateComponents alloc] init];
  minusOneMonth.month = -1;
  NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents: minusOneMonth
                                                               toDate: [NSDate date]
                                                              options: 0];
  [minusOneMonth release];
  return date;
}

- (void) viewDidLoad {
  UIView *footerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
  UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
  button.frame = CGRectMake(80, 0, 160, 40);
  [button setTitle: @"Search" forState: UIControlStateNormal];
  [button addTarget: self action: @selector(searchClicked) forControlEvents: UIControlEventTouchUpInside];
  [footerView addSubview: button];
  tableView.tableFooterView = [footerView autorelease];
}

- (void) viewWillAppear: (BOOL) animated {
  [super viewWillAppear: animated];
  NSIndexPath *selection = [tableView indexPathForSelectedRow];
  [tableView deselectRowAtIndexPath: selection animated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) searchClicked {
  if ([startDate earlierDate: endDate] == endDate) {
    [UIAlertView showAlertWithTitle: @"Error" content: @"Start date can't be later than end date."];
  } else {
    NSLog(@"searching!");
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (IntArray *) rowTypes {
  if (connector.account.userType == Employee) {
    return [IntArray arrayOfSize: 2 integers: ProjectRow, DateRangeRow];
  } else {
    return [IntArray arrayOfSize: 3 integers: ProjectRow, UserRow, DateRangeRow];
  }
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return [[self rowTypes] size];
}

- (RowType) rowTypeAtIndexPath: (NSIndexPath *) path {
  return [[self rowTypes] integerAtIndex: path.row];
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell;
  switch ([self rowTypeAtIndexPath: path]) {
    case ProjectRow:
      cell = [tableView cellWithStyle: UITableViewCellStyleValue1 andIdentifier: SEARCH_FORM_CELL_TYPE];
      cell.textLabel.text = @"Project";
      cell.detailTextLabel.text = project ? project.name : @"All";
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      break;

    case UserRow:
      cell = [tableView cellWithStyle: UITableViewCellStyleValue1 andIdentifier: SEARCH_FORM_CELL_TYPE];
      cell.textLabel.text = @"User";
      cell.detailTextLabel.text = user ? user.name : @"All";
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      break;

    case DateRangeRow:
      cell = dateRangeCell;
      startDateLabel.text = [[ActivityDateFormatter sharedFormatter] formatDate: startDate withAliases: NO];
      endDateLabel.text = [[ActivityDateFormatter sharedFormatter] formatDate: endDate withAliases: NO];
      break;

    default:
      break;
  }
  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  UIViewController *subcontroller = [subcontrollers objectAtIndex: path.row];
  if ([subcontroller isEqual: RTNull]) {
    subcontroller = [self subcontrollerForRowType: [self rowTypeAtIndexPath: path]];
    [subcontrollers replaceObjectAtIndex: path.row withObject: subcontroller];
  }
  [self.navigationController pushViewController: subcontroller animated: YES];
}

- (UIViewController *) subcontrollerForRowType: (RowType) rowType {
  UIViewController *controller;
  switch (rowType) {
    case ProjectRow:
      controller = [[RecordChoiceController alloc] initWithModel: [Project class] delegate: self allowNil: YES];
      break;

    case UserRow:
      controller = [[RecordChoiceController alloc] initWithModel: [User class] delegate: self allowNil: YES];
      break;

    case DateRangeRow:
      controller = [[DateRangeController alloc] initWithDelegate: self];
      break;

    default:
      break;
  }
  return [controller autorelease];
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  if ([self rowTypeAtIndexPath: path] == DateRangeRow) {
    return dateRangeCell.frame.size.height;
  } else {
    return STANDARD_CELL_HEIGHT;
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleanup

- (void) clearSubcontrollers {
  [subcontrollers release];
  subcontrollers = [[NSMutableArray alloc] initWithObjects: RTNull, RTNull, RTNull, nil];
}

- (void) didReceiveMemoryWarning {
  [self clearSubcontrollers];
}

@end

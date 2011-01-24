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
#import "SearchFormController.h"
#import "SearchResultsController.h"
#import "ServerConnector.h"
#import "User.h"
#import "Utils.h"

typedef enum { ProjectRow, UserRow, DateRangeRow } RowType;

static CGFloat dateRangeCellHeight = 0.0;


@interface SearchFormController ()
- (NSDate *) dateOneMonthAgo;
- (void) clearSubcontrollers;
- (void) hideNotFoundMessage;
- (UIViewController *) subcontrollerForRowType: (RowType) rowType;
@end


@implementation SearchFormController

@synthesize dateRangeCell, startDateLabel, endDateLabel, user, project, startDate, endDate;
PSReleaseOnDealloc(dateRangeCell, startDateLabel, endDateLabel, startDate, endDate, project, user, subcontrollers);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStyleGrouped];
  if (self) {
    project = nil;
    user = nil;
    startDate = [[self dateOneMonthAgo] retain];
    endDate = [[NSDate date] retain];
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"magnifying-glass.png"];
    self.title = @"Search";
    [self psSetBackButtonTitle: @"Form"];
    [[NSBundle mainBundle] loadNibNamed: @"DateRangeCell" owner: self options: nil];
    [self clearSubcontrollers];
    dateRangeCellHeight = dateRangeCell.frame.size.height;
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
  CGFloat width = self.view.frame.size.width;
  UIView *footerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, width, 40)];
  UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
  button.frame = CGRectMake((width - 160) / 2.0, 0, 160, 40);
  [button setTag: 1];
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

- (void) viewDidDisappear: (BOOL) animated {
  [self hideNotFoundMessage];
}

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) orientation
                                          duration: (NSTimeInterval) duration {
  CGFloat width = self.view.frame.size.width;
  [tableView.tableFooterView psResizeHorizontallyTo: width];
  [[tableView.tableFooterView viewWithTag: 1] psMoveHorizontallyTo: (width - 160) / 2.0];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) searchClicked {
  if ([startDate psIsEarlierOrSameDay: endDate]) {
    SearchResultsController *controller;
    controller = [[SearchResultsController alloc] initWithParentController: self connector: connector];
    [self.navigationController pushViewController: controller animated: YES];
    [controller release];
  } else {
    [UIAlertView psShowErrorWithMessage: @"Start date can't be later than end date."];
  }
}

- (void) hideNotFoundMessage {
  tableView.tableHeaderView = nil;
}

- (void) showNotFoundMessage {
  if (!tableView.tableHeaderView) {
    UIView *footer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UILabel *label = [[UILabel alloc] initWithFrame: footer.frame];
    label.font = [UIFont systemFontOfSize: 14];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"No activities found - please change your search criteria and try again.";
    label.textColor = [UIColor colorWithRed: 0.7 green: 0.0 blue: 0.0 alpha: 1.0];
    label.textAlignment = UITextAlignmentCenter;
    label.numberOfLines = 2;
    [footer addSubview: label];
    tableView.tableHeaderView = footer;
    [footer release];
    [label release];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (PSIntArray *) rowTypes {
  if ([connector.account userType] == Employee) {
    return PSIntegers(ProjectRow, DateRangeRow);
  } else if ([connector.account userType] == ClientUser && [Project count] < 2) {
    return PSIntegers(UserRow, DateRangeRow);
  } else {
    return PSIntegers(ProjectRow, UserRow, DateRangeRow);
  }
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return [[self rowTypes] count];
}

- (RowType) rowTypeAtIndexPath: (NSIndexPath *) path {
  return [[self rowTypes] integerAtIndex: path.row];
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = nil;
  switch ([self rowTypeAtIndexPath: path]) {
    case ProjectRow:
      cell = [tableView psGenericCellWithStyle: UITableViewCellStyleValue1];
      cell.textLabel.text = @"Project";
      cell.detailTextLabel.text = project ? project.name : @"All";
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      break;

    case UserRow:
      cell = [tableView psGenericCellWithStyle: UITableViewCellStyleValue1];
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
  if ([subcontroller isEqual: PSNull]) {
    subcontroller = [self subcontrollerForRowType: [self rowTypeAtIndexPath: path]];
    [subcontrollers replaceObjectAtIndex: path.row withObject: subcontroller];
  }
  [self.navigationController pushViewController: subcontroller animated: YES];
}

- (UIViewController *) subcontrollerForRowType: (RowType) rowType {
  id controller = nil;
  switch (rowType) {
    case ProjectRow:
      controller = [[RecordChoiceController alloc] initWithModel: [Project class] delegate: self allowNil: YES];
      [controller setCloseOnSelection: NO];
      break;

    case UserRow:
      controller = [[RecordChoiceController alloc] initWithModel: [User class] delegate: self allowNil: YES];
      [controller setCloseOnSelection: NO];
      break;

    case DateRangeRow:
      controller = [[DateRangeController alloc] initWithDelegate: self];
      break;

    default:
      break;
  }
  UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle: @"Search"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(searchClicked)];
  [[controller navigationItem] setRightBarButtonItem: [searchButton autorelease]];
  [controller psSetBackButtonTitle: self.navigationItem.backBarButtonItem.title];
  return [controller autorelease];
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  if ([self rowTypeAtIndexPath: path] == DateRangeRow) {
    return dateRangeCellHeight;
  } else {
    return STANDARD_CELL_HEIGHT;
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleanup

- (void) clearSubcontrollers {
  [subcontrollers release];
  subcontrollers = [[NSMutableArray alloc] initWithObjects: PSNull, PSNull, PSNull, nil];
}

- (void) didReceiveMemoryWarning {
  [self clearSubcontrollers];
}

@end

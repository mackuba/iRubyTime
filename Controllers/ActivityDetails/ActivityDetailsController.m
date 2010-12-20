// -------------------------------------------------------
// ActivityDetailsController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityCommentsDialogController.h"
#import "ActivityDetailsController.h"
#import "ActivityDateDialogController.h"
#import "ActivityLengthDialogController.h"
#import "ProjectChoiceController.h"
#import "ActivityTypeChoiceController.h"


@implementation ActivityDetailsController

@synthesize tableView, activity;

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector nibName: (NSString *) nib {
  self = [super initWithNibName: nib bundle: [NSBundle mainBundle]];
  if (self) {
    connector = [rtConnector retain];
    activity = nil;
    subcontrollers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void) viewDidLoad {
  [self setupToolbar];
  PSObserve(connector, RequestFailedNotification, requestFailed:);
}

- (void) viewWillAppear: (BOOL) animated {
  [super viewWillAppear: animated];
  [tableView reloadData];
  NSIndexPath *selection = [tableView indexPathForSelectedRow];
  [tableView deselectRowAtIndexPath: selection animated: YES];
}

- (void) setupToolbar {
  cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                               target: self
                                                               action: @selector(cancelClicked)];
  saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                                             target: self
                                                             action: @selector(saveClicked)];

  spinner = [[UIActivityIndicatorView spinnerBarButton] retain];
  loadingButton = [[UIBarButtonItem alloc] initWithCustomView: spinner];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation {
  return (RTiPad ? YES : (orientation == UIInterfaceOrientationPortrait));
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) saveClicked {
  if ([activity.comments psIsBlank]) {
    [UIAlertView psShowAlertWithTitle: @"Can't save activity"
                              message: @"Activity comments field is empty - please fill it first."];
  } else {
    self.navigationItem.rightBarButtonItem = loadingButton;
    cancelButton.enabled = NO;
    [spinner startAnimating];
    [self executeSave];
  }
}

- (void) executeSave { AbstractMethod() }

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) requestFailed: (NSNotification *) notification {
  [spinner stopAnimating];
  self.navigationItem.rightBarButtonItem = saveButton;
  cancelButton.enabled = YES;

  NSError *error = [notification.userInfo objectForKey: @"error"];
  NSString *text = [notification.userInfo objectForKey: @"text"];
  Request *request = [notification.userInfo objectForKey: @"request"];
  NSString *message = [self errorMessageFromError: error text: text request: request];

  [UIAlertView psShowErrorWithMessage: message];
}

- (NSString *) errorMessageFromError: (NSError *) error text: (NSString *) text request: (Request *) request {
  NSString *message = nil;
  if (error && error.domain == RubyTimeErrorDomain && error.code == 400 && text) {
    message = [self errorMessageFromJSON: text];
  } else if (error) {
    message = [error friendlyDescription];
  }
  if (!message) {
    if (request.type == RTDeleteActivityRequest) {
      message = @"Activity could not be deleted.";
    } else {
      message = @"Activity could not be saved.";
    }
  }
  return message;
}

- (NSString *) errorMessageFromJSON: (NSString *) jsonString {
  NSString *message = nil;
  NSDictionary *result = [jsonString yajl_JSON];
  if (result.count > 0) {
    NSArray *errors = [result objectForKey: [[result allKeys] objectAtIndex: 0]];
    if (errors.count > 0) {
      message = [[errors objectAtIndex: 0] stringByAppendingString: @"."];
    }
  }
  return message;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

// original delegate methods

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return [[self rowTypesInSection: section] count];
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  return [self cellForRowType: [self rowTypeAtIndexPath: path]];
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  [self pushSubcontrollerForPath: path];
}


// abstract methods that the subclasses need to define

- (PSIntArray *) rowTypesInSection: (NSInteger) section { AbstractMethod(return nil); }


// helper methods

- (RowType) rowTypeAtIndexPath: (NSIndexPath *) path {
  return [[self rowTypesInSection: path.section] integerAtIndex: path.row];
}

- (UITableViewCell *) cellForRowType: (RowType) rowType {
  if (rowType == CommentsRow) {
    UITableViewCell *cell = [tableView psCellWithStyle: UITableViewCellStyleDefault andIdentifier: @"CommentsCell"];
    cell.textLabel.text = (activity.comments.length > 0) ? activity.comments : @"Comments";
    cell.textLabel.textColor = (activity.comments.length > 0) ? [UIColor blackColor] : [UIColor lightGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize: 14.0];
    return cell;
  } else {
    UITableViewCell *cell = [tableView psGenericCellWithStyle: UITableViewCellStyleValue1];
    switch (rowType) {
      case DateRow:
        cell.textLabel.text = @"Date";
        cell.detailTextLabel.text = activity.dateAsString;
        break;

      case ProjectRow:
        cell.textLabel.text = @"Project";
        cell.detailTextLabel.text = activity.project.name;
        break;
        
      case ActivityTypeRow:
        cell.textLabel.text = @"Activity Type";
        cell.detailTextLabel.text = activity.activityType.name;
        break;

      case UserRow:
        cell.textLabel.text = @"User";
        cell.detailTextLabel.text = activity.user.name;
        break;

      case LengthRow:
        cell.textLabel.text = @"Length";
        cell.detailTextLabel.text = [activity hourString];
        break;
        
      default:
        break;
    }
    return cell;
  }
}

- (void) pushSubcontrollerForPath: (NSIndexPath *) path {
  UIViewController *controller = [self subcontrollerForRowType: [self rowTypeAtIndexPath: path]];
  if (controller) {
    [self.navigationController pushViewController: controller animated: YES];
  }
}

- (UIViewController *) subcontrollerForRowType: (RowType) rowType {
  UIViewController *controller = [subcontrollers objectForKey: PSInt(rowType)];

  if (!controller) {
    switch (rowType) {
      case DateRow:
        controller = [[ActivityDateDialogController alloc] initWithActivity: activity];
        break;
      case ProjectRow:
        controller = [[ProjectChoiceController alloc] initWithActivity: activity];
        break;
      case ActivityTypeRow:
        controller = [[ActivityTypeChoiceController alloc] initWithActivity: activity parent: self];
        break;
      case LengthRow:
        controller = [[ActivityLengthDialogController alloc] initWithActivity: activity];
        break;
      case CommentsRow:
        controller = [[ActivityCommentsDialogController alloc] initWithActivity: activity];
        break;
    }
    
    [subcontrollers setObject: controller forKey: PSInt(rowType)];
    [controller release];
  }

  return controller;
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleanup

- (void) didReceiveMemoryWarning {
  [subcontrollers removeAllObjects];
}

- (void) dealloc {
  PSStopObservingAll();
  PSRelease(tableView, activity, connector, spinner, saveButton, loadingButton, cancelButton, subcontrollers);
  [super dealloc];
}

@end

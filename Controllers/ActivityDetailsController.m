// -------------------------------------------------------
// ActivityDetailsController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityDetailsController.h"

#define ACTIVITY_FIELD_CELL_TYPE @"ActivityFieldCell"

@implementation ActivityDetailsController

@synthesize tableView, commentsCell, commentsLabel;

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector nibName: (NSString *) nib {
  self = [super initWithNibName: nib bundle: [NSBundle mainBundle]];
  if (self) {
    [[NSBundle mainBundle] loadNibNamed: @"CommentsCell" owner: self options: nil];
    connector = [rtConnector retain];
    activity = nil;
  }
  return self;
}

- (void) viewDidLoad {
  [self setupToolbar];
  Observe(connector, RequestFailedNotification, requestFailed:);
}

- (void) viewWillAppear: (BOOL) animated {
  [super viewWillAppear: animated];
  commentsLabel.text = (activity.comments.length > 0) ? activity.comments : @"Comments";
  commentsLabel.textColor = (activity.comments.length > 0) ? [UIColor blackColor] : [UIColor lightGrayColor];
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

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) saveClicked {
  if ([activity.comments trimmedString].length == 0) {
    [UIAlertView showAlertWithTitle: @"Can't save activity"
                            content: @"Activity comments field is empty - please fill it first."];
  } else {
    self.navigationItem.rightBarButtonItem = loadingButton;
    [spinner startAnimating];
    [self executeSave];
  }
}

- (void) executeSave { AbstractVoidMethod() }

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) requestFailed: (NSNotification *) notification {
  [spinner stopAnimating];
  self.navigationItem.rightBarButtonItem = saveButton;

  NSError *error = [notification.userInfo objectForKey: @"error"];
  NSString *text = [notification.userInfo objectForKey: @"text"];
  Request *request = [notification.userInfo objectForKey: @"request"];
  NSString *message = [self errorMessageFromError: error text: text request: request];

  [UIAlertView showAlertWithTitle: @"Error" content: message];
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
  NSDictionary *result = [NSDictionary dictionaryWithJSONString: jsonString];
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

- (UITableViewCell *) tableView: (UITableView *) table fieldCellForRow: (NSInteger) row {
  UITableViewCell *cell = [table cellWithStyle: UITableViewCellStyleValue1 andIdentifier: ACTIVITY_FIELD_CELL_TYPE];
  switch(row) {
    case 0:
      cell.textLabel.text = @"Date";
      cell.detailTextLabel.text = activity.dateAsString;
      break;

    case 1:
      cell.textLabel.text = @"Project";
      cell.detailTextLabel.text = activity.project.name;
      break;

    case 2:
      cell.textLabel.text = @"Length";
      cell.detailTextLabel.text = [activity hourString];
      break;
      
    default:
      cell.textLabel.text = @"Comments";
      cell.detailTextLabel.text = activity.comments;
  }
  return cell;
}

- (void) pushHelperControllerForPath: (NSIndexPath *) path {
  UIViewController *controller = [self helperControllerForRow: path.row];
  if (controller) {
    [self.navigationController pushViewController: controller animated: YES];
  }
}

- (UIViewController *) helperControllerForRow: (NSInteger) row { AbstractMethod() }

// -------------------------------------------------------------------------------------------
#pragma mark Helper controllers

- (void) clearHelperControllers {
  [activityCommentsDialogController release];
  [activityDateDialogController release];
  [activityLengthDialogController release];
  [projectChoiceController release];
  activityCommentsDialogController = nil;
  activityDateDialogController = nil;
  activityLengthDialogController = nil;
  projectChoiceController = nil;
}

- (ActivityCommentsDialogController *) activityCommentsDialogController {
  if (!activityCommentsDialogController) {
    activityCommentsDialogController = [[ActivityCommentsDialogController alloc] initWithActivity: activity];
  }
  return activityCommentsDialogController;
}

- (ActivityDateDialogController *) activityDateDialogController {
  if (!activityDateDialogController) {
    activityDateDialogController = [[ActivityDateDialogController alloc] initWithActivity: activity];
  }
  return activityDateDialogController;
}

- (ActivityLengthDialogController *) activityLengthDialogController {
  if (!activityLengthDialogController) {
    activityLengthDialogController = [[ActivityLengthDialogController alloc] initWithActivity: activity];
  }
  return activityLengthDialogController;
}

- (ProjectChoiceController *) projectChoiceController {
  if (!projectChoiceController) {
    projectChoiceController = [[ProjectChoiceController alloc] initWithActivity: activity
                                                                    projectList: connector.projects
                                                                 recentProjects: [connector recentProjects]];
  }
  return projectChoiceController;
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleanup

- (void) didReceiveMemoryWarning {
  [self clearHelperControllers];
}

- (void) dealloc {
  StopObservingAll();
  ReleaseAll(tableView, activity, connector, spinner, saveButton, loadingButton, cancelButton,
    projectChoiceController, activityCommentsDialogController, activityDateDialogController,
    activityLengthDialogController, commentsCell, commentsLabel);
  [super dealloc];
}

@end

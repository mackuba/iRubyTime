// -------------------------------------------------------
// NewActivityDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityCommentsDialogController.h"
#import "ActivityDateDialogController.h"
#import "NewActivityDialogController.h"
#import "Project.h"
#import "ProjectChoiceController.h"
#import "RubyTimeConnector.h"
#import "Utils.h"
#import "NSDictionary+BSJSONAdditions.h"

#define ACTIVITY_FIELD_CELL_TYPE @"ActivityFieldCell"

@interface NewActivityDialogController ()
- (ActivityDateDialogController *) activityDateDialogController;
- (ActivityCommentsDialogController *) activityCommentsDialogController;
- (ProjectChoiceController *) projectChoiceController;
- (UITableViewCell *) tableView: (UITableView *) table fieldCellForRow: (NSInteger) row;
- (NSString *) errorMessageFromJSON: (NSString *) jsonString;
- (void) setupToolbar;
@end

@implementation NewActivityDialogController

@synthesize tableView, activityLengthPicker, commentsCell, commentsLabel;

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithNibName: @"NewActivityDialog" bundle: [NSBundle mainBundle]];
  if (self) {
    connector = [rtConnector retain];
    activity = [[Activity alloc] init];

    if (connector.activities.count > 0) {
      activity.minutes = [[connector valueForKeyPath: @"activities.@avg.minutes"] intValue];
      activity.project = [[connector.activities objectAtIndex: 0] project];
    } else {
      activity.minutes = 7 * 60;
      activity.project = [connector.projects objectAtIndex: 0];
    }
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  [self setupToolbar];
  tableView.scrollEnabled = false;

  activityLengthPicker.countDownDuration = activity.minutes * 60;
  NSInteger precision = activityLengthPicker.minuteInterval;
  activity.minutes = activity.minutes / precision * precision;
  
  Observe(connector, @"requestFailed", activityNotCreated:);
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
  UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
  UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                          target: self
                                                                          action: @selector(cancelClicked)];
  saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                                             target: self
                                                             action: @selector(saveClicked)];
  spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
  spinner.frame = CGRectMake(0, 0, 36, 20);
  spinner.contentMode = UIViewContentModeCenter;
  loadingButton = [[UIBarButtonItem alloc] initWithCustomView: spinner];
  back.title = @"Back";
  
  self.navigationItem.leftBarButtonItem = cancel;
  self.navigationItem.rightBarButtonItem = saveButton;
  self.navigationItem.backBarButtonItem = back;
  self.navigationItem.title = @"New activity";

  [cancel release];
  [back release];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) saveClicked {
  if ([activity.comments trimmedString].length == 0) {
    [Utils showAlertWithTitle: @"Can't save activity"
                      content: @"Activity comments field is empty - please fill it first."];
  } else {
    self.navigationItem.rightBarButtonItem = loadingButton;
    [spinner startAnimating];
    [connector createActivity: activity];
  }
}

- (void) cancelClicked {
  Notify(@"newActivityDialogCancelled");
}

- (IBAction) timeChanged {
  activity.minutes = activityLengthPicker.countDownDuration / 60;
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) activityNotCreated: (NSNotification *) notification {
  [spinner stopAnimating];
  self.navigationItem.rightBarButtonItem = saveButton;

  NSError *error = [notification.userInfo objectForKey: @"error"];
  NSString *text = [notification.userInfo objectForKey: @"text"];
  NSString *message = nil;
  if (error && error.domain == RubyTimeErrorDomain && error.code == 400 && text) {
    message = [self errorMessageFromJSON: text];
  } else if (error) {
    message = [error friendlyDescription];
  }
  if (!message) {
    message = @"Activity could not be saved.";
  }
  [Utils showAlertWithTitle: @"Error" content: message];
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

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  return 3;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  if (path.row == 2) {
    return commentsCell;
  } else {
    return [self tableView: table fieldCellForRow: path.row];
  }
}

- (UITableViewCell *) tableView: (UITableView *) table fieldCellForRow: (NSInteger) row {
  UITableViewCell *cell = [table cellWithStyle: UITableViewCellStyleValue1 andIdentifier: ACTIVITY_FIELD_CELL_TYPE];
  if (row == 0) {
    cell.textLabel.text = @"Date";
    cell.detailTextLabel.text = activity.dateAsString;
  } else {
    cell.textLabel.text = @"Project";
    cell.detailTextLabel.text = activity.project.name;
  }
  return cell;
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return (path.row == 2) ? 92 : 44;
}

- (UITableViewCellAccessoryType) tableView: (UITableView *) table
          accessoryTypeForRowWithIndexPath: (NSIndexPath *) path {
  return UITableViewCellAccessoryDisclosureIndicator;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) path {
  UIViewController *controller;
  switch (path.row) {
    case 0: controller = [self activityDateDialogController]; break;
    case 1: controller = [self projectChoiceController]; break;
    case 2: controller = [self activityCommentsDialogController]; break;
    default: return;
  }
  [self.navigationController pushViewController: controller animated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Helper controllers

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

- (void) dealloc {
  StopObservingAll();
  ReleaseAll(tableView, activityLengthPicker, activity, connector, projectChoiceController,
    activityCommentsDialogController, activityDateDialogController, spinner, saveButton, loadingButton,
    commentsCell, commentsLabel);
  [super dealloc];
}

@end

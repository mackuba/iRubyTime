// -------------------------------------------------------
// ShowActivityDialogController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityCommentsDialogController.h"
#import "ActivityDateDialogController.h"
#import "ActivityLengthDialogController.h"
#import "Project.h"
#import "ProjectChoiceController.h"
#import "Request.h"
#import "RubyTimeConnector.h"
#import "ShowActivityDialogController.h"
#import "Utils.h"
#import "NSDictionary+BSJSONAdditions.h"

#define ACTIVITY_FIELD_CELL_TYPE @"ActivityFieldCell"
#define DELETE_ACTIVITY_CELL_TYPE @"DeleteActivityCell"

@interface ShowActivityDialogController ()
- (UITableViewCell *) tableView: (UITableView *) table fieldCellForRow: (NSInteger) row;
- (void) deleteActivityClicked;
- (ActivityCommentsDialogController *) activityCommentsDialogController;
- (ActivityDateDialogController *) activityDateDialogController;
- (ActivityLengthDialogController *) activityLengthDialogController;
- (ProjectChoiceController *) projectChoiceController;
- (NSString *) errorMessageFromJSON: (NSString *) jsonString;
@end

@implementation ShowActivityDialogController

OnDeallocRelease(activity, originalActivity, connector, loadingButton, editButton, saveButton, spinner, cancelButton,
  activityCommentsDialogController, activityDateDialogController, activityLengthDialogController,
  projectChoiceController, connector);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithActivity: (Activity *) anActivity connector: (RubyTimeConnector *) aConnector {
  self = [super initWithStyle: UITableViewStyleGrouped];
  if (self) {
    activity = [anActivity copy];
    originalActivity = [anActivity retain];
    connector = [aConnector retain];
    self.title = @"Activity details";
  }
  return self;
}

- (void) viewDidLoad {
  self.tableView.allowsSelectionDuringEditing = YES;
  self.tableView.scrollEnabled = false;
  cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                               target: self
                                                               action: @selector(cancelClicked)];
  spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
  spinner.frame = CGRectMake(0, 0, 36, 20);
  spinner.contentMode = UIViewContentModeCenter;
  loadingButton = [[UIBarButtonItem alloc] initWithCustomView: spinner];
  editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit
                                                             target: self
                                                             action: @selector(editClicked)];
  saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                                             target: self
                                                             action: @selector(saveClicked)];

  self.navigationItem.rightBarButtonItem = editButton;

  Observe(connector, @"requestFailed", requestFailed:);
  Observe(connector, @"activityEdited", activityEdited);
}

- (void) viewWillAppear: (BOOL) animated {
  [super viewWillAppear: animated];
  [self.tableView reloadData];
  NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
  [self.tableView deselectRowAtIndexPath: selection animated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) deleteActivityClicked {
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle: @"Do you really want to delete this activity?"
                                                     delegate: self
                                            cancelButtonTitle: @"Cancel"
                                       destructiveButtonTitle: @"Delete"
                                            otherButtonTitles: nil];
  [sheet showInView: self.view];
  [sheet release];
}

- (void) actionSheet: (UIActionSheet *) sheet clickedButtonAtIndex: (NSInteger) index {
  if (index == 0) {
    // ... delete ...
    self.navigationItem.rightBarButtonItem = loadingButton;
    [spinner startAnimating];
  }
  [self.tableView deselectRowAtIndexPath: RTIndex(1, 0) animated: YES];
}

- (void) cancelClicked {
  [activity release];
  activity = [originalActivity copy];
  [self.tableView reloadData];
  [self setEditing: NO animated: YES];
  self.navigationItem.leftBarButtonItem = nil;
  self.navigationItem.rightBarButtonItem = editButton;
  [spinner stopAnimating];
  // TODO: cancel request?

  [activityCommentsDialogController release];
  [activityDateDialogController release];
  [activityLengthDialogController release];
  [projectChoiceController release];
  activityCommentsDialogController = nil;
  activityDateDialogController = nil;
  activityLengthDialogController = nil;
  projectChoiceController = nil;
}

- (void) editClicked {
  [self setEditing: YES animated: YES];
  self.navigationItem.leftBarButtonItem = cancelButton;
  self.navigationItem.rightBarButtonItem = saveButton;
}

- (void) saveClicked {
  if ([activity.comments trimmedString].length == 0) {
    [Utils showAlertWithTitle: @"Can't save activity"
                      content: @"Activity comments field is empty - please fill it first."];
  } else {
    self.navigationItem.rightBarButtonItem = loadingButton;
    [spinner startAnimating];
    [connector editActivity: activity];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) requestFailed: (NSNotification *) notification {
  [spinner stopAnimating];
  self.navigationItem.rightBarButtonItem = saveButton;

  NSError *error = [notification.userInfo objectForKey: @"error"];
  NSString *text = [notification.userInfo objectForKey: @"text"];
  Request *request = [notification.userInfo objectForKey: @"request"];
  NSString *message = nil;
  if (error && error.domain == RubyTimeErrorDomain && error.code == 400 && text) {
    message = [self errorMessageFromJSON: text];
  } else if (error) {
    message = [error friendlyDescription];
  }
  if (!message) {
    if (request.type == RTEditActivityRequest) {
      message = @"Activity could not be saved.";
    } else {
      message = @"Activity could not be deleted.";
    }
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

- (void) activityEdited {
  [self setEditing: NO animated: YES];
  self.navigationItem.leftBarButtonItem = nil;
  self.navigationItem.rightBarButtonItem = editButton;
  [spinner stopAnimating];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
  return 2;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  if (section == 0) {
    return 4; // TODO: 5 if activity author is displayed too
  } else {
    return (self.editing ? 1 : 0);
  }
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  if (path.section == 0) {
    //if (path.row == 3) {
    //  return commentsCell;
    //} else {
      return [self tableView: table fieldCellForRow: path.row];
    //}
  } else {
    UITableViewCell *cell = [table cellWithStyle: UITableViewCellStyleDefault andIdentifier: DELETE_ACTIVITY_CELL_TYPE];
    cell.textLabel.text = @"Delete activity";
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.textColor = [UIColor colorWithRed: 0.7 green: 0.0 blue: 0.0 alpha: 1.0];
    return cell;
  }
}

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
      // TODO truncate comments value
  }
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

- (UITableViewCellEditingStyle) tableView: (UITableView *) table
            editingStyleForRowAtIndexPath: (NSIndexPath *) path {
  return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView: (UITableView *) table
         shouldIndentWhileEditingRowAtIndexPath: (NSIndexPath *) path {
  return NO;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) path {
  if (self.editing) {
    if (path.section == 0) {
      UIViewController *controller;
      switch (path.row) {
        case 0: controller = [self activityDateDialogController]; break;
        case 1: controller = [self projectChoiceController]; break;
        case 2: controller = [self activityLengthDialogController]; break;
        case 3: controller = [self activityCommentsDialogController]; break;
        default: return;
      }
      [self.navigationController pushViewController: controller animated: YES];
    } else {
      [self deleteActivityClicked];
    }
  } else {
    [tableView deselectRowAtIndexPath: path animated: YES];
  }
}

- (void) setEditing: (BOOL) editing animated: (BOOL) animated {
  [super setEditing: editing animated: animated];
  [self.tableView beginUpdates];
  [self.tableView setEditing: editing animated: animated];
  NSArray *indexes = RTArray(RTIndex(1, 0));
  if (editing) {
    [self.tableView insertRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  } else {
    [self.tableView deleteRowsAtIndexPaths: indexes withRowAnimation: UITableViewRowAnimationNone];
  }
  [self.tableView endUpdates];
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

@end

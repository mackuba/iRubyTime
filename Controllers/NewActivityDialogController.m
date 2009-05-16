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

#define NEW_ACTIVITY_CELL_TYPE @"NewActivityDialogCell"

@interface NewActivityDialogController ()
- (ActivityDateDialogController *) activityDateDialogController;
- (ActivityCommentsDialogController *) activityCommentsDialogController;
- (ProjectChoiceController *) projectChoiceController;
@end

@implementation NewActivityDialogController

@synthesize tableView, activityLengthPicker;

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithNibName: @"NewActivityDialog" bundle: [NSBundle mainBundle]];
  if (self) {
    connector = [rtConnector retain];
    activity = [[Activity alloc] init];
    // TODO: set activity's project based on recent entries
    // TODO: set activity's date
    // TODO: set activity length to sensible default based on recent entries
    
    activity.minutes = 450;
    activity.project = [connector.projects objectAtIndex: 0];
    activity.date = [NSDate date];
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
  UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
  UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                          target: self
                                                                          action: @selector(cancelClicked)];
  saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                                             target: self
                                                             action: @selector(saveClicked)];
  loadingButton = [[UIBarButtonItem alloc] initWithCustomView: spinner];
  back.title = @"Back";
  
  self.navigationItem.leftBarButtonItem = cancel;
  self.navigationItem.rightBarButtonItem = saveButton;
  self.navigationItem.backBarButtonItem = back;
  self.navigationItem.title = @"New activity";

  tableView.scrollEnabled = false;

  activityLengthPicker.countDownDuration = activity.minutes * 60;
  
  Observe(connector, @"requestFailed", activityNotCreated);
  
  [cancel release];
  [back release];
}

- (void) viewWillAppear: (BOOL) animated {
  [super viewWillAppear: animated];
  [tableView reloadData];
  NSIndexPath *selection = [tableView indexPathForSelectedRow];
  [tableView deselectRowAtIndexPath: selection animated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) saveClicked {
  if ([activity.comments trimmedString].length == 0) {
    [Utils showAlertWithTitle: @"Can't create activity"
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

- (void) activityNotCreated {
  [spinner stopAnimating];
  self.navigationItem.rightBarButtonItem = saveButton;
  [Utils showAlertWithTitle: @"Error" content: @"Activity could not be saved"];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
  return 3;
}

// TODO: extract common functionality from here and ActivityListController
- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [table dequeueReusableCellWithIdentifier: NEW_ACTIVITY_CELL_TYPE];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: NEW_ACTIVITY_CELL_TYPE] autorelease];
  }
  switch (path.row) {
    case 0: cell.text = RTFormat(@"Project: %@", activity.project.name); break;
    case 1: cell.text = RTFormat(@"Date: %@", activity.dateAsString); break;
    case 2: cell.text = RTFormat(@"%@", activity.comments); break;
  }
  return cell;
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return (path.row == 2) ? 92 : 44;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) path {
  UIViewController *controller;
  switch (path.row) {
    case 0: controller = [self projectChoiceController]; break;
    case 1: controller = [self activityDateDialogController]; break;
    case 2: controller = [self activityCommentsDialogController]; break;
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
                                                                    projectList: connector.projects];
  }
  return projectChoiceController;
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleanup

- (void) dealloc {
  StopObservingAll();
  ReleaseAll(tableView, activityLengthPicker, activity, connector, projectChoiceController,
    activityCommentsDialogController, activityDateDialogController, spinner, saveButton, loadingButton);
  [super dealloc];
}

@end

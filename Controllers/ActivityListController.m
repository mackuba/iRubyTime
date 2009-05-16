// -------------------------------------------------------
// ActivityListController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityCell.h"
#import "ActivityListController.h"
#import "LoginDialogController.h"
#import "NewActivityDialogController.h"
#import "RubyTimeAppDelegate.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

#define ACTIVITY_CELL_TYPE @"activityCell"

@implementation ActivityListController

@synthesize currentCell, connector;
OnDeallocRelease(loginController, connector, spinner);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (void) viewDidLoad {
  [super viewDidLoad];

  // prepare "loading" spinner
  spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
  spinner.frame = CGRectMake(0, 0, 36, 20);
  spinner.contentMode = UIViewContentModeCenter;
  
  // prepare buttons for toolbar
  UIBarButtonItem *loadingButton = [[UIBarButtonItem alloc] initWithCustomView: spinner];
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                             target: self
                                                                             action: @selector(showNewActivityDialog)];
  self.navigationItem.leftBarButtonItem = loadingButton;
  self.navigationItem.rightBarButtonItem = addButton;
  
  [loadingButton release];
  [addButton release];
  
  Observe(connector, @"authenticationSuccessful", loginSuccessful);
  Observe(connector, @"loadProjects", loading);
  Observe(connector, @"activitiesReceived", activitiesReceived:);
  Observe(connector, @"activityCreated", activityCreated:);
  Observe(nil, @"newActivityDialogCancelled", newActivityDialogCancelled:);
}

- (void) viewDidAppear: (BOOL) animated {
  [super viewDidAppear: animated];
  if (!connector.loggedIn) {
    loginController = [[LoginDialogController alloc] initWithConnector: connector];
    [self presentModalViewController: loginController animated: YES];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) scrollTextViewToTop {
  [self.tableView setContentOffset: CGPointZero animated: YES];
}

- (void) addActivitiesToList: (NSInteger) amount {
  NSMutableArray *rows = [[NSMutableArray alloc] initWithCapacity: amount];
  for (int i = 0; i < amount; i++) {
    [rows addObject: [NSIndexPath indexPathForRow: i inSection: 0]];
  }

  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths: rows withRowAnimation: UITableViewRowAnimationTop];
  [self.tableView endUpdates];
  
  [rows release];
}

- (void) loading {
  [spinner startAnimating];
}

- (void) showNewActivityDialog {
  NewActivityDialogController *dialog = [[NewActivityDialogController alloc] initWithConnector: connector];
  UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController: dialog];
  [self presentModalViewController: navigation animated: YES];
  [navigation release];
  [dialog release];
}

- (void) closeNewActivityDialog {
  [self dismissModalViewControllerAnimated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) loginSuccessful {
  if (loginController) {
    [loginController dismissModalViewControllerAnimated: YES];
    [loginController release];
    loginController = nil;
  }
}

- (void) activitiesReceived: (NSNotification *) notification {
  NSArray *activities = [[notification userInfo] objectForKey: @"activities"];
  if (activities.count > 0) {
    [self scrollTextViewToTop];
  }
  [self addActivitiesToList: activities.count];
  [spinner stopAnimating];
}

- (void) activityCreated: (NSNotification *) notification {
  [self scrollTextViewToTop];
  [self addActivitiesToList: 1];
  [self closeNewActivityDialog];
}

- (void) newActivityDialogCancelled: (NSNotification *) notification {
  [self closeNewActivityDialog];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return connector.activities.count;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  Activity *activity = [connector.activities objectAtIndex: path.row];
  ActivityCell *cell = (ActivityCell *) [table dequeueReusableCellWithIdentifier: ACTIVITY_CELL_TYPE];
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed: @"ActivityCell" owner: self options: nil];
    cell = currentCell;
  }
  [cell displayActivity: activity];
  return cell;
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return 69; // TODO: make variable height
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
  // TODO: show activity details controller
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end

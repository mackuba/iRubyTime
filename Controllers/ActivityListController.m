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

#define ACTIVITY_CELL_TYPE @"ActivityCell"

@interface ActivityListController ()
- (void) showLoginDialog;
@end

@implementation ActivityListController

@synthesize currentCell, connector;
OnDeallocRelease(connector, spinner);

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
  addButton.enabled = NO;

  Observe(connector, @"authenticationSuccessful", loginSuccessful);
  Observe(connector, @"authenticate", loading);
  Observe(connector, @"loadProjects", loading);
  Observe(connector, @"activitiesReceived", activitiesReceived:);
  Observe(connector, @"activityCreated", activityCreated);
  Observe(nil, @"newActivityDialogCancelled", newActivityDialogCancelled);
  
  [loadingButton release];
  [addButton release];
}

- (void) viewDidAppear: (BOOL) animated {
  [super viewDidAppear: animated];
  if (!connector.loggedIn) {
    if (connector.username && connector.password && connector.serverURL) {
      Observe(connector, @"requestFailed", requestFailed);
      Observe(connector, @"authenticationFailed", authenticationFailed);
      [connector authenticate];
    } else {
      [self showLoginDialog];
    }
  }
}

- (void) viewWillDisappear: (BOOL) animated {
  StopObserving(connector, @"requestFailed");
  StopObserving(connector, @"authenticationFailed");
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) scrollTextViewToTop {
  [self.tableView setContentOffset: CGPointZero animated: YES];
}

- (void) addActivityToList {
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths: RTArray(RTIndex(0, 0)) withRowAnimation: UITableViewRowAnimationTop];
  [self.tableView endUpdates];
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

- (void) showLoginDialog {
  LoginDialogController *loginController = [[LoginDialogController alloc] initWithConnector: connector];
  UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController: loginController];
  [self presentModalViewController: navigation animated: YES];
}

- (void) closeNewActivityDialog {
  [self dismissModalViewControllerAnimated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) loginSuccessful {
  // TODO: add a switch in list controller to see all activities or only user's
  [self dismissModalViewControllerAnimated: YES];
}

- (void) activitiesReceived: (NSNotification *) notification {
  [self.tableView reloadData];
  [spinner stopAnimating];
  self.navigationItem.rightBarButtonItem.enabled = (connector.projects.count > 0);
}

- (void) activityCreated {
  [self scrollTextViewToTop];
  [self addActivityToList];
  [self closeNewActivityDialog];
}

- (void) newActivityDialogCancelled {
  [self closeNewActivityDialog];
}

- (void) authenticationFailed {
  [self showLoginDialog];
}

- (void) requestFailed {
  [spinner stopAnimating];
  [Utils showAlertWithTitle: @"Error" content: @"Can't connect to the server."];
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

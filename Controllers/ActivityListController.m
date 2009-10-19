// -------------------------------------------------------
// ActivityListController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityCell.h"
#import "ActivityListController.h"
#import "LoadingView.h"
#import "LoginDialogController.h"
#import "NewActivityDialogController.h"
#import "RubyTimeAppDelegate.h"
#import "RubyTimeConnector.h"
#import "ShowActivityDialogController.h"
#import "Utils.h"

#define ACTIVITY_CELL_TYPE @"ActivityCell"

@interface ActivityListController ()
- (void) showLoginDialog;
- (void) showPopupDialog: (Class) controllerClass;
- (void) stopLoading;
@end

@implementation ActivityListController

@synthesize currentCell, connector;
OnDeallocRelease(connector);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (void) viewDidLoad {
  [super viewDidLoad];

  
  // prepare buttons for toolbar
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                             target: self
                                                                             action: @selector(showNewActivityDialog)];
  self.navigationItem.rightBarButtonItem = addButton;
  addButton.enabled = NO;

  Observe(connector, @"authenticationSuccessful", loginSuccessful);
  Observe(connector, @"authenticate", startLoading);
  Observe(connector, @"loadProjects", startLoading);
  Observe(connector, @"activitiesReceived", activitiesReceived);
  Observe(connector, @"activityCreated", activityCreated:);
  Observe(connector, @"activityDeleted", activityDeleted);
  Observe(nil, @"newActivityDialogCancelled", newActivityDialogCancelled);
  
  [addButton release];
}

- (void) viewDidAppear: (BOOL) animated {
  [super viewDidAppear: animated];
  [self.tableView reloadData];
  if (!connector.loggedIn) {
    if (connector.username && connector.password && connector.serverURL) {
      Observe(connector, @"requestFailed", requestFailed:);
      Observe(connector, @"authenticationFailed", authenticationFailed);
      [connector authenticate];
    } else {
      [self showLoginDialog];
    }
  } else {
    Observe(connector, @"requestFailed", requestFailed:);
    Observe(connector, @"authenticationFailed", authenticationFailed);
  }
}

- (void) viewWillDisappear: (BOOL) animated {
  StopObserving(connector, @"requestFailed");
  StopObserving(connector, @"authenticationFailed");
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) addActivityToList: (Activity *) activity {
  NSInteger index = [connector.activities indexOfObject: activity];
  if (index != NSNotFound) {
    UITableView *table = self.tableView;
    NSInteger count = connector.activities.count;
    NSIndexPath *newCellIndex = RTIndex(0, index);
    if (count > 1) {
      // don't scroll to the last one if it's not added yet (don't scroll at all if it's the first activity)
      NSIndexPath *scrollIndex = RTIndex(0, MIN(index, count - 2));
      [table scrollToRowAtIndexPath: scrollIndex atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
    [table beginUpdates];
    [table insertRowsAtIndexPaths: RTArray(newCellIndex) withRowAnimation: UITableViewRowAnimationTop];
    [table endUpdates];
    if (index == count - 1) {
      // now you can scroll to the last one
      [table scrollToRowAtIndexPath: newCellIndex atScrollPosition: UITableViewScrollPositionBottom animated: YES];
    }
  }
}

- (void) startLoading {
  if (!loadingView) {
    loadingView = [[LoadingView loadingViewInView: self.tableView.superview] retain];
  }
}

- (void) stopLoading {
  [loadingView removeView];
  [loadingView release];
  loadingView = nil;
}

- (void) showNewActivityDialog {
  [self showPopupDialog: [NewActivityDialogController class]];
}

- (void) showLoginDialog {
  [self showPopupDialog: [LoginDialogController class]];
}

- (void) closeNewActivityDialog {
  [self dismissModalViewControllerAnimated: YES];
}

- (void) showPopupDialog: (Class) controllerClass {
  id dialog = [[controllerClass alloc] initWithConnector: connector];
  UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController: dialog];
  [self presentModalViewController: navigation animated: YES];
  [navigation release];
  [dialog release];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) loginSuccessful {
  // TODO: add a switch in list controller to see all activities or only user's
  [self dismissModalViewControllerAnimated: YES];
}

- (void) activitiesReceived {
  [self.tableView reloadData];
  self.navigationItem.rightBarButtonItem.enabled = (connector.projects.count > 0);
  [self stopLoading];
}

- (void) activityCreated: (NSNotification *) notification {
  [self addActivityToList: [notification.userInfo objectForKey: @"activity"]];
  [self closeNewActivityDialog];
}

- (void) activityDeleted {
  [self.tableView reloadData];
}

- (void) newActivityDialogCancelled {
  [self closeNewActivityDialog];
}

- (void) authenticationFailed {
  [self showLoginDialog];
}

- (void) requestFailed: (NSNotification *) notification {
  [self stopLoading];
  NSError *error = [notification.userInfo objectForKey: @"error"];
  NSString *message = error ? [error friendlyDescription] : @"Can't connect to the server.";
  [Utils showAlertWithTitle: @"Error" content: message];
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
  return 69;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) path {
  Activity *activity = [connector.activities objectAtIndex: path.row];
  UIViewController *controller = [[ShowActivityDialogController alloc] initWithActivity: activity connector: connector];
  [self.navigationController pushViewController: controller animated: YES];
  [tableView deselectRowAtIndexPath: path animated: YES];
  [controller release];
}

@end

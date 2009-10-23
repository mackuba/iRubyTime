// -------------------------------------------------------
// ActivityListController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityCell.h"
#import "ActivityListController.h"
#import "BaseViewController.h"
#import "NewActivityDialogController.h"
#import "RubyTimeConnector.h"
#import "ShowActivityDialogController.h"
#import "Utils.h"

#define ACTIVITY_CELL_TYPE @"ActivityCell"

@implementation ActivityListController

@synthesize currentCell;

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStylePlain];
  if (self) {
    self.title = @"My activities";
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"clock.png"];
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                             target: self
                                                                             action: @selector(showNewActivityDialog)];
  self.navigationItem.rightBarButtonItem = addButton;
  [addButton setEnabled: NO];
  [addButton release];
}

- (void) initializeView {
  [super initializeView];
  Observe(connector, ActivityCreatedNotification, activityCreated:);
  Observe(connector, ActivityDeletedNotification, activityDeleted);
  Observe(nil, ActivityDialogCancelledNotification, hidePopupView);
}

- (BOOL) needsOwnData {
  return YES;
}

- (void) fetchData {
  Observe(connector, ActivitiesReceivedNotification, activitiesReceived);
  [connector loadActivities];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) addActivityToList: (Activity *) activity {
  NSInteger index = [connector.activities indexOfObject: activity];
  if (index != NSNotFound) {
    NSInteger count = connector.activities.count;
    NSIndexPath *newCellIndex = RTIndex(0, index);
    if (count > 1) {
      // don't scroll to the last one if it's not added yet (don't scroll at all if it's the first activity)
      NSIndexPath *scrollIndex = RTIndex(0, MIN(index, count - 2));
      [tableView scrollToRowAtIndexPath: scrollIndex atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths: RTArray(newCellIndex) withRowAnimation: UITableViewRowAnimationTop];
    [tableView endUpdates];
    if (index == count - 1) {
      // now you can scroll to the last one
      [tableView scrollToRowAtIndexPath: newCellIndex atScrollPosition: UITableViewScrollPositionBottom animated: YES];
    }
  }
}

- (void) showNewActivityDialog {
  [self showPopupView: [NewActivityDialogController class]];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) activitiesReceived {
  [self initializeView];
  self.navigationItem.rightBarButtonItem.enabled = (connector.projects.count > 0);
  StopObserving(connector, ActivitiesReceivedNotification);
}

- (void) activityCreated: (NSNotification *) notification {
  [self addActivityToList: [notification.userInfo objectForKey: @"activity"]];
  [self hidePopupView];
}

- (void) activityDeleted {
  [tableView reloadData];
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

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  Activity *activity = [connector.activities objectAtIndex: path.row];
  UIViewController *controller = [[ShowActivityDialogController alloc] initWithActivity: activity connector: connector];
  [self.navigationController pushViewController: controller animated: YES];
  [table deselectRowAtIndexPath: path animated: YES];
  [controller release];
}

@end

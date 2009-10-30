// -------------------------------------------------------
// ActivityListController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Activity.h"
#import "ActivityCell.h"
#import "ActivityListController.h"
#import "ActivityManager.h"
#import "BaseViewController.h"
#import "NewActivityDialogController.h"
#import "RubyTimeConnector.h"
#import "ShowActivityDialogController.h"
#import "Utils.h"

#define ACTIVITY_CELL_TYPE @"ActivityCell"

@interface ActivityListController ()
- (void) showActivityDetailsDialogForActivity: (Activity *) activity;
@end

@implementation ActivityListController

@synthesize currentCell;
OnDeallocRelease(manager);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization and settings

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStylePlain];
  if (self) {
    manager = [[ActivityManager alloc] init];
    dataIsLoaded = NO;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  if ([self hasNewActivityButton]) {
    UIBarButtonItem *addButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                    target: self
                                                    action: @selector(showNewActivityDialog)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton setEnabled: NO];
    [addButton release];
  }
}

// override in subclasses
- (BOOL) hasNewActivityButton {
  return NO;
}

- (BOOL) needsOwnData {
  return !dataIsLoaded;
}

// override in subclasses and call super
- (void) fetchData {
  Observe(connector, ActivitiesReceivedNotification, activitiesReceived:);
}

// override in subclasses
- (NSString *) cellNibName {
  return @"ActivityCellWithProject";
}

- (NSInteger) defaultLengthForNewActivity {
  if (manager.activities.count > 0) {
    return [[manager.activities valueForKeyPath: @"@avg.minutes"] intValue];
  } else {
    return 7 * 60;
  }
}

- (Project *) defaultProjectForNewActivity {
  if (manager.activities.count > 0) {
    return [[manager.activities objectAtIndex: 0] project];
  } else {
    return [[Project list] objectAtIndex: 0];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) addActivityToList: (Activity *) activity {
  [manager addNewActivity: activity];
  NSInteger index = [manager.activities indexOfObject: activity];
  if (index != NSNotFound) {
    NSInteger count = manager.activities.count;
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
  NewActivityDialogController *dialog;
  dialog = [[NewActivityDialogController alloc] initWithConnector: connector
                                                   defaultProject: [self defaultProjectForNewActivity]
                                                    defaultLength: [self defaultLengthForNewActivity]];
  [self showPopupView: dialog];
  Observe(connector, ActivityCreatedNotification, activityCreated:);
  Observe(dialog, ActivityDialogCancelledNotification, hidePopupView);
  [dialog release];
}

- (void) showActivityDetailsDialogForActivity: (Activity *) activity {
  ShowActivityDialogController *controller =
    [[ShowActivityDialogController alloc] initWithActivity: activity connector: connector];
  controller.displaysActivityUser = (connector.account.userType != Employee);
  [self.navigationController pushViewController: controller animated: YES];
  [controller release];
  Observe(connector, ActivityDeletedNotification, activityDeleted:);
  Observe(connector, ActivityUpdatedNotification, activityUpdated:);
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) activitiesReceived: (NSNotification *) notification {
  dataIsLoaded = YES;
  NSArray *activities = [notification.userInfo objectForKey: @"activities"];
  [manager setActivities: activities];
  [self initializeView];
  self.navigationItem.rightBarButtonItem.enabled = ([Project count] > 0);
  StopObserving(connector, ActivitiesReceivedNotification);
}

- (void) activityCreated: (NSNotification *) notification {
  Activity *activity = [notification.userInfo objectForKey: @"activity"];
  [self addActivityToList: activity];
  [self hidePopupView];
}

- (void) activityDeleted: (NSNotification *) notification {
  Activity *activity = [notification.userInfo objectForKey: @"activity"];
  [manager deleteActivity: activity];
  [tableView reloadData];
}

- (void) activityUpdated: (NSNotification *) notification {
  Activity *activity = [notification.userInfo objectForKey: @"activity"];
  [manager updateActivity: activity];
  [tableView reloadData];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return manager.activities.count;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  Activity *activity = [manager.activities objectAtIndex: path.row];
  ActivityCell *cell = (ActivityCell *) [table dequeueReusableCellWithIdentifier: ACTIVITY_CELL_TYPE];
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed: [self cellNibName] owner: self options: nil];
    cell = currentCell;
  }
  [cell displayActivity: activity];
  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  Activity *activity = [manager.activities objectAtIndex: path.row];
  [self showActivityDetailsDialogForActivity: activity];
  [table deselectRowAtIndexPath: path animated: YES];
}

@end

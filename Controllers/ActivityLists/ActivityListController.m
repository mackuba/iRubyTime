// -------------------------------------------------------
// ActivityListController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Activity.h"
#import "ActivityCell.h"
#import "ActivityDateFormatter.h"
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
- (void) loadMore;
@end

@implementation ActivityListController

@synthesize currentCell, loadMoreSpinner, loadMoreCell, loadMoreLabel;
OnDeallocRelease(manager, loadMoreSpinner, loadMoreCell, loadMoreLabel);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization and settings

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStylePlain];
  if (self) {
    [[NSBundle mainBundle] loadNibNamed: @"ShowMoreCell" owner: self options: nil];
    manager = [[ActivityManager alloc] init];
    dataIsLoaded = NO;
    hasMoreActivities = YES;
    loadMoreRequestSent = NO;
    loadMoreLabelColor = [[loadMoreLabel textColor] retain];
    listOffset = 0;
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

- (void) initializeView {
  [super initializeView];
  if (loadMoreRequestSent) {
    [self loadMore];
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

// override in subclasses
- (NSInteger) activityBatchSize { AbstractMethod(return 0); }

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

- (void) loadMore {
  loadMoreRequestSent = YES;
  loadMoreLabel.textColor = [UIColor lightGrayColor];
  [loadMoreSpinner startAnimating];
  [self fetchData];
}

- (void) restoreLoadMoreLabel {
  loadMoreRequestSent = NO;
  loadMoreLabel.textColor = loadMoreLabelColor;
  [loadMoreSpinner stopAnimating];
}

// -------------------------------------------------------------------------------------------
#pragma mark Notification callbacks

- (void) activitiesReceived: (NSNotification *) notification {
  dataIsLoaded = YES;
  NSArray *activities = [notification.userInfo objectForKey: @"activities"];
  [manager appendActivities: activities];
  hasMoreActivities = (activities.count == [self activityBatchSize]);
  listOffset += activities.count;
  [self restoreLoadMoreLabel];
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

- (Activity *) activityAtPath: (NSIndexPath *) path {
  NSDate *date = [manager.allDates objectAtIndex: path.section];
  return [[manager activitiesOnDay: date] objectAtIndex: path.row];
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) table {
  return (dataIsLoaded && hasMoreActivities) ? (manager.allDates.count + 1) : manager.allDates.count;
}

- (NSString *) tableView: (UITableView *) table titleForHeaderInSection: (NSInteger) section {
  if (section == manager.allDates.count) {
    return nil;
  } else {
    NSDate *date = [manager.allDates objectAtIndex: section];
    return [[ActivityDateFormatter sharedFormatter] formatDate: date withAliases: YES];
  }
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  // show 'load more' cell too, but only if it makes sense
  if (section == manager.allDates.count) {
    return 1;
  } else {
    NSDate *date = [manager.allDates objectAtIndex: section];
    return [[manager activitiesOnDay: date] count];
  }
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  if (path.section == manager.allDates.count) {
    return loadMoreCell;
  } else {
    Activity *activity = [self activityAtPath: path];
    ActivityCell *cell = (ActivityCell *) [table dequeueReusableCellWithIdentifier: ACTIVITY_CELL_TYPE];
    if (!cell) {
      [[NSBundle mainBundle] loadNibNamed: [self cellNibName] owner: self options: nil];
      cell = currentCell;
    }
    [cell displayActivity: activity];
    return cell;
  }
}

- (NSIndexPath*) tableView: (UITableView *) table willSelectRowAtIndexPath: (NSIndexPath *) path {
  if (path.section == manager.allDates.count && loadMoreRequestSent) {
    // don't allow selecting 'load more' cell if the spinner is spinning
    return nil;
  } else {
    return path;
  }
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  if (path.section == manager.allDates.count) {
    [self loadMore];
  } else {
    [self showActivityDetailsDialogForActivity: [self activityAtPath: path]];
  }
  [table deselectRowAtIndexPath: path animated: YES];
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  if (path.section == manager.allDates.count) {
    return loadMoreCell.frame.size.height;
  } else {
    return 69;
  }
}

@end

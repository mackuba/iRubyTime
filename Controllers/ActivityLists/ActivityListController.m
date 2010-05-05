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
#import "ServerConnector.h"
#import "ShowActivityDialogController.h"
#import "Utils.h"


@interface ActivityListController ()
- (void) showActivityDetailsDialogForActivity: (Activity *) activity;
- (NSIndexPath *) indexPathForActivity: (Activity *) activity;
- (void) loadMore;
@end


@implementation ActivityListController

@synthesize currentCell, loadMoreSpinner, loadMoreCell, loadMoreLabel;
PSReleaseOnDealloc(manager, loadMoreSpinner, loadMoreCell, loadMoreLabel);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization and settings

- (id) initWithConnector: (ServerConnector *) rtConnector {
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
  PSObserve(connector, ActivitiesReceivedNotification, activitiesReceived:);
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
  BOOL isOnlyOne = (manager.activities.count == 1);
  BOOL isOnlyOneInSection = ([manager activitiesOnDay: activity.date].count == 1);
  BOOL isLastOne = isOnlyOne || ([manager.activities objectAtIndex: manager.activities.count - 1] == activity);
  NSIndexPath *newCellIndex = [self indexPathForActivity: activity];

  if (!isOnlyOne) {
    NSIndexPath *scrollIndex;
    if (isLastOne) {
      Activity *nextToLast = [manager.activities objectAtIndex: manager.activities.count - 2];
      scrollIndex = [self indexPathForActivity: nextToLast];
    } else {
      scrollIndex = newCellIndex;
    }
    [tableView scrollToRowAtIndexPath: scrollIndex atScrollPosition: UITableViewScrollPositionTop animated: YES];
  }

  [tableView beginUpdates];
  if (isOnlyOneInSection) {
    NSIndexSet *sectionSet = [NSIndexSet indexSetWithIndex: newCellIndex.section];
    [tableView insertSections: sectionSet withRowAnimation: UITableViewRowAnimationNone];
  }
  [tableView insertRowsAtIndexPaths: PSArray(newCellIndex) withRowAnimation: UITableViewRowAnimationNone];
  [tableView endUpdates];

  if (!isOnlyOne && isLastOne) {
    [tableView scrollToRowAtIndexPath: newCellIndex atScrollPosition: UITableViewScrollPositionBottom animated: YES];
  }
}

- (void) showNewActivityDialog {
  NewActivityDialogController *dialog;
  dialog = [[NewActivityDialogController alloc] initWithConnector: connector
                                                   defaultProject: [self defaultProjectForNewActivity]
                                                    defaultLength: [self defaultLengthForNewActivity]];
  [self showPopupView: dialog];
  PSObserve(connector, ActivityCreatedNotification, activityCreated:);
  PSObserve(dialog, ActivityDialogCancelledNotification, hidePopupView);
  [dialog release];
}

- (void) showActivityDetailsDialogForActivity: (Activity *) activity {
  ShowActivityDialogController *controller =
    [[ShowActivityDialogController alloc] initWithActivity: activity connector: connector];
  controller.displaysActivityUser = (connector.account.userType != Employee);
  [self.navigationController pushViewController: controller animated: YES];
  [controller release];
  PSObserve(connector, ActivityDeletedNotification, activityDeleted:);
  PSObserve(connector, ActivityUpdatedNotification, activityUpdated:);
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
  PSStopObserving(connector, ActivitiesReceivedNotification);
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
  [self.navigationController popViewControllerAnimated: YES];
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

- (NSIndexPath *) indexPathForActivity: (Activity *) activity {
  NSInteger section = [manager.allDates indexOfObject: activity.date];
  NSInteger row = [[manager activitiesOnDay: activity.date] indexOfObject: activity];
  return (row != NSNotFound && section != NSNotFound) ? PSIndex(section, row) : PSIndex(0, 0);
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
    ActivityCell *cell = (ActivityCell *) [table dequeueReusableCellWithIdentifier: PSGenericCell];
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

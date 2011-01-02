// -------------------------------------------------------
// SearchResultsController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Project.h"
#import "SearchFormController.h"
#import "SearchResultsController.h"
#import "ServerConnector.h"
#import "Utils.h"

@implementation SearchResultsController

PSReleaseOnDealloc(parentController);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithParentController: (SearchFormController *) parent
                      connector: (ServerConnector *) rtConnector {
  self = [super initWithConnector: rtConnector];
  if (self) {
    self.title = @"Search results";
    [self psSetBackButtonTitle: @"Results"];
    parentController = [parent retain];
  }
  return self;
}

- (NSString *) cellNibName {
  if ([connector.account userType] == Employee) {
    return @"ActivityCellWithProject";
  } else if ([Project count] == 1) {
    return @"ActivityCellWithUser";
  } else {
    return @"ActivityCellWithBoth";
  }
}

- (NSInteger) activityBatchSize {
  return -1; // never show 'load more'
}

- (void) viewDidAppear: (BOOL) animated {
  [super viewDidAppear: animated];
  if (self.navigationController.viewControllers.count == 3) {
    NSMutableArray *stack = [self.navigationController.viewControllers mutableCopy];
    [stack removeObjectAtIndex: 1];
    [self.navigationController setViewControllers: stack animated: NO];
    [stack release];
  }
}

- (void) fetchData {
  [super fetchData];
  PSRequest *request = [connector searchActivitiesRequestWithProject: parentController.project
                                                                user: parentController.user
                                                           startDate: parentController.startDate
                                                             endDate: parentController.endDate];
  [request send];
}

- (void) activitiesReceived: (NSNotification *) notification {
  NSArray *activities = [notification.userInfo objectForKey: @"activities"];
  if (activities.count > 0) {
    [super activitiesReceived: notification];
  } else {
    // the nav controller gets confused if we call this when the previous animation hasn't finished yet
    [self performSelector: @selector(noActivitiesReceived) withObject: nil afterDelay: 0.5];
  }
}

- (void) noActivitiesReceived {
  [parentController showNotFoundMessage];
  [self.navigationController popViewControllerAnimated: YES];
}

@end

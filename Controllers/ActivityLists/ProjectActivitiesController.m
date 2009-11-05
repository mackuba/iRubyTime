// -------------------------------------------------------
// ProjectActivitiesController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Project.h"
#import "ProjectActivitiesController.h"
#import "ServerConnector.h"
#import "Utils.h"

@implementation ProjectActivitiesController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector project: (Project *) project {
  self = [super initWithConnector: rtConnector];
  if (self) {
    displayedProject = [project retain];
    self.title = project.name;
  }
  return self;
}

- (BOOL) hasNewActivityButton {
  return (connector.account.userType != ClientUser);
}

- (Project *) defaultProjectForNewActivity {
  return displayedProject;
}

- (NSString *) cellNibName {
  return (connector.account.userType == Employee) ? @"ActivityCellWithProject" : @"ActivityCellWithUser";
}

- (NSInteger) activityBatchSize {
  return (connector.account.userType == Employee) ? 20 : 25;
}

- (void) fetchData {
  [super fetchData];
  [connector loadActivitiesForProject: displayedProject limit: [self activityBatchSize] offset: listOffset];
}

@end

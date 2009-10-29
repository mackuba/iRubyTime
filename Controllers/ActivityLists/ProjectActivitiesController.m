// -------------------------------------------------------
// ProjectActivitiesController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "Project.h"
#import "ProjectActivitiesController.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

@implementation ProjectActivitiesController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector project: (Project *) project {
  self = [super initWithConnector: rtConnector];
  if (self) {
    displayedProject = [project retain];
    self.title = RTFormat(@"%@ activities", project.name);
  }
  return self;
}

- (BOOL) hasNewActivityButton {
  return (connector.account.userType != ClientUser);
}

- (Project *) defaultProjectForNewActivity {
  return displayedProject;
}

- (void) fetchData {
  [super fetchData];
  [connector loadActivitiesForProject: displayedProject];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return 69;
}

@end

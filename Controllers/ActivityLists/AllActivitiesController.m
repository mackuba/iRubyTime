// -------------------------------------------------------
// AllActivitiesController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "AllActivitiesController.h"
#import "Project.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

@implementation AllActivitiesController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector];
  if (self) {
    self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem: UITabBarSystemItemRecents tag: 0];
    self.title = @"Recent activities";
    [self setBackButtonTitle: @"Recent"];
  }
  return self;
}

- (BOOL) hasNewActivityButton {
  return (connector.account.userType != ClientUser);
}

- (NSString *) cellNibName {
  if (connector.account.userType == Employee) {
    return @"ActivityCellWithProject";
  } else if ([Project count] == 1) {
    return @"ActivityCellWithUser";
  } else {
    return @"ActivityCellWithBoth";
  }
}

- (void) fetchData {
  [super fetchData];
  [connector loadAllActivities];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return 69;
}

@end

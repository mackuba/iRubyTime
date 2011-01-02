// -------------------------------------------------------
// AllActivitiesController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "AllActivitiesController.h"
#import "Project.h"
#import "ServerConnector.h"
#import "Utils.h"

@implementation AllActivitiesController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector {
  self = [super initWithConnector: rtConnector];
  if (self) {
    self.title = @"Recent activities";
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"clock.png"];
    self.tabBarItem.title = @"Activities";
    [self psSetBackButtonTitle: @"Activities"];
  }
  return self;
}

- (BOOL) hasNewActivityButton {
  return ([connector.account userType] != ClientUser);
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
  switch ([connector.account userType]) {
    case ClientUser:
      return 30;
    case Admin:
      return 40;
    case Employee:
    default:
      return 20;
  }
}

- (void) fetchData {
  [super fetchData];
  [[connector loadActivitiesRequestWithLimit: [self activityBatchSize] offset: listOffset] send];
}

@end

// -------------------------------------------------------
// UserActivitiesController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "ServerConnector.h"
#import "User.h"
#import "UserActivitiesController.h"
#import "Utils.h"

@implementation UserActivitiesController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector user: (User *) user {
  self = [super initWithConnector: rtConnector];
  if (self) {
    displayedUser = [user retain];
    self.title = user.name;
    if (user.name.length > 11) {
      NSString *firstName = [[user.name componentsSeparatedByString: @" "] objectAtIndex: 0];
      [self setBackButtonTitle: firstName];
    }
  }
  return self;
}

- (BOOL) hasNewActivityButton {
  return ([displayedUser isEqual: connector.account]);
}

- (NSInteger) activityBatchSize {
  return 20;
}

- (void) fetchData {
  [super fetchData];
  [connector loadActivitiesForUser: displayedUser limit: [self activityBatchSize] offset: listOffset];
}

@end

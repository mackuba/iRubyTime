// -------------------------------------------------------
// UserActivitiesController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "RubyTimeConnector.h"
#import "User.h"
#import "UserActivitiesController.h"
#import "Utils.h"

@implementation UserActivitiesController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector user: (User *) user {
  self = [super initWithConnector: rtConnector];
  if (self) {
    displayedUser = [user retain];
    isAccountOwner = [user isEqual: rtConnector.account];
    if (isAccountOwner) {
      self.title = @"My activities";
      self.tabBarItem.image = [UIImage loadImageFromBundle: @"clock.png"];
    } else {
      self.title = RTFormat(@"%@'s activities", user.name);
    }
  }
  return self;
}

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  return [self initWithConnector: rtConnector user: rtConnector.account];
}

- (BOOL) hasNewActivityButton {
  return isAccountOwner;
}

- (void) fetchData {
  [super fetchData];
  [connector loadActivitiesForUser: displayedUser];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return 69;
}

@end

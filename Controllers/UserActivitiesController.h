// -------------------------------------------------------
// UserActivitiesController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "ActivityListController.h"

@class User;

@interface UserActivitiesController : ActivityListController {
  User *displayedUser;
  BOOL isAccountOwner;
}

// for other user
- (id) initWithConnector: (RubyTimeConnector *) rtConnector user: (User *) user;

// for my own activities
- (id) initWithConnector: (RubyTimeConnector *) rtConnector;

@end

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
}

- (id) initWithConnector: (RubyTimeConnector *) rtConnector user: (User *) user;

@end

// -------------------------------------------------------
// UserListController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "RubyTimeConnector.h"
#import "User.h"
#import "UserActivitiesController.h"
#import "UserListController.h"
#import "Utils.h"

#define USER_CELL_TYPE @"UserCell"

@interface UserListController ()
- (UserActivitiesController *) subcontrollerForUser: (User *) user;
@end

@implementation UserListController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStylePlain];
  if (self) {
    self.title = @"Users";
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"walk.png"];
    subcontrollers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return connector.users.count;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [table cellWithStyle: UITableViewCellStyleDefault andIdentifier: USER_CELL_TYPE];
  User *user = [connector.users objectAtIndex: path.row];
  cell.textLabel.text = user.name;
  if ([user isEqual: connector.account]) {
    cell.textLabel.font = [UIFont boldSystemFontOfSize: 16];
  } else {
    cell.textLabel.font = [UIFont systemFontOfSize: 16];
  }
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  User *user = [connector.users objectAtIndex: path.row];
  ActivityListController *controller = [self subcontrollerForUser: user];
  [self.navigationController pushViewController: controller animated: YES];
  [table deselectRowAtIndexPath: path animated: YES];
  [controller fetchDataIfNeeded];
}

- (UserActivitiesController *) subcontrollerForUser: (User *) user {
  UserActivitiesController *controller = [subcontrollers objectForKey: user];
  if (!controller) {
    controller = [[UserActivitiesController alloc] initWithConnector: connector user: user];
    [subcontrollers setObject: controller forKey: user];
    [controller release];
  }
  return controller;
}

@end
// -------------------------------------------------------
// SettingsController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "RubyTimeConnector.h"
#import "SettingsController.h"
#import "Utils.h"

#define SETTINGS_CELL_TYPE @"SettingsCell"

typedef enum { ServerRow, LoginRow, VersionRow } RowType;

@interface SettingsController ()
@end


@implementation SettingsController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (RubyTimeConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStyleGrouped];
  if (self) {
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"gear.png"];
    self.title = @"Settings";
  }
  return self;
}

/*- (void) viewWillAppear: (BOOL) animated {
  [super viewWillAppear: animated];
  NSIndexPath *selection = [tableView indexPathForSelectedRow];
  [tableView deselectRowAtIndexPath: selection animated: YES];
}*/

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (IntArray *) rowTypesForSection: (NSInteger) section {
  switch (section) {
    case 0: return [IntArray arrayOfSize: 2 integers: ServerRow, LoginRow];
    case 1: return [IntArray arrayOfSize: 1 integers: VersionRow];
    default: return [IntArray emptyArray];
  }
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) table {
  return 2;
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return [[self rowTypesForSection: section] size];
}

- (NSString *) tableView: (UITableView *) table titleForHeaderInSection: (NSInteger) section {
  switch (section) {
    case 0: return @"Your account";
    case 1: return @"About iRubyTime";
    default: return @"";
  }
}

- (RowType) rowTypeAtIndexPath: (NSIndexPath *) path {
  return [[self rowTypesForSection: path.section] integerAtIndex: path.row];
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [tableView cellWithStyle: UITableViewCellStyleValue1 andIdentifier: SETTINGS_CELL_TYPE];
  switch ([self rowTypeAtIndexPath: path]) {
    case ServerRow:
      cell.textLabel.text = @"Server URL";
      cell.detailTextLabel.text = connector.account.serverURL;
      break;

    case LoginRow:
      cell.textLabel.text = @"Username";
      cell.detailTextLabel.text = connector.account.username;
      break;

    case VersionRow:
      cell.textLabel.text = @"App version";
      cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"];
      break;

    default:
      break;
  }
  return cell;
}

- (void) tableView: (UITableView *) table didSelectRowAtIndexPath: (NSIndexPath *) path {
  [table deselectRowAtIndexPath: path animated: YES];
}

@end

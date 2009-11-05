// -------------------------------------------------------
// SettingsController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Account.h"
#import "ApplicationDelegate.h"
#import "LoginDialogController.h"
#import "ServerConnector.h"
#import "SettingsController.h"
#import "Utils.h"

typedef enum { ServerRow, LoginRow, VersionRow } RowType;

@implementation SettingsController

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector {
  self = [super initWithConnector: rtConnector andStyle: UITableViewStyleGrouped];
  if (self) {
    self.tabBarItem.image = [UIImage loadImageFromBundle: @"gear.png"];
    self.title = @"Settings";
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) loginClicked {
  currentAccount = [connector.account retain];
  LoginDialogController *loginDialog = [[LoginDialogController alloc] initWithConnector: connector];
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel"
                                                                   style: UIBarButtonItemStyleBordered
                                                                  target: self
                                                                  action: @selector(cancelLoginClicked)];
  loginDialog.navigationItem.leftBarButtonItem = [cancelButton autorelease];
  [self showPopupView: [loginDialog autorelease]];
  Observe(connector, AuthenticationSuccessfulNotification, loginSuccessful);
}

- (void) cancelLoginClicked {
  StopObserving(connector, AuthenticationSuccessfulNotification);
  [connector dropCurrentConnection];
  connector.account = [currentAccount autorelease];
  currentAccount = nil;
  [self hidePopupView];
}

- (void) loginSuccessful {
  StopObserving(connector, AuthenticationSuccessfulNotification);
  id applicationDelegate = [[UIApplication sharedApplication] delegate];
  [applicationDelegate reloginSuccessful];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (IntArray *) rowTypesForSection: (NSInteger) section {
  switch (section) {
    case 0: return [IntArray arrayOfSize: 2 integers: ServerRow, LoginRow];
    case 1: return [IntArray arrayOfSize: 1 integers: VersionRow];
    default: return [IntArray emptyArray];
  }
}

- (UIView *) logInFooterView {
  static UIView *footerView = nil;
  if (!footerView) {
    footerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 70)];
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    CGSize buttonSize = CGSizeMake(220, 40);
    button.frame = CGRectMake(
      (footerView.frame.size.width - buttonSize.width) / 2,
      (footerView.frame.size.height - buttonSize.height) / 2,
      buttonSize.width,
      buttonSize.height
    );
    [button setTitle: @"Switch to another account" forState: UIControlStateNormal];
    [button addTarget: self action: @selector(loginClicked) forControlEvents: UIControlEventTouchUpInside];
    [footerView addSubview: button];
  }
  return footerView;
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

- (UIView *) tableView: (UITableView *) table viewForFooterInSection: (NSInteger) section {
  return (section == 0) ? [self logInFooterView] : nil;
}

- (CGFloat) tableView: (UITableView *) table heightForFooterInSection: (NSInteger) section {
  return (section == 0) ? [self logInFooterView].frame.size.height : 0;
}

- (RowType) rowTypeAtIndexPath: (NSIndexPath *) path {
  return [[self rowTypesForSection: path.section] integerAtIndex: path.row];
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  UITableViewCell *cell = [tableView genericCellWithStyle: UITableViewCellStyleValue1];
  switch ([self rowTypeAtIndexPath: path]) {
    case ServerRow:
      cell.textLabel.text = @"Server URL";
      cell.textLabel.adjustsFontSizeToFitWidth = YES;
      cell.textLabel.minimumFontSize = 16.0;
      cell.detailTextLabel.text = connector.account.serverURL;
      cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
      cell.detailTextLabel.minimumFontSize = 8.0;
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
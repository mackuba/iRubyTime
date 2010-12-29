// -------------------------------------------------------
// LoggedOutViewController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ApplicationDelegate.h"
#import "LoginDialogController.h"
#import "LoggedOutViewController.h"
#import "ServerConnector.h"
#import "Utils.h"

@implementation LoggedOutViewController

@synthesize footerView;
PSReleaseOnDealloc(footerView, connector);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithConnector: (ServerConnector *) rtConnector {
  self = [super initWithStyle: UITableViewStyleGrouped];
  if (self) {
    connector = rtConnector;
    [[NSBundle mainBundle] loadNibNamed: @"LoggedOutView" owner: self options: nil];
    self.tableView.scrollEnabled = NO;
  }
  return self;
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation {
  return (RTiPad ? YES : (orientation == UIInterfaceOrientationPortrait));
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (void) loginClicked {
  LoginDialogController *loginDialog = [[LoginDialogController alloc] initWithConnector: connector];
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel"
                                                                   style: UIBarButtonItemStyleBordered
                                                                  target: self
                                                                  action: @selector(cancelLoginClicked)];
  loginDialog.navigationItem.leftBarButtonItem = [cancelButton autorelease];
  UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController: loginDialog];
  if ([self respondsToSelector: @selector(setModalPresentationStyle:)]) {
    navigation.modalPresentationStyle = UIModalPresentationPageSheet;
  }
  [self presentModalViewController: navigation animated: YES];
  [navigation release];
  [loginDialog release];
  PSObserve(connector, AuthenticationSuccessfulNotification, loginSuccessful);
}

- (void) cancelLoginClicked {
  PSStopObserving(connector, AuthenticationSuccessfulNotification);
  [connector dropCurrentConnection];
  connector.account = nil;
  [self dismissModalViewControllerAnimated: YES];
}

- (void) loginSuccessful {
  PSStopObserving(connector, AuthenticationSuccessfulNotification);
  id applicationDelegate = [[UIApplication sharedApplication] delegate];
  [applicationDelegate reloginSuccessful];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate & data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return 0;
}

- (UIView *) tableView: (UITableView *) table viewForFooterInSection: (NSInteger) section {
  return footerView;
}

- (CGFloat) tableView: (UITableView *) table heightForFooterInSection: (NSInteger) section {
  return footerView.frame.size.height;
}

@end

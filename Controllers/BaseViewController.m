// -------------------------------------------------------
// BaseViewController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "BaseViewController.h"
#import "LoadingView.h"
#import "LoginDialogController.h"
#import "RubyTimeConnector.h"
#import "Utils.h"

@implementation BaseViewController

@synthesize connector;
OnDeallocRelease(connector, loadingView);

- (id) initWithConnector: (RubyTimeConnector *) rtConnector { AbstractMethod(return nil) }

- (id) initWithConnector: (RubyTimeConnector *) rtConnector andStyle: (UITableViewStyle) style {
  self = [super init];
  if (self) {
    connector = [rtConnector retain];
    tableStyle = style;
  }
  return self;
}

- (void) loadView {
  CGRect windowSize = [[[UIApplication sharedApplication] keyWindow] frame];
  UIView *wrapperView = [[UIView alloc] initWithFrame: windowSize];
  tableView = [[UITableView alloc] initWithFrame: windowSize style: tableStyle];
  tableView.delegate = self;
  tableView.dataSource = self;
  [wrapperView addSubview: tableView];
  self.view = [wrapperView autorelease];
}

- (void) showLoadingMessage {
  if (!loadingView) {
    loadingView = [[LoadingView loadingViewInView: self.view] retain];
  }
}

- (void) hideLoadingMessage {
  [loadingView removeView];
  [loadingView release];
  loadingView = nil;
}

- (void) showPopupView: (UIViewController *) controller {
  UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController: controller];
  [self presentModalViewController: navigation animated: YES];
  [navigation release];
}

- (void) hidePopupView {
  [self dismissModalViewControllerAnimated: YES];
}

// override in subclasses and return YES if the controller needs to fetch data (activities) before it's displayed
- (BOOL) needsOwnData {
  return NO;
}

// override in subclasses if the controller needs to fetch data
- (void) fetchData {
}

- (void) fetchDataIfNeeded {
  if ([self needsOwnData]) {
    [self showLoadingMessage];
    [self fetchData];
  } else {
    [self initializeView];
  }
}

- (void) initializeView {
  [tableView reloadData];
  [self hideLoadingMessage];
}

- (void) viewWillAppear: (BOOL) animated {
  Observe(connector, RequestFailedNotification, requestFailed:);
  [tableView reloadData];
}

- (void) viewWillDisappear: (BOOL) animated {
  StopObserving(connector, RequestFailedNotification);
}

- (void) requestFailed: (NSNotification *) notification {
  [self hideLoadingMessage];
  NSError *error = [notification.userInfo objectForKey: @"error"];
  NSString *message = error ? [error friendlyDescription] : @"Can't connect to the server.";
  [UIAlertView showAlertWithTitle: @"Error" content: message];
}

// implement in subclasses
- (NSInteger) tableView: (UITableView *) t numberOfRowsInSection: (NSInteger) s {
  return 0;
}

// implement in subclasses
- (UITableViewCell *) tableView: (UITableView *) t cellForRowAtIndexPath: (NSIndexPath *) p {AbstractMethod(return nil)}

@end

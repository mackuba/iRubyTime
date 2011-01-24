// -------------------------------------------------------
// BaseViewController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ApplicationDelegate.h"
#import "BaseViewController.h"
#import "LoadingView.h"
#import "LoginDialogController.h"
#import "ServerConnector.h"
#import "Utils.h"

@implementation BaseViewController

@synthesize connector;
PSReleaseOnDealloc(connector, loadingView);

- (id) initWithConnector: (ServerConnector *) rtConnector { PSAbstractMethod(id) }

- (id) initWithConnector: (ServerConnector *) rtConnector andStyle: (UITableViewStyle) style {
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
  tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

// override in subclasses and return YES if the controller needs to fetch data (activities) before it's displayed
- (BOOL) needsOwnData {
  return NO;
}

// override in subclasses if the controller needs to fetch data
- (void) fetchData {
}

- (void) fetchDataIfNeeded {
  id delegate = [[UIApplication sharedApplication] delegate];
  if (![delegate kernelPanic]) {
    if (![delegate initialDataIsLoaded]) {
      [self showLoadingMessage];
    } else if ([self needsOwnData]) {
      [self showLoadingMessage];
      [self fetchData];
    } else {
      [self initializeView];
    }
  }
}

- (void) initializeView {
  [tableView reloadData];
  [self hideLoadingMessage];
}

- (void) viewWillAppear: (BOOL) animated {
  PSStopObservingAll();
  PSObserve(connector, RequestFailedNotification, requestFailed:);
  [tableView reloadData];
  [self fetchDataIfNeeded];
}

- (void) viewWillDisappear: (BOOL) animated {
  PSStopObservingAll();
  [self hideLoadingMessage];
  id delegate = [[UIApplication sharedApplication] delegate];
  if ([delegate initialDataIsLoaded]) {
    [connector cancelAllRequests];
  }
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation {
  return (PSiPadDevice ? YES : (orientation == UIInterfaceOrientationPortrait));
}

- (void) requestFailed: (NSNotification *) notification {
  [self hideLoadingMessage];
  NSError *error = [[notification.userInfo objectForKey: @"request"] error];
  NSString *message = error ? [error friendlyDescription] : @"Can't connect to the server.";
  [UIAlertView psShowErrorWithMessage: message];
}

// implement in subclasses
- (NSInteger) tableView: (UITableView *) t numberOfRowsInSection: (NSInteger) s {
  return 0;
}

// implement in subclasses
- (UITableViewCell *) tableView: (UITableView *) t cellForRowAtIndexPath: (NSIndexPath *) p { PSAbstractMethod(id); }

@end

// -------------------------------------------------------
// BaseViewController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

#define STANDARD_CELL_HEIGHT 44

@class LoadingView;
@class ServerConnector;

@interface BaseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  LoadingView *loadingView;
  ServerConnector *connector;
  UITableView *tableView;
  UITableViewStyle tableStyle;
}

- (id) initWithConnector: (ServerConnector *) rtConnector;
- (id) initWithConnector: (ServerConnector *) rtConnector andStyle: (UITableViewStyle) style;
- (void) showLoadingMessage;
- (void) hideLoadingMessage;
- (BOOL) needsOwnData;
- (void) fetchData;
- (void) fetchDataIfNeeded;
- (void) initializeView;

@property (nonatomic, retain) ServerConnector *connector;

@end

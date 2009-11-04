// -------------------------------------------------------
// BaseViewController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

#define STANDARD_CELL_HEIGHT 44

@class LoadingView;
@class RubyTimeConnector;

@interface BaseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  LoadingView *loadingView;
  RubyTimeConnector *connector;
  UITableView *tableView;
  UITableViewStyle tableStyle;
}

- (id) initWithConnector: (RubyTimeConnector *) rtConnector;
- (id) initWithConnector: (RubyTimeConnector *) rtConnector andStyle: (UITableViewStyle) style;
- (void) showLoadingMessage;
- (void) hideLoadingMessage;
- (void) showPopupView: (UIViewController *) controllerClass;
- (void) hidePopupView;
- (BOOL) needsOwnData;
- (void) fetchData;
- (void) fetchDataIfNeeded;
- (void) initializeView;

@property (nonatomic, retain) RubyTimeConnector *connector;

@end

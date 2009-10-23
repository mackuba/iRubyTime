// -------------------------------------------------------
// BaseViewController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

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
- (void) showPopupView: (Class) controllerClass;
- (void) hidePopupView;
- (BOOL) needsOwnData;
- (void) fetchData;
- (void) initializeView;

@property (nonatomic, retain) RubyTimeConnector *connector;

@end

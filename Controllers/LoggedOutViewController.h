// -------------------------------------------------------
// LoggedOutViewController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class ServerConnector;

@interface LoggedOutViewController : UITableViewController {
  ServerConnector *connector;
}

@property (nonatomic, retain) IBOutlet UIView *footerView;

- (id) initWithConnector: (ServerConnector *) connector;
- (IBAction) loginClicked;

@end

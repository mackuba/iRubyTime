// -------------------------------------------------------
// ActivityDetailsController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

#import "Activity.h"
#import "ActivityType.h"
#import "BaseViewController.h"
#import "Project.h"
#import "ServerConnector.h"
#import "User.h"
#import "Utils.h"

typedef enum { DateRow, ProjectRow, ActivityTypeRow, UserRow, LengthRow, CommentsRow, DeleteButtonRow } RowType;

// ABSTRACT CLASS

@interface ActivityDetailsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  Activity *activity;
  NSMutableDictionary *subcontrollers;
  ServerConnector *connector;
  UIActivityIndicatorView *spinner;
  UIBarButtonItem *cancelButton;
  UIBarButtonItem *loadingButton;
  UIBarButtonItem *saveButton;
  UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) Activity *activity;

- (id) initWithConnector: (ServerConnector *) rtConnector nibName: (NSString *) nib;

- (void) setupToolbar;
- (NSString *) errorMessageFromJSON: (NSString *) jsonString;
- (NSString *) errorMessageFromError: (NSError *) error text: (NSString *) text request: (PSRequest *) request;
- (void) pushSubcontrollerForPath: (NSIndexPath *) path;
- (RowType) rowTypeAtIndexPath: (NSIndexPath *) path;
- (UITableViewCell *) cellForRowType: (RowType) rowType;
- (UIViewController *) subcontrollerForRowType: (RowType) rowType;

// ABSTRACT METHODS
- (void) executeSave;
- (PSIntArray *) rowTypesInSection: (NSInteger) section;

@end

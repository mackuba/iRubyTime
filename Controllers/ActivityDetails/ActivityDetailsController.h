// -------------------------------------------------------
// ActivityDetailsController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

#import "Activity.h"
#import "ActivityManager.h"
#import "Project.h"
#import "Request.h"
#import "RubyTimeConnector.h"
#import "User.h"
#import "Utils.h"
#import "NSDictionary+BSJSONAdditions.h"

#define COMMENTS_CELL_HEIGHT 92
#define STANDARD_CELL_HEIGHT 44

typedef enum { DateRow, ProjectRow, UserRow, LengthRow, CommentsRow, DeleteButtonRow } RowType;

// ABSTRACT CLASS

@interface ActivityDetailsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  Activity *activity;
  ActivityManager *activityManager;
  NSMutableDictionary *subcontrollers;
  RubyTimeConnector *connector;
  UIActivityIndicatorView *spinner;
  UIBarButtonItem *cancelButton;
  UIBarButtonItem *loadingButton;
  UIBarButtonItem *saveButton;
  UITableView *tableView;
  UITableViewCell *commentsCell;
  UILabel *commentsLabel;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *commentsCell;
@property (nonatomic, retain) IBOutlet UILabel *commentsLabel;

- (id) initWithConnector: (RubyTimeConnector *) rtConnector
                 nibName: (NSString *) nib
         activityManager: (ActivityManager *) manager;

- (void) setupToolbar;
- (NSString *) errorMessageFromJSON: (NSString *) jsonString;
- (NSString *) errorMessageFromError: (NSError *) error text: (NSString *) text request: (Request *) request;
- (void) pushSubcontrollerForPath: (NSIndexPath *) path;
- (RowType) rowTypeAtIndexPath: (NSIndexPath *) path;
- (UITableViewCell *) cellForRowType: (RowType) rowType;
- (UIViewController *) subcontrollerForRowType: (RowType) rowType;

// ABSTRACT METHODS
- (void) executeSave;
- (CGFloat) heightForRowOfType: (RowType) rowType;
- (IntArray *) rowTypesInSection: (NSInteger) section;

@end

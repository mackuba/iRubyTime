// -------------------------------------------------------
// ActivityListController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class ActivityCell;
@class ActivityManager;

@interface ActivityListController : BaseViewController {
  ActivityCell *currentCell;
  ActivityManager *manager;
  BOOL dataIsLoaded;
  BOOL hasMoreActivities;
  UIActivityIndicatorView *loadMoreSpinner;
  UITableViewCell *loadMoreCell;
  UILabel *loadMoreLabel;
  UIColor *loadMoreLabelColor;
  BOOL loadMoreRequestSent;
  NSInteger listOffset;
}

@property (nonatomic, assign) IBOutlet ActivityCell *currentCell;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadMoreSpinner;
@property (nonatomic, retain) IBOutlet UITableViewCell *loadMoreCell;
@property (nonatomic, retain) IBOutlet UILabel *loadMoreLabel;

- (BOOL) hasNewActivityButton;

@end

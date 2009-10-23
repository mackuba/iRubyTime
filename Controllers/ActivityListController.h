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
}

@property (nonatomic, assign) IBOutlet ActivityCell *currentCell;

@end

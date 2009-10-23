// -------------------------------------------------------
// ActivityListController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class ActivityCell;

@interface ActivityListController : BaseViewController {
  ActivityCell *currentCell;
}

@property (nonatomic, assign) IBOutlet ActivityCell *currentCell;

@end

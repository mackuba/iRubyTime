// -------------------------------------------------------
// SearchFormController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class Activity;
@class Project;
@class User;

@interface SearchFormController : BaseViewController {
  NSDate *startDate;
  NSDate *endDate;
  UITableViewCell *dateRangeCell;
  UILabel *startDateLabel;
  UILabel *endDateLabel;
  Project *project;
  User *user;
  NSMutableArray *subcontrollers;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *dateRangeCell;
@property (nonatomic, retain) IBOutlet UILabel *startDateLabel;
@property (nonatomic, retain) IBOutlet UILabel *endDateLabel;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;

@end

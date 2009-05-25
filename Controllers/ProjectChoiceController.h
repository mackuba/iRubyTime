// -------------------------------------------------------
// ProjectChoiceController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;

@interface ProjectChoiceController : UITableViewController {
  NSArray *projects;
  NSArray *recentProjects;
  Activity *activity;
}

- (id) initWithActivity: (Activity *) newActivity
            projectList: (NSArray *) projectList
         recentProjects: (NSArray *) recentProjects;

@end

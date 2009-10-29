// -------------------------------------------------------
// ProjectActivitiesController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>
#import "ActivityListController.h"

@class Project;

@interface ProjectActivitiesController : ActivityListController {
  Project *displayedProject;
}

- (id) initWithConnector: (RubyTimeConnector *) rtConnector project: (Project *) project;

@end

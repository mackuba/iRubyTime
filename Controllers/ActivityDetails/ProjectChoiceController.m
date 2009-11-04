// -------------------------------------------------------
// ProjectChoiceController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "Project.h"
#import "ProjectChoiceController.h"

@implementation ProjectChoiceController

- (id) initWithActivity: (Activity *) activity {
  return [super initWithModel: [Project class] delegate: activity allowNil: NO];
}

@end

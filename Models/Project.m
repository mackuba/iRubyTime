// -------------------------------------------------------
// Project.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Project.h"
#import "Utils.h"

@implementation Project

@synthesize hasActivities;
SynthesizeAndReleaseLater(name);

- (id) init {
  return [super initWithModelName: @"Project" properties: RTArray(@"name", @"hasActivities")];
}

+ (NSArray *) allWithActivities {
  return [[self list] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"hasActivities == TRUE"]];
}

@end

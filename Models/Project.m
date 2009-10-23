// -------------------------------------------------------
// Project.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Project.h"
#import "Utils.h"

@implementation Project

@synthesize projectId;
SynthesizeAndReleaseLater(name);

- (id) copyWithZone: (NSZone *) zone {
  Project *other = [[Project alloc] init];
  other.name = [self.name copy];
  other.projectId = self.projectId;
  return other;
}

- (BOOL) isEqual: (id) other {
  if ([other isMemberOfClass: [Project class]]) {
    Project *otherProject = (Project *) other;
    return otherProject.projectId == self.projectId && [otherProject.name isEqualToString: self.name];
  } else {
    return false;
  }
}

- (NSUInteger) hash {
  return projectId;
}

@end

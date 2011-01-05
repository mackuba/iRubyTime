// -------------------------------------------------------
// Project.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Project.h"
#import "ActivityType.h"
#import "Utils.h"

@implementation Project

@synthesize hasActivities, name, availableActivityTypes;
PSReleaseOnDealloc(name, availableActivityTypes);

+ (NSArray *) propertyList {
  return PSArray(@"name", @"hasActivities", @"availableActivityTypes");
}

+ (NSArray *) allWithActivities {
  return [[self list] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"hasActivities == TRUE"]];
}

- (void) setAvailableActivityTypes: (id) newAvailableActivityTypes {
  [availableActivityTypes release];
  availableActivityTypes = [[NSMutableArray alloc] init];
  for (id activityTypeHash in newAvailableActivityTypes) {
    if ([activityTypeHash class] == [ActivityType class]) {
      [availableActivityTypes addObject: activityTypeHash];
    } else {
      [availableActivityTypes addObject: [ActivityType objectFromJSON: activityTypeHash]];
    }
  }
}

- (ActivityType *) activityTypeWithId: (NSNumber *) aRecordId {
  NSInteger activityTypeId = [aRecordId integerValue];

  for (ActivityType *activityType in availableActivityTypes) {
    if ([activityType.recordId integerValue] == activityTypeId) {
      return activityType;
    }
    else {
      for (ActivityType *subactivityType in [activityType availableSubactivityTypes]) {
        if ([subactivityType.recordId integerValue] == activityTypeId) {
          return subactivityType;
        }
      }
    }
  }
  return nil;
}

- (BOOL) hasAvailableActivityTypes {
  return self.availableActivityTypes.count > 0;
}

@end

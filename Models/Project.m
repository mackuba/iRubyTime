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

PSModelProperties(name, availableActivityTypes, hasActivities);
PSReleaseOnDealloc(name, availableActivityTypes);

+ (NSArray *) allWithActivities {
  return [[self list] psFilterWithPredicate: @"hasActivities == TRUE"];
}

- (void) setAvailableActivityTypes: (id) types {
  [availableActivityTypes release];
  availableActivityTypes = [[ActivityType objectsFromJSON: types] retain];
}

- (ActivityType *) activityTypeWithId: (NSNumber *) aRecordId {
  NSInteger activityId = [aRecordId integerValue];

  for (ActivityType *activityType in availableActivityTypes) {
    if (activityType.recordIdValue == activityId) {
      return activityType;
    } else {
      for (ActivityType *subactivityType in [activityType availableSubactivityTypes]) {
        if (subactivityType.recordIdValue == activityId) {
          return subactivityType;
        }
      }
    }
  }

  return nil;
}

- (BOOL) hasAvailableActivityTypes {
  return availableActivityTypes.count > 0;
}

@end

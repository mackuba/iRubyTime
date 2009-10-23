// -------------------------------------------------------
// ActivityManager.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityManager.h"
#import "Utils.h"

@implementation ActivityManager

OnDeallocRelease(activityList);

- (id) init {
  if (self = [super init]) {
    activityList = [[NSMutableArray alloc] initWithCapacity: 20];
  }
  return self;
}

- (void) setActivities: (NSArray *) list {
  activityList = [list mutableCopy];
}

- (NSArray *) activities {
  return activityList;
}

- (void) addNewActivity: (Activity *) activity {
  NSInteger index;
  for (index = 0; index < activityList.count; index++) {
    Activity *existing = [activityList objectAtIndex: index];
    if ([activity.date laterDate: existing.date] == activity.date) break;
  }
  [activityList insertObject: activity atIndex: index];
}

- (void) updateActivity: (Activity *) activity {
  [self deleteActivity: activity];
  [self addNewActivity: activity];
}

- (void) deleteActivity: (Activity *) activity {
  NSInteger index;
  Activity *existing;
  for (index = 0; index < activityList.count; index++) {
    existing = [activityList objectAtIndex: index];
    if (existing.activityId == activity.activityId) break;
  }
  if (index < activityList.count) {
    [activityList removeObjectAtIndex: index];
  }
}

@end

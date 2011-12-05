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

@synthesize allDates, activities;
PSReleaseOnDealloc(allDates, activities, dateGroups);

- (id) init {
  if (self = [super init]) {
    activities = [[NSMutableArray alloc] initWithCapacity: 50];
    dateGroups = [NSDictionary dictionary];
    allDates = [[NSArray alloc] init];
  }
  return self;
}

- (void) recreateDateGroups {
  [dateGroups release];
  dateGroups = [[activities psGroupByKey: @"date"] retain];
  NSArray *unsortedDates = [dateGroups allKeys];
  [allDates release];
  allDates = [[[unsortedDates sortedArrayUsingSelector: @selector(compare:)] reverseObjectEnumerator] allObjects];
  [allDates retain];
}

- (NSArray *) activitiesOnDay: (NSDate *) date {
  return [dateGroups objectForKey: date];
}

- (void) appendActivities: (NSArray *) activityList {
  [activities addObjectsFromArray: activityList];
  [self recreateDateGroups];
}

- (void) addNewActivity: (Activity *) activity {
  NSInteger index;
  for (index = 0; index < activities.count; index++) {
    Activity *existing = [activities objectAtIndex: index];
    if ([activity.date laterDate: existing.date] == activity.date) break;
  }
  [activities insertObject: activity atIndex: index];
  [self recreateDateGroups];
}

- (void) updateActivity: (Activity *) activity {
  [self deleteActivity: activity];
  [self addNewActivity: activity];
  [self recreateDateGroups];
}

- (void) deleteActivity: (Activity *) activity {
  NSInteger index;
  Activity *existing;
  for (index = 0; index < activities.count; index++) {
    existing = [activities objectAtIndex: index];
    if ([existing.recordId isEqual: activity.recordId]) break;
  }
  if (index < activities.count) {
    [activities removeObjectAtIndex: index];
  }
  [self recreateDateGroups];
}

- (NSArray *) recentProjects {
  return [self valueForKeyPath: @"activities.@distinctUnionOfObjects.project"];
}

@end

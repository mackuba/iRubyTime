// -------------------------------------------------------
// DataManager.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "DataManager.h"
#import "Project.h"
#import "Utils.h"
#import "NSArray+BSJSONAdditions.h"

@implementation DataManager

@synthesize projects, delegate;
OnDeallocRelease(activityList, projects, projectHash);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithDelegate: (id) aDelegate {
  if (self = [super init]) {
    activityList = [[NSMutableArray alloc] initWithCapacity: 20];
    projects = [[NSMutableArray alloc] initWithCapacity: 20];
    projectHash = [[NSMutableDictionary alloc] initWithCapacity: 20];
    delegate = aDelegate;
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark Activities

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

- (Activity *) activityFromJSON: (NSDictionary *) json {
  Activity *activity = [[Activity alloc] init];
  activity.comments = [json objectForKey: @"comments"];
  activity.dateAsString = [json objectForKey: @"date"];
  activity.minutes = [[json objectForKey: @"minutes"] intValue];
  activity.activityId = [[json objectForKey: @"id"] intValue];
  activity.project = [projectHash objectForKey: [json objectForKey: @"project_id"]];
  return [activity autorelease];
}

- (Activity *) activityFromJSONString: (NSString *) jsonString {
  NSDictionary *record = [NSDictionary dictionaryWithJSONString: jsonString];
  return [self activityFromJSON: record];
}

- (NSArray *) activitiesFromJSONString: (NSString *) jsonString {
  NSArray *records = [NSArray arrayWithJSONString: jsonString];
  NSMutableArray *list = [NSMutableArray arrayWithCapacity: records.count];
  for (NSDictionary *record in records) {
    Activity *activity = [self activityFromJSON: record];
    [list addObject: activity];
  }
  return list;
}

// -------------------------------------------------------------------------------------------
#pragma mark Projects

- (void) setProjects: (NSArray *) projectList {
  if (projects != projectList) {
    [projects release];
    projects = [projectList retain];
    [projectHash removeAllObjects];
    for (Project *project in projects) {
      [projectHash setObject: project forKey: RTInt(project.projectId)];
    }
  }
}

- (Project *) projectFromJSON: (NSDictionary *) json {
  Project *project = [[Project alloc] init];
  project.name = [json objectForKey: @"name"];
  project.projectId = [[json objectForKey: @"id"] intValue];
  return [project autorelease];
}

- (NSArray *) projectsFromJSONString: (NSString *) jsonString {
  NSArray *records = [NSArray arrayWithJSONString: jsonString];
  NSMutableArray *list = [NSMutableArray arrayWithCapacity: records.count];
  for (NSDictionary *record in records) {
    Project *project = [self projectFromJSON: record];
    [list addObject: project];
  }
  return list;
}

@end

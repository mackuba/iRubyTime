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

@synthesize activities, projects, delegate;
OnDeallocRelease(activities, projects, projectHash);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithDelegate: (id) aDelegate {
  if (self = [super init]) {
    activities = [[NSMutableArray alloc] initWithCapacity: 20];
    projects = [[NSMutableArray alloc] initWithCapacity: 20];
    projectHash = [[NSMutableDictionary alloc] initWithCapacity: 20];
    delegate = aDelegate;
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark Activities

- (void) addNewActivity: (Activity *) activity {
  [activities insertObject: activity atIndex: 0];
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

// -------------------------------------------------------
// GlobalDataManager.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "GlobalDataManager.h"
#import "Project.h"
#import "User.h"
#import "Utils.h"
#import "NSArray+BSJSONAdditions.h"

@implementation DataManager

@synthesize projects, users;
OnDeallocRelease(projects, users, projectHash);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) init {
  if (self = [super init]) {
    projects = [[NSMutableArray alloc] initWithCapacity: 20];
    projectHash = [[NSMutableDictionary alloc] initWithCapacity: 20];
  }
  return self;
}

- (void) setProjects: (NSArray *) projectList {
  // set projects and initialize projectHash too
  if (projects != projectList) {
    [projects release];
    projects = [projectList retain];
    [projectHash removeAllObjects];
    for (Project *project in projects) {
      [projectHash setObject: project forKey: RTInt(project.projectId)];
    }
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark JSON conversions

- (NSArray *) objectsOfClass: (Class) klass fromJSONString: (NSString *) jsonString {
  NSArray *records = [NSArray arrayWithJSONString: jsonString];
  NSMutableArray *list = [NSMutableArray arrayWithCapacity: records.count];
  for (NSDictionary *record in records) {
    NSString *methodName = [[NSStringFromClass(klass) lowercaseString] stringByAppendingString: @"FromJSON:"];
    SEL method = NSSelectorFromString(methodName);
    id object = [self performSelector: method withObject: record];
    [list addObject: object];
  }
  return list;
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
  return [self objectsOfClass: [Activity class] fromJSONString: jsonString];
}

- (Project *) projectFromJSON: (NSDictionary *) json {
  Project *project = [[Project alloc] init];
  project.name = [json objectForKey: @"name"];
  project.projectId = [[json objectForKey: @"id"] intValue];
  return [project autorelease];
}

- (NSArray *) projectsFromJSONString: (NSString *) jsonString {
  return [self objectsOfClass: [Project class] fromJSONString: jsonString];
}

- (User *) userFromJSON: (NSDictionary *) json {
  User *user = [[User alloc] init];
  user.name = [json objectForKey: @"name"];
  user.userId = [[json objectForKey: @"id"] intValue];
  return [user autorelease];
}

- (NSArray *) usersFromJSONString: (NSString *) jsonString {
  return [self objectsOfClass: [User class] fromJSONString: jsonString];
}

- (void) addSelfToTopOfUsers: (User *) user {
  NSMutableArray *userList = [users mutableCopy];
  [userList removeObject: user];
  [userList insertObject: user atIndex: 0];
  self.users = [NSArray arrayWithArray: userList];
}

@end

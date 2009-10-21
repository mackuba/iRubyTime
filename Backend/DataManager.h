// -------------------------------------------------------
// DataManager.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Activity;
@class Project;

@interface DataManager : NSObject {
  NSMutableArray *activityList;
  NSArray *projects;
  NSMutableDictionary *projectHash;
}

@property (nonatomic, copy) NSArray *activities;
@property (nonatomic, retain) NSArray *projects;

- (void) addNewActivity: (Activity *) activity;
- (Activity *) activityFromJSON: (NSDictionary *) json;
- (Activity *) activityFromJSONString: (NSString *) jsonString;
- (NSArray *) activitiesFromJSONString: (NSString *) jsonString;
- (void) updateActivity: (Activity *) activity;
- (void) deleteActivity: (Activity *) activity;

- (Project *) projectFromJSON: (NSDictionary *) json;
- (NSArray *) projectsFromJSONString: (NSString *) jsonString;

@end

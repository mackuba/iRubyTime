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
  NSMutableArray *activities;
  NSMutableDictionary *activityHash;
  NSArray *projects;
  NSMutableDictionary *projectHash;
  __weak id delegate;
}

@property (nonatomic, readonly) NSArray *activities;
@property (nonatomic, retain) NSArray *projects;
@property (nonatomic, assign) id delegate;

- (id) initWithDelegate: (id) delegate;
// - (void) loadDataFromDisk;
- (void) addActivities: (NSArray *) newActivities;
- (void) addNewActivity: (Activity *) activity;
- (Activity *) activityFromJSON: (NSDictionary *) json;
- (NSArray *) activitiesFromJSONString: (NSString *) jsonString;
- (Project *) projectFromJSON: (NSDictionary *) json;
- (NSArray *) projectsFromJSONString: (NSString *) jsonString;

@end

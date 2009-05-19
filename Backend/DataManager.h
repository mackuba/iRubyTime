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
  NSArray *projects;
  NSMutableDictionary *projectHash;
  __weak id delegate;
}

@property (nonatomic, retain) NSArray *activities;
@property (nonatomic, retain) NSArray *projects;
@property (nonatomic, assign) id delegate;

- (id) initWithDelegate: (id) delegate;

- (void) addNewActivity: (Activity *) activity;
- (Activity *) activityFromJSON: (NSDictionary *) json;
- (Activity *) activityFromJSONString: (NSString *) jsonString;
- (NSArray *) activitiesFromJSONString: (NSString *) jsonString;

- (Project *) projectFromJSON: (NSDictionary *) json;
- (NSArray *) projectsFromJSONString: (NSString *) jsonString;

@end

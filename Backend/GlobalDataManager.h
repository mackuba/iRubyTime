// -------------------------------------------------------
// GlobalDataManager.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Activity;
@class Project;

@interface DataManager : NSObject {
  NSArray *projects;
  NSMutableDictionary *projectHash;
}

@property (nonatomic, retain) NSArray *projects;

- (Activity *) activityFromJSON: (NSDictionary *) json;
- (Activity *) activityFromJSONString: (NSString *) jsonString;
- (NSArray *) activitiesFromJSONString: (NSString *) jsonString;
- (Project *) projectFromJSON: (NSDictionary *) json;
- (NSArray *) projectsFromJSONString: (NSString *) jsonString;

@end

// -------------------------------------------------------
// GlobalDataManager.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Activity;
@class Project;
@class User;

@interface DataManager : NSObject {
  NSArray *projects;
  NSMutableDictionary *projectHash;
  NSArray *users;
}

@property (nonatomic, retain) NSArray *projects;
@property (nonatomic, retain) NSArray *users;

- (Activity *) activityFromJSON: (NSDictionary *) json;
- (Activity *) activityFromJSONString: (NSString *) jsonString;
- (NSArray *) activitiesFromJSONString: (NSString *) jsonString;
- (Project *) projectFromJSON: (NSDictionary *) json;
- (NSArray *) projectsFromJSONString: (NSString *) jsonString;
- (User *) userFromJSON: (NSDictionary *) json;
- (NSArray *) usersFromJSONString: (NSString *) jsonString;

@end

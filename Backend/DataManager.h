// -------------------------------------------------------
// DataManager.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Activity;

@interface DataManager : NSObject {
  NSMutableArray *activities;
  NSMutableDictionary *activityHash;
  __weak id delegate;
}

@property (nonatomic, readonly) NSArray *activities;
@property (nonatomic, assign) id delegate;

- (id) initWithDelegate: (id) delegate;
// - (void) loadDataFromDisk;
- (void) addActivities: (NSArray *) newActivities;
- (Activity *) activityFromJSON: (NSDictionary *) json;
- (NSArray *) activitiesFromJSONString: (NSString *) jsonString;

@end

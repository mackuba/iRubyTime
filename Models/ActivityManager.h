// -------------------------------------------------------
// ActivityManager.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Activity;

@interface ActivityManager : NSObject {
  NSMutableArray *activities;
  NSMutableDictionary *dateGroups;
  NSArray *allDates;
}

@property (nonatomic, readonly) NSArray *activities;
@property (nonatomic, readonly) NSArray *allDates;

- (void) addNewActivity: (Activity *) activity;
- (void) updateActivity: (Activity *) activity;
- (void) deleteActivity: (Activity *) activity;
- (NSArray *) recentProjects;
- (void) appendActivities: (NSArray *) activities;
- (NSArray *) activitiesOnDay: (NSDate *) date;

@end

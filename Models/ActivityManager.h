// -------------------------------------------------------
// ActivityManager.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Activity;

@interface ActivityManager : NSObject {
  NSMutableArray *activityList;
}

@property (nonatomic, copy) NSArray *activities;

- (void) addNewActivity: (Activity *) activity;
- (void) updateActivity: (Activity *) activity;
- (void) deleteActivity: (Activity *) activity;
- (NSArray *) recentProjects;

@end

// -------------------------------------------------------
// DataManager.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "DataManager.h"
#import "Utils.h"
#import "NSArray+BSJSONAdditions.h"

@implementation DataManager

@synthesize activities, delegate;
OnDeallocRelease(activities, activityHash);

// -------------------------------------------------------------------------------------------
#pragma mark Initialization

- (id) initWithDelegate: (id) aDelegate {
  if (self = [super init]) {
    activities = [[NSMutableArray alloc] initWithCapacity: 20];
    activityHash = [[NSMutableDictionary alloc] initWithCapacity: 20];
    delegate = aDelegate;
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark Activities

- (void) addActivities: (NSArray *) newActivities {
  NSMutableArray *newlyAdded = [[NSMutableArray alloc] initWithCapacity: newActivities.count];
  for (Activity *activity in [newActivities reverseObjectEnumerator]) {
    if (![activityHash objectForKey: RTInt(activity.activityId)]) {
      [newlyAdded insertObject: activity atIndex: 0];
      [activities insertObject: activity atIndex: 0];
      [activityHash setObject: activity forKey: RTInt(activity.activityId)];
    }
  }
  NotifyWithDataAs(delegate ? delegate : self, @"activitiesReceived", RTDict(newlyAdded, @"activities"));
}

- (Activity *) activityFromJSON: (NSDictionary *) json {
  Activity *activity = [[Activity alloc] init];
  activity.comments = [json objectForKey: @"comments"];
  activity.date = [json objectForKey: @"date"];
  activity.minutes = [[json objectForKey: @"minutes"] intValue];
  activity.activityId = [[json objectForKey: @"id"] intValue];
  return [activity autorelease];
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

@end

// -------------------------------------------------------
// Activity.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "Utils.h"
#import "NSArray+BSJSONAdditions.h"

@implementation Activity

@synthesize minutes;
SynthesizeAndReleaseLater(date, comments);

+ (NSArray *) activitiesFromJSONString: (NSString *) jsonString {
  NSArray *records = [NSArray arrayWithJSONString: jsonString];
  NSMutableArray *activities = [NSMutableArray arrayWithCapacity: records.count];
  for (NSDictionary *record in records) {
    Activity *activity = [[Activity alloc] initWithJSON: record];
    [activities addObject: activity];
    [activity release];
  }
  return activities;
}

- (id) initWithJSON: (NSDictionary *) json {
  if (self = [super init]) {
    self.comments = [json objectForKey: @"comments"];
    self.date = [json objectForKey: @"date"];
    self.minutes = [[json objectForKey: @"minutes"] intValue];
  }
  return self;
}

- (NSString *) hourString {
  return RTFormat(@"%d:%02d", minutes / 60, minutes % 60);
}

@end

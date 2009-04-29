// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

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

@end

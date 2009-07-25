// -------------------------------------------------------
// Activity.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityDateFormatter.h"
#import "Project.h"
#import "Utils.h"

@implementation Activity

@synthesize minutes, activityId;
SynthesizeAndReleaseLater(date, dateAsString, comments, project);

- (id) init {
  self = [super init];
  if (self) {
    self.comments = @"";
    self.date = [NSDate date];
  }
  return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
  [coder encodeObject: comments forKey: @"comments"];
  [coder encodeObject: date forKey: @"date"];
  [coder encodeInt: minutes forKey: @"minutes"];
  [coder encodeInt: activityId forKey: @"activityId"];
  [coder encodeObject: project forKey: @"project"];
}

- (id) initWithCoder: (NSCoder *) coder {
  self = [super init];
  self.comments = [coder decodeObjectForKey: @"comments"];
  self.date = [coder decodeObjectForKey: @"date"];
  minutes = [coder decodeIntForKey: @"minutes"];
  activityId = [coder decodeIntForKey: @"activityId"];
  self.project = [coder decodeObjectForKey: @"project"];
  return self;
}

- (id) copyWithZone: (NSZone *) zone {
  Activity *other = [[Activity alloc] init];
  other.comments = self.comments;
  other.date = self.date;
  other.minutes = self.minutes;
  other.activityId = self.activityId;
  other.project = self.project;
  return other;
}

- (NSString *) hourString {
  return RTFormat(@"%d:%02d", minutes / 60, minutes % 60);
}

- (void) setDate: (NSDate *) newDate {
  [date release];
  date = [newDate copy];

  [dateAsString release];
  dateAsString = [[[ActivityDateFormatter sharedFormatter] formatDate: date] retain];
}

- (void) setDateAsString: (NSString *) dateString {
  self.date = [[ActivityDateFormatter sharedFormatter] parseDate: dateString];
}

- (BOOL) isEqualToActivity: (Activity *) other {
  return other &&
    other.activityId == self.activityId &&
    other.minutes == self.minutes &&
    other.project == self.project &&
    [other.date isEqualToDate: self.date] &&
    [other.comments isEqualToString: self.comments];
}

- (NSString *) toQueryString {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-MM-dd";
  NSString *query = RTFormat(@"activity[date]=%@&activity[comments]=%@&activity[hours]=%@&activity[project_id]=%d",
    [formatter stringFromDate: date], self.comments, [self hourString], self.project.projectId);
  [formatter release];
  return [query stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

@end

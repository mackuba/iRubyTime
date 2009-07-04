// -------------------------------------------------------
// Activity.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
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

- (NSString *) hourString {
  return RTFormat(@"%d:%02d", minutes / 60, minutes % 60);
}

- (void) setDate: (NSDate *) newDate {
  [date release];
  date = [newDate copy];

  [dateAsString release];
  dateAsString = [[self userFriendlyDateDescription: date] retain];
}

- (void) setDateAsString: (NSString *) dateString {
  NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
  inputFormatter.dateFormat = @"yyyy-MM-dd";
  self.date = [inputFormatter dateFromString: dateString];
  [inputFormatter release];
}

- (NSString *) userFriendlyDateDescription: (NSDate *) aDate {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSUInteger dateUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  NSDateComponents *oneDayBack = [[NSDateComponents alloc] init];
  oneDayBack.day = -1;
  NSString *result;

  NSDate *today = [NSDate date];
  NSDate *yesterday = [calendar dateByAddingComponents: oneDayBack toDate: today options: 0];

  NSDateComponents *dateComponents = [calendar components: dateUnits fromDate: aDate];
  NSDateComponents *nowComponents = [calendar components: dateUnits fromDate: [NSDate date]];
  NSDateComponents *yesterdayComponents = [calendar components: dateUnits fromDate: yesterday];

  if ([dateComponents isEqual: nowComponents]) {
    result = @"Today";
  } else if ([dateComponents isEqual: yesterdayComponents]) {
    result = @"Yesterday";
  } else if ([dateComponents year] != [nowComponents year]) {
    formatter.dateFormat = @"E d MMM yyyy";
    result = [formatter stringFromDate: aDate];
  } else {
    formatter.dateFormat = @"E d MMM";
    result = [formatter stringFromDate: aDate];
  }
  
  [formatter release];
  [oneDayBack release];
  return result;
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

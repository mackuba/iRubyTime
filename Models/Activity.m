// -------------------------------------------------------
// Activity.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "ActivityDateFormatter.h"
#import "Project.h"
#import "User.h"
#import "Utils.h"

@implementation Activity

@synthesize minutes;
SynthesizeAndReleaseLater(date, dateAsString, comments, project, user);

- (id) init {
  self = [super initWithModelName: @"Activity"
                       properties: RTArray(@"comments", @"date", @"minutes", @"project", @"user")];
  if (self) {
    self.comments = @"";
    self.date = [NSDate date];
  }
  return self;
}

- (NSString *) hourString {
  return RTFormat(@"%d:%02d", minutes / 60, minutes % 60);
}

- (void) setDate: (id) newDate {
  if ([newDate isKindOfClass: [NSString class]]) {
    [self setDateAsString: newDate];
  } else {
    [self setDateAsDate: newDate];
  }
}

- (void) setDateAsDate: (NSDate *) newDate {
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
    other.recordId == self.recordId &&
    other.minutes == self.minutes &&
    other.project == self.project &&
    [other.date isEqualToDate: self.date] &&
    [other.comments isEqualToString: self.comments];
}

- (NSString *) toQueryString {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-MM-dd";
  NSString *query = RTFormat(@"activity[date]=%@&activity[comments]=%@&activity[hours]=%@&activity[project_id]=%d",
    [formatter stringFromDate: date],
    [self.comments stringWithPercentEscapesForFormValues],
    [self hourString],
    self.project.recordId);
  [formatter release];
  return query;
}

@end

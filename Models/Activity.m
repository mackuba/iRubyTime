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

@synthesize minutes, locked, date, dateAsString, comments, project, user;
PSReleaseOnDealloc(date, dateAsString, comments, project, user);

+ (NSArray *) propertyList {
  return PSArray(@"comments", @"date", @"minutes", @"project", @"user", @"locked");
}

- (id) init {
  self = [super init];
  if (self) {
    self.comments = @"";
    self.date = [NSDate date];
  }
  return self;
}

- (NSString *) hourString {
  return PSFormat(@"%d:%02d", minutes / 60, minutes % 60);
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
  dateAsString = [[[ActivityDateFormatter sharedFormatter] formatDate: date withAliases: YES] retain];
}

- (void) setDateAsString: (NSString *) dateString {
  self.date = [[ActivityDateFormatter sharedFormatter] parseDate: dateString];
}

- (BOOL) isEqualToActivity: (Activity *) other {
  return other &&
    other.minutes == self.minutes &&
    other.project == self.project &&
    [other.recordId isEqual: self.recordId] &&
    [other.date isEqualToDate: self.date] &&
    [other.comments isEqualToString: self.comments];
}

- (NSString *) toQueryString {
  NSString *query = PSFormat(@"activity[date]=%@&activity[comments]=%@&activity[hours]=%@&activity[project_id]=%@",
    [[ActivityDateFormatter sharedFormatter] formatDateForRequest: date],
    [self.comments psStringWithPercentEscapesForFormValues],
    [self hourString],
    self.project.recordId);
  return query;
}

@end

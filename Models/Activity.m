// -------------------------------------------------------
// Activity.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ApplicationDelegate.h"
#import "ServerConnector.h"
#import "Activity.h"
#import "ActivityDateFormatter.h"
#import "Project.h"
#import "ActivityType.h"
#import "User.h"
#import "Utils.h"

@implementation Activity

@synthesize minutes, locked, date, dateAsString, comments, activityType, project, user;
PSReleaseOnDealloc(date, dateAsString, comments, project, user, activityType);

+ (NSArray *) propertyList {
  return PSArray(@"comments", @"date", @"minutes", @"project", @"user", @"locked", @"activityType");
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

- (void) setActivityType: (id) objectId {
  [activityType autorelease];
  [activityTypeId autorelease];
  if (!objectId) {
    activityTypeId = nil;
    activityType = nil;
  } else if ([objectId isKindOfClass: [NSNumber class]]) {
    activityTypeId = [objectId copy];
  } else {
    activityType = [objectId retain];
  }
}

- (ActivityType *) activityType {
  if (!activityType) {
    activityType = [project activityTypeWithId: activityTypeId];
  }
  return activityType;
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
  NSString *query = PSFormat(@"activity[date]=%@&activity[comments]=%@&activity[hours]=%@&activity[project_id]=%@&activity[%@]=%@",
    [[ActivityDateFormatter sharedFormatter] formatDateForRequest: date],
    [self.comments psStringWithPercentEscapesForFormValues],
    [self hourString],
    self.project.recordId,
    self.activityType.isSubtype ? @"sub_activity_type_id" : @"main_activity_type_id",
    self.activityType ? [self.activityType.recordId description] : @"");
  return query;
}

@end

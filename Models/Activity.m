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

@synthesize dateAsString;
PSModelProperties(date, comments, project, user, activityType, minutes, locked);
PSReleaseOnDealloc(date, comments, project, user, activityType, dateAsString);

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

- (NSString *) encodeToPostData {
  NSString *activityTypeField = self.activityType.isSubtype ? @"sub_activity_type_id" : @"main_activity_type_id";
  NSString *activityTypeValue = self.activityType ? [self.activityType.recordId description] : @"";

  NSDictionary *fields = PSHash(
    @"date",           [[ActivityDateFormatter sharedFormatter] formatDateForRequest: date],
    @"comments",       [self.comments psStringWithPercentEscapesForFormValues],
    @"hours",          [self hourString],
    @"project_id",     self.project.recordId,
    activityTypeField, activityTypeValue
  );

  return [NSString psStringWithFormEncodedFields: fields ofModelNamed: @"activity"];
}

@end

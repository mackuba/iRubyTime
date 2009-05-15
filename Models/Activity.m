// -------------------------------------------------------
// Activity.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Activity.h"
#import "Utils.h"

@implementation Activity

@synthesize minutes, activityId;
SynthesizeAndReleaseLater(date, dateAsString, comments, project);

- (id) init {
  self = [super init];
  if (self) {
    self.comments = @"";
  }
  return self;
}

- (NSString *) hourString {
  return RTFormat(@"%d:%02d", minutes / 60, minutes % 60);
}

- (void) setDate: (NSDate *) newDate {
  [date release];
  date = [newDate copy];

  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  outputFormatter.dateFormat = @"E d MMM";
  // TODO: show "today" or "yesterday"
  [dateAsString release];
  dateAsString = [[outputFormatter stringFromDate: date] retain];
  [outputFormatter release];
}

- (void) setDateAsString: (NSString *) dateString {
  NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
  inputFormatter.dateFormat = @"yyyy-MM-dd";
  self.date = [inputFormatter dateFromString: dateString];
  [inputFormatter release];
}

- (BOOL) isEqualToActivity: (Activity *) other {
  return other &&
    other.activityId == self.activityId &&
    other.minutes == self.minutes &&
    other.project == self.project &&
    [other.date isEqualToDate: self.date] &&
    [other.comments isEqualToString: self.comments];
}

@end

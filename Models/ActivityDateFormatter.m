// -------------------------------------------------------
// ActivityDateFormatter.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityDateFormatter.h"
#import "Utils.h"

static ActivityDateFormatter *sharedFormatter = nil;

@implementation ActivityDateFormatter

OnDeallocRelease(calendar, dateComponentsForToday, dateComponentsForYesterday,
  fullDateFormatter, dayAndMonthFormatter, inputFormatter);

- (id) init {
  self = [super init];
  if (self) {
    calendar = [[NSCalendar currentCalendar] retain];
    dateUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;

    fullDateFormatter = [[NSDateFormatter alloc] init];
    fullDateFormatter.dateFormat = @"E d MMM yyyy";
    dayAndMonthFormatter = [[NSDateFormatter alloc] init];
    dayAndMonthFormatter.dateFormat = @"E d MMM";
    inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.dateFormat = @"yyyy-MM-dd";

    NSDateComponents *oneDayBack = [[NSDateComponents alloc] init];
    oneDayBack.day = -1;
    NSDate *today = [NSDate date];
    NSDate *yesterday = [calendar dateByAddingComponents: oneDayBack toDate: today options: 0];
    [oneDayBack release];

    dateComponentsForToday = [[calendar components: dateUnits fromDate: today] retain];
    dateComponentsForYesterday = [[calendar components: dateUnits fromDate: yesterday] retain];
  }
  return self;
}

- (NSString *) formatDate: (NSDate *) date {
  NSDateComponents *dateComponents = [calendar components: dateUnits fromDate: date];
  if ([dateComponents isEqual: dateComponentsForToday]) {
    return @"Today";
  } else if ([dateComponents isEqual: dateComponentsForYesterday]) {
    return @"Yesterday";
  } else if ([dateComponents year] == [dateComponentsForToday year]) {
    return [dayAndMonthFormatter stringFromDate: date];
  } else {
    return [fullDateFormatter stringFromDate: date];
  }
}

- (NSDate *) parseDate: (NSString *) dateString {
  return [inputFormatter dateFromString: dateString];
}

+ (ActivityDateFormatter *) sharedFormatter {
  if (!sharedFormatter) {
    sharedFormatter = [[ActivityDateFormatter alloc] init];
  }
  return sharedFormatter;
}

@end

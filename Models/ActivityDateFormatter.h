// -------------------------------------------------------
// ActivityDateFormatter.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface ActivityDateFormatter : NSObject {
  NSCalendar *calendar;
  NSUInteger dateUnits;
  NSDateComponents *dateComponentsForToday;
  NSDateComponents *dateComponentsForYesterday;
  NSDateFormatter *fullDateFormatter;
  NSDateFormatter *dayAndMonthFormatter;
  NSDateFormatter *inputFormatter;
}

+ (ActivityDateFormatter *) sharedFormatter;
- (NSString *) formatDate: (NSDate *) date;
- (NSDate *) parseDate: (NSString *) dateString;

@end

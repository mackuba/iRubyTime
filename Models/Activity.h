// -------------------------------------------------------
// Activity.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Model.h"

@class Project;

@interface Activity : Model {
  NSString *comments;
  NSDate *date;
  NSString *dateAsString;
  NSInteger minutes;
  Project *project;
}

@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *dateAsString;
@property (nonatomic) NSInteger minutes;
@property (nonatomic, retain) Project *project;

- (NSString *) hourString;
- (BOOL) isEqualToActivity: (Activity *) other;
- (NSString *) toQueryString;
- (void) setDateAsDate: (NSDate *) newDate;

@end

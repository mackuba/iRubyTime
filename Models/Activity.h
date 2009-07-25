// -------------------------------------------------------
// Activity.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Project;

@interface Activity : NSObject <NSCoding> {
  NSString *comments;
  NSDate *date;
  NSString *dateAsString;
  NSInteger minutes;
  NSInteger activityId;
  Project *project;
}

@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *dateAsString;
@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSInteger activityId;
@property (nonatomic, retain) Project *project;

- (NSString *) hourString;
- (BOOL) isEqualToActivity: (Activity *) other;
- (NSString *) toQueryString;

@end

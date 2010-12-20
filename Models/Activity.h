// -------------------------------------------------------
// Activity.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

@class Project;
@class User;
@class ActivityType;

@interface Activity : PSModel {
  NSString *comments;
	ActivityType *activityType;
  NSNumber *activityTypeId;
  NSDate *date;
  NSString *dateAsString;
  NSInteger minutes;
  BOOL locked;
  Project *project;
  User *user;
}

@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) ActivityType *activityType;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *dateAsString;
@property (nonatomic) NSInteger minutes;
@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) User *user;
@property (nonatomic, getter = isLocked) BOOL locked;

- (NSString *) hourString;
- (BOOL) isEqualToActivity: (Activity *) other;
- (NSString *) toQueryString;
- (void) setDateAsDate: (NSDate *) newDate;

@end

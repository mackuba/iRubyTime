// -------------------------------------------------------
// Activity.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

@class Project;
@class User;
@class ActivityType;

@interface Activity : PSModel {}

@property (nonatomic, copy) NSString *comments;
@property (nonatomic, retain) ActivityType *activityType;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *dateAsString;
@property (nonatomic) NSInteger minutes;
@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) User *user;
@property (nonatomic, getter = isLocked) BOOL locked;

- (NSString *) hourString;
- (BOOL) isEqualToActivity: (Activity *) other;
- (void) setDateAsDate: (NSDate *) newDate;

@end

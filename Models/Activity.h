// -------------------------------------------------------
// Activity.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Project;

@interface Activity : NSObject {
  NSString *comments;
  NSString *date;
  NSInteger minutes;
  NSInteger activityId;
  Project *project;
}

@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSString *date;
@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSInteger activityId;
@property (nonatomic, retain) Project *project;

- (NSString *) hourString;
- (BOOL) isEqualToActivity: (Activity *) other;

@end

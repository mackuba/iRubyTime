// -------------------------------------------------------
// Activity.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface Activity : NSObject {
  NSString *comments;
  NSString *date;
  NSInteger minutes;
  NSInteger activityId;
}

@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSString *date;
@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSInteger activityId;

- (NSString *) hourString;
- (BOOL) isEqualToActivity: (Activity *) other;

@end

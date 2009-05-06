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
SynthesizeAndReleaseLater(date, comments, project);

- (NSString *) hourString {
  return RTFormat(@"%d:%02d", minutes / 60, minutes % 60);
}

- (BOOL) isEqualToActivity: (Activity *) other {
  return other &&
    other.activityId == self.activityId &&
    other.minutes == self.minutes &&
    other.project == self.project &&
    [other.date isEqualToString: self.date] &&
    [other.comments isEqualToString: self.comments];
}

@end

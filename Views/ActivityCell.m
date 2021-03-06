// -------------------------------------------------------
// ActivityCell.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityCell.h"
#import "Activity.h"
#import "Project.h"
#import "ActivityType.h"
#import "User.h"
#import "Utils.h"

@implementation ActivityCell

@synthesize dateLabel, hoursLabel, commentsLabel, projectLabel, activityTypeLabel, userLabel;
PSReleaseOnDealloc(dateLabel, hoursLabel, commentsLabel, projectLabel, activityTypeLabel, userLabel);

- (void) displayActivity: (Activity *) activity {
  self.commentsLabel.text = activity.comments;
  self.dateLabel.text = activity.dateAsString;
  self.projectLabel.text = activity.project.name;
  self.activityTypeLabel.text = activity.activityType.name;
  self.userLabel.text = activity.user.name;
  self.hoursLabel.text = [activity hourString];
}

@end

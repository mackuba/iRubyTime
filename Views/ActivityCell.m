// -------------------------------------------------------
// ActivityListConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityCell.h"
#import "Activity.h"
#import "Project.h"
#import "Utils.h"

@implementation ActivityCell

SynthesizeAndReleaseLater(dateLabel, hoursLabel, commentsLabel, projectLabel);

- (void) displayActivity: (Activity *) activity {
  self.commentsLabel.text = activity.comments;
  self.dateLabel.text = activity.date;
  self.projectLabel.text = activity.project.name;
  self.hoursLabel.text = [activity hourString];
}

@end
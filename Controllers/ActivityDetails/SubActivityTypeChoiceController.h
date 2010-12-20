//
//  SubActivityTypeChoiceController.h
//  RubyTime
//
//  Created by Ania on 12/17/10.
//  Copyright 2010 (c). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordChoiceController.h"

@class Activity, ActivityType, ActivityTypeChoiceController;

@interface SubActivityTypeChoiceController : RecordChoiceController {
  ActivityType *activityType;
  ActivityTypeChoiceController *parent;
}

- (id) initWithActivity: (Activity *) newActivity activityType: (ActivityType *) newActivityType parent: (ActivityTypeChoiceController *) newParent;

@end

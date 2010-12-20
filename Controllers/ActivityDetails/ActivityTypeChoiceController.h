//
//  ActivityTypeChoiceController.h
//  RubyTime
//
//  Created by Anna Lesniak on 12/3/10.
//  Copyright 2010 (c). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordChoiceController.h"

@class Activity, ActivityDetailsController;

@interface ActivityTypeChoiceController : RecordChoiceController {
  UIViewController *parent;
}

@property (nonatomic, readonly) UIViewController *parent;

- (id) initWithActivity: (Activity *) activity parent: (UIViewController *) newParent;

@end

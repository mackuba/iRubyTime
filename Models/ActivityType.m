//
//  ActivityType.m
//  RubyTime
//
//  Created by Anna Lesniak on 12/3/10.
//  Copyright 2010 (c). All rights reserved.
//

#import "ActivityType.h"
#import "Project.h"

@implementation ActivityType

@synthesize isSubtype;
PSModelProperties(name, availableSubactivityTypes, position);
PSReleaseOnDealloc(name, availableSubactivityTypes);

+ (id) objectWithId: (NSNumber *) objectId context: (id) context {
  NSNumber *projectId = [context objectForKey: @"project_id"];
  Project *project = [Project objectWithId: projectId];
  return [project activityTypeWithId: objectId];
}

+ (id) subActivityTypeFromJSON: (NSDictionary *) json {
  ActivityType *subtype = [ActivityType objectFromJSON: json];
  subtype.isSubtype = YES;
  return subtype;
}

- (id) init {
  self = [super init];
  if (self) {
    isSubtype = NO;
  }
  return self;
}

- (void) setAvailableSubactivityTypes: (id) types {
  [availableSubactivityTypes release];
  availableSubactivityTypes = [ActivityType psArrayByCalling: @selector(subActivityTypeFromJSON:)
                                             withObjectsFrom: types];
  [availableSubactivityTypes retain];
}

- (BOOL) hasAvailableSubactivityTypes {
  return availableSubactivityTypes.count > 0;
}

@end

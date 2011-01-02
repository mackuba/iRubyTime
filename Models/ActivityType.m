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

@synthesize name, position, availableSubactivityTypes, isSubtype;
PSReleaseOnDealloc(name, availableSubactivityTypes);

+ (NSArray *) propertyList {
  return PSArray(@"name", @"position", @"availableSubactivityTypes");
}

+ (id) objectWithId: (NSNumber *) objectId context: (id) context {
  NSNumber *projectId = [context objectForKey: @"project_id"];
  Project *project = [Project objectWithId: projectId];
  return [project activityTypeWithId: objectId];
}

- (id) init {
  self = [super init];
  if (self) {
    isSubtype = NO;
  }
  return self;
}

- (void) setAvailableSubactivityTypes: (id) newAvailableSubactivityTypes {
  [availableSubactivityTypes release];
  availableSubactivityTypes = [[NSMutableArray alloc] initWithCapacity: [newAvailableSubactivityTypes count]];
  for (id subactivityTypeHash in newAvailableSubactivityTypes) {
    ActivityType *type = [ActivityType objectFromJSON: subactivityTypeHash];
    type.isSubtype = YES;
    [availableSubactivityTypes addObject: type];
  }
}

- (BOOL) hasAvailableSubactivityTypes {
  return availableSubactivityTypes.count > 0;
}

- (NSString *) description {
  return PSFormat(@"%@ %@", name, availableSubactivityTypes);
}

@end

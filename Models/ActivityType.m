//
//  ActivityType.m
//  RubyTime
//
//  Created by Anna Lesniak on 12/3/10.
//  Copyright 2010 (c). All rights reserved.
//

#import "ActivityType.h"


@implementation ActivityType

@synthesize name, position, availableSubactivityTypes, isSubtype;
PSReleaseOnDealloc(name, availableSubactivityTypes);

+ (NSArray *) propertyList {
  return PSArray(@"name", @"position", @"availableSubactivityTypes");
}

+ (id) objectWithId: (NSNumber *) objectId {
  return objectId;
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
  availableSubactivityTypes = [[NSMutableArray alloc] init];
  for (id subactivityTypeHash in newAvailableSubactivityTypes) {
    ActivityType *type = [ActivityType objectFromJSON: subactivityTypeHash];
    type.isSubtype = YES;
    [availableSubactivityTypes addObject: type];
  }
}

- (BOOL) hasAvailableSubactivityTypes {
  return [self.availableSubactivityTypes count] > 0;
}

- (NSString *) description {
  return PSFormat(@"%@ %@", name, availableSubactivityTypes);
}

@end
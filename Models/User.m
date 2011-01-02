// -------------------------------------------------------
// User.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "User.h"
#import "Utils.h"

@implementation User

@synthesize name;
PSReleaseOnDealloc(name);

+ (NSArray *) propertyList {
  return PSArray(@"name");
}

- (void) addSelfToTopOfUsers {
  [self removeObjectFromList];
  [[self class] prependObjectsToList: PSArray(self)];
}

@end

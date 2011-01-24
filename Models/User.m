// -------------------------------------------------------
// User.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "User.h"
#import "Utils.h"

@implementation User

PSModelProperties(name);
PSReleaseOnDealloc(name);

- (void) addSelfToTopOfUsers {
  [self removeObjectFromList];
  [[self class] prependObjectsToList: PSArray(self)];
}

@end

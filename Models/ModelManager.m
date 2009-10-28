// -------------------------------------------------------
// ModelManager.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ModelManager.h"

@implementation ModelManager

@synthesize list, identityMap;

- (id) init {
  self = [super init];
  if (self) {
    list = [[NSMutableArray alloc] initWithCapacity: 100];
    identityMap = [[NSMutableDictionary alloc] initWithCapacity: 100];
  }
  return self;
}

+ (ModelManager *) managerForClass: (NSString *) className {
  static NSMutableDictionary *managers;
  if (!managers) {
    managers = [[NSMutableDictionary alloc] initWithCapacity: 5];
  }
  ModelManager *manager = [managers objectForKey: className];
  if (!manager) {
    manager = [[ModelManager alloc] init];
    [managers setObject: manager forKey: className];
  }
  return manager;
}

@end

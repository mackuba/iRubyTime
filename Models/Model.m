// -------------------------------------------------------
// Model.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Model.h"
#import "ModelManager.h"
#import "Utils.h"
#import "NSArray+BSJSONAdditions.h"

@implementation Model

@synthesize recordId;
SynthesizeAndReleaseLater(properties, modelName);

// -------------------------------------------------------------------------------------------
#pragma mark Creating from JSON

+ (id) objectFromJSON: (NSDictionary *) json {
  // create a blank object
  id object = [[self alloc] init];

  // set all properties
  for (NSString *property in [object properties]) {
    // 'id' from json will be stored as 'recordId'
    NSString *key = ([property isEqual: RECORD_ID] ? @"id" : property);
    id value = [json objectForKey: key];

    // if we have a property 'prop', but there's 'prop_id' in json, it means it's a belongs_to relation
    id relationValue = [json objectForKey: RTFormat(@"%@_id", property)];
    if (!value && relationValue) {
      // then find the object in the other model
      Class targetClass = NSClassFromString([property capitalizedString]);
      NSInteger objectId = [relationValue intValue];
      value = [targetClass objectWithId: objectId];
    }

    [object setValue: value forKey: property];
  }

  return [object autorelease];
}

+ (id) objectFromJSONString: (NSString *) jsonString {
  NSDictionary *record = [NSDictionary dictionaryWithJSONString: jsonString];
  return [self objectFromJSON: record];
}

+ (NSArray *) objectsFromJSONString: (NSString *) jsonString {
  NSArray *records = [NSArray arrayWithJSONString: jsonString];
  NSMutableArray *objects = [NSMutableArray arrayWithCapacity: records.count];
  for (NSDictionary *record in records) {
    [objects addObject: [self objectFromJSON: record]];
  }
  return objects;
}

// -------------------------------------------------------------------------------------------
#pragma mark Reading and updating global object list and map

+ (ModelManager *) modelManager {
  return [ModelManager managerForClass: NSStringFromClass([self class])];
}

+ (id) objectWithId: (NSInteger) objectId {
  return [[self identityMap] objectForKey: RTInt(objectId)];
}

+ (void) appendObjectsToList: (NSArray *) objects {
  [[self list] addObjectsFromArray: objects];
  NSMutableDictionary *identityMap = [self identityMap];
  for (id object in objects) {
    [identityMap setObject: object forKey: [object valueForKey: RECORD_ID]];
  }
}

+ (NSInteger) count {
  return [[self list] count];
}

+ (NSMutableArray *) list {
  return [[self modelManager] list];
}

+ (NSMutableDictionary *) identityMap {
  return [[self modelManager] identityMap];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (id) initWithModelName: (NSString *) name properties: (NSArray *) propertyList {
  self = [super init];
  if (self) {
    modelName = [name copy];
    properties = [[propertyList arrayByAddingObject: RECORD_ID] retain];
  }
  return self;
}

- (id) copyWithZone: (NSZone *) zone {
  id other = [[[self class] alloc] init];
  for (NSString *property in properties) {
    id value = [self valueForKey: property];
    [other setValue: value forKey: property];
  }
  return other;
}

- (BOOL) isEqual: (id) other {
  if ([other isKindOfClass: [self class]]) {
    id otherRecordId = [other valueForKey: RECORD_ID];
    id myRecordId = [self valueForKey: RECORD_ID];
    return [otherRecordId isEqual: myRecordId];
  } else {
    return false;
  }
}

- (NSUInteger) hash {
  return recordId;
}

@end

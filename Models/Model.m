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
  Model *object = [[self alloc] init];
  NSArray *properties = [object properties];

  // set all properties
  for (NSString *key in [json allKeys]) {
    id value = nil;
    NSString *property;

    if ([key hasSuffix: @"_id"]) {
      // for names ending with _id, find an associated object in another Model
      property = [key substringToIndex: key.length - 3];
      id associationId = [json objectForKey: key];
      Class targetClass = NSClassFromString([property capitalizedString]);
      if (associationId != [NSNull null] && [targetClass respondsToSelector: @selector(objectWithId:)]) {
        value = [targetClass objectWithId: [associationId intValue]];
      }
    } else {
      // for other names, assign the value as is to a correct property
      value = [json objectForKey: key];

      if ([key isEqual: @"id"]) {
        // 'id' is saved as 'record_id'
        property = RECORD_ID;
      } else if ([key hasSuffix: @"?"]) {
        // 'foo?' is saved as 'foo'
        property = [key substringToIndex: key.length - 1];
      } else {
        // normal property
        property = key;
      }
    }

    if (value != nil && [properties containsObject: property]) {
      [object setValue: value forKey: property];
    }
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

// -------------------------------------------------------
// Model.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

#define RECORD_ID @"recordId"

@interface Model : NSObject <NSCopying> {
  NSInteger recordId;
  NSArray *properties;
  NSString *modelName;
}

@property (nonatomic) NSInteger recordId;
@property (nonatomic, readonly) NSArray *properties;
@property (nonatomic, readonly) NSString *modelName;

+ (id) objectFromJSON: (NSDictionary *) json;
+ (id) objectFromJSONString: (NSString *) jsonString;
+ (NSArray *) objectsFromJSONString: (NSString *) jsonString;

+ (void) appendObjectsToList: (NSArray *) objects;
+ (id) objectWithId: (NSInteger) objectId;
+ (NSInteger) count;
+ (NSMutableArray *) list;
+ (NSMutableDictionary *) identityMap;
+ (void) reset;

- (id) initWithModelName: (NSString *) name properties: (NSArray *) propertyList;
- (BOOL) isEqual: (id) other;

@end

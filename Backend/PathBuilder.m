// -------------------------------------------------------
// PathBuilder.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Model.h"
#import "PathBuilder.h"
#import "Utils.h"

@interface PathBuilder ()
- (id) initWithBasePath: (NSString *) path;
@end

@implementation PathBuilder

+ (PathBuilder *) builderWithBasePath: (NSString *) path record: (Model *) record {
  NSString *basePath = RTFormat(path, record.recordId);
  PathBuilder *builder = [[PathBuilder alloc] initWithBasePath: basePath];
  return [builder autorelease];
}

+ (PathBuilder *) builderWithBasePath: (NSString *) path {
  PathBuilder *builder = [[PathBuilder alloc] initWithBasePath: path];
  return [builder autorelease];
}

- (id) initWithBasePath: (NSString *) path {
  self = [super init];
  if (self) {
    fullPath = [[NSMutableString alloc] initWithString: path];
    hasParams = NO;
  }
  return self;
}

- (void) setObject: (id) value forKey: (NSString *) key {
  [fullPath appendString: (hasParams ? @"&" : @"?")];
  [fullPath appendString: RTFormat(@"search_criteria[%@]=%@", key, [value description])];
  hasParams = YES;
}

- (void) setInt: (NSInteger) number forKey: (NSString *) key {
  [self setObject: RTInt(number) forKey: key];
}

- (NSString *) path {
  return fullPath;
}

@end

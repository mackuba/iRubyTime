// -------------------------------------------------------
// PathBuilder.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface PathBuilder : NSObject {
  NSMutableString *fullPath;
  BOOL hasParams;
}

@property (nonatomic, readonly) NSString *path;

+ (PathBuilder *) builderWithBasePath: (NSString *) path record: (PSModel *) record;
+ (PathBuilder *) builderWithBasePath: (NSString *) path;
- (void) setObject: (id) value forKey: (NSString *) key;
- (void) setInt: (NSInteger) number forKey: (NSString *) key;

@end

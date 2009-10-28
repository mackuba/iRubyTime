// -------------------------------------------------------
// ModelManager.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface ModelManager : NSObject {
  NSMutableArray *list;
  NSMutableDictionary *identityMap;
}

@property (nonatomic, readonly) NSMutableArray *list;
@property (nonatomic, readonly) NSMutableDictionary *identityMap;

+ (ModelManager *) managerForClass: (NSString *) className;

@end

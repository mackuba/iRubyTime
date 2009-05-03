// -------------------------------------------------------
// Activity.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface Activity : NSObject {
  NSString *comments;
  NSString *date;
  NSInteger minutes;
}

@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSString *date;
@property (nonatomic) NSInteger minutes;

+ (NSArray *) activitiesFromJSONString: (NSString *) jsonString;
- (id) initWithJSON: (NSDictionary *) json;
- (NSString *) hourString;

@end

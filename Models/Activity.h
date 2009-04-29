// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

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

@end

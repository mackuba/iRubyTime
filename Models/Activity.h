//
//  Activity.h
//  RubyTime
//
//  Created by Jakub Suder on 28-04-09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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

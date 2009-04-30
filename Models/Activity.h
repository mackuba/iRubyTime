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

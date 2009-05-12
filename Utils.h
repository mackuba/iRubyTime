// -------------------------------------------------------
// Utils.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

#define ReleaseAll(...) \
  NSArray *_releaseList = [[NSArray alloc] initWithObjects: __VA_ARGS__, nil]; \
  for (NSObject *object in _releaseList) { \
    [object release]; \
  } \
  [_releaseList release];

#define OnDeallocRelease(...) \
  - (void) dealloc { \
    ReleaseAll(__VA_ARGS__); \
    [super dealloc]; \
  }

#define SynthesizeAndReleaseLater(...) \
  @synthesize __VA_ARGS__; \
  OnDeallocRelease(__VA_ARGS__);

#define Observe(sender, notification, callback) \
  NSLog(@"%s:%d: registering for %@", __FILE__, __LINE__, (notification)); \
  [[NSNotificationCenter defaultCenter] addObserver: self \
                                           selector: @selector(callback) \
                                               name: (notification) \
                                             object: (sender)];

#define NotifyWithDataAs(sender, notification, data) \
  NSLog(@"%s:%d: %@ sends %@ (%@)", __FILE__, __LINE__, (sender), (notification), (data)); \
  [[NSNotificationCenter defaultCenter] postNotificationName: (notification) \
                                                      object: (sender) \
                                                    userInfo: (data)];

#define NotifyWithData(notification, data) NotifyWithDataAs(self, (notification), (data))
#define Notify(notification) NotifyWithData((notification), nil)

#define RTArray(...) [NSArray arrayWithObjects: __VA_ARGS__, nil]
#define RTDict(...) [NSDictionary dictionaryWithObjectsAndKeys: __VA_ARGS__, nil]
#define RTFormat(...) [NSString stringWithFormat: __VA_ARGS__]
#define RTInt(i) [NSNumber numberWithInt: i]


@interface Utils : NSObject
+ (void) showAlertWithTitle: (NSString *) title content: (NSString *) content;
@end

@interface NSString (RubyTime)
- (NSString *) trimmedString;
@end
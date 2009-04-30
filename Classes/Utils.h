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

#define RTArray(...) [NSArray arrayWithObjects: __VA_ARGS__, nil]
#define RTDict(...) [NSDictionary dictionaryWithObjectsAndKeys: __VA_ARGS__, nil]
#define RTFormat(...) [NSString stringWithFormat: __VA_ARGS__]


@interface Utils : NSObject
+ (void) showAlertWithTitle: (NSString *) title content: (NSString *) content;
@end

@interface NSString (RubyTime)
- (NSString *) trimmedString;
@end

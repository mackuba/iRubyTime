// -------------------------------------------------------
// Utils.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;

#define RubyTimeErrorDomain @"RubyTimeErrorDomain"

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
  [[NSNotificationCenter defaultCenter] addObserver: self \
                                           selector: @selector(callback) \
                                               name: (notification) \
                                             object: (sender)]

#define StopObservingAll() [[NSNotificationCenter defaultCenter] removeObserver: self]
#define StopObserving(sender, notification) \
  [[NSNotificationCenter defaultCenter] removeObserver: self \
                                                  name: (notification) \
                                                object: (sender)]

#define NotifyWithData(notification, data) \
  [[NSNotificationCenter defaultCenter] postNotificationName: (notification) \
                                                      object: self \
                                                    userInfo: (data)]

#define Notify(notification) NotifyWithData((notification), nil)

#define RTArray(...) [NSArray arrayWithObjects: __VA_ARGS__, nil]
#define RTDict(...) [NSDictionary dictionaryWithObjectsAndKeys: __VA_ARGS__, nil]
#define RTFormat(...) [NSString stringWithFormat: __VA_ARGS__]
#define RTInt(i) [NSNumber numberWithInt: i]
#define RTIndex(sec, row) [NSIndexPath indexPathForRow: row inSection: sec]

@interface UIAlertView (RubyTime)
+ (void) showAlertWithTitle: (NSString *) title content: (NSString *) content;
@end

@interface NSString (RubyTime)
- (NSString *) trimmedString;
- (NSString *) stringWithPercentEscapesForFormValues;
@end

@interface NSError (RubyTime)
- (NSString *) friendlyDescription;
@end

@interface UITableView (RubyTime)
- (UITableViewCell *) cellWithStyle: (UITableViewCellStyle) style andIdentifier: (NSString *) identifier;
@end

@interface UIActivityIndicatorView (RubyTime)
+ (UIActivityIndicatorView *) spinnerBarButton;
@end

@interface UIViewController (RubyTime)
- (void) initializeLengthPicker: (UIDatePicker *) picker usingActivity: (Activity *) activity;
@end

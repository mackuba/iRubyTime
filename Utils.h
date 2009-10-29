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

#define AbstractMethod(returnStatement) { [self doesNotRecognizeSelector: _cmd]; returnStatement; }

@interface IntArray : NSObject {
  NSInteger *values;
  NSInteger size;
}

@property (nonatomic, readonly) NSInteger size;

+ (IntArray *) arrayOfSize: (NSInteger) size integers: (NSInteger) first, ...;
+ (IntArray *) emptyArray;
- (id) initWithSize: (NSInteger) size;
- (void) setInteger: (NSInteger) value atIndex: (NSInteger) index;
- (NSInteger) integerAtIndex: (NSInteger) index;
@end

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

@interface UIImage (RubyTime)
+ (UIImage *) loadImageFromBundle: (NSString *) imageName;
@end

@interface UIViewController (RubyTime)
- (void) initializeLengthPicker: (UIDatePicker *) picker usingActivity: (Activity *) activity;
- (void) setBackButtonTitle: (NSString *) title;
@end

@interface NSUserDefaults (RubyTime)
- (NSString *) passwordForKey: (NSString *) key andUsername: (NSString *) username;
- (void) setPassword: (NSString *) password forKey: (NSString *) key andUsername: (NSString *) username;
@end

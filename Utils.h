// -------------------------------------------------------
// Utils.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;

#define RTUniversalNib(name) (PSiPadDevice ? ([name stringByAppendingString: @"-iPad"]) : name)

@interface NSError (RubyTime)
- (NSString *) friendlyDescription;
@end

@interface UIActivityIndicatorView (RubyTime)
+ (UIActivityIndicatorView *) spinnerBarButton;
@end

@interface UIViewController (RubyTime)
- (void) initializeLengthPicker: (UIDatePicker *) picker usingActivity: (Activity *) activity;
@end

// -------------------------------------------------------
// Utils.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class Activity;

#define RubyTimeErrorDomain @"RubyTimeErrorDomain"
#define AbstractMethod(returnStatement) { [self doesNotRecognizeSelector: _cmd]; returnStatement; }


@interface NSError (RubyTime)
- (NSString *) friendlyDescription;
@end

@interface NSUserDefaults (RubyTime)
- (NSString *) passwordForKey: (NSString *) key andUsername: (NSString *) username;
- (void) setPassword: (NSString *) password forKey: (NSString *) key andUsername: (NSString *) username;
@end

@interface UIActivityIndicatorView (RubyTime)
+ (UIActivityIndicatorView *) spinnerBarButton;
@end

@interface UIImage (RubyTime)
+ (UIImage *) loadImageFromBundle: (NSString *) imageName;
@end

@interface UIViewController (RubyTime)
- (void) initializeLengthPicker: (UIDatePicker *) picker usingActivity: (Activity *) activity;
@end

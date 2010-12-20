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

#define RTiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define RTUniversalNib(name) (RTiPad ? ([name stringByAppendingString: @"-iPad"]) : name)

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

// -------------------------------------------------------
// LoadingView.h
//
// Created by Matt Gallagher
// http://cocoawithlove.com/2009/04/showing-message-over-iphone-keyboard.html
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface LoadingView : UIView {}

+ (id) loadingViewInView: (UIView *) aSuperview;
- (void) removeView;

@end

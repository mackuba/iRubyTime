// -------------------------------------------------------
// LoadingView.m
//
// Created by Matt Gallagher
// http://cocoawithlove.com/2009/04/showing-message-over-iphone-keyboard.html
// -------------------------------------------------------

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView

+ (id) loadingViewInView: (UIView *) aSuperview {
  LoadingView *loadingView = [[[LoadingView alloc] initWithFrame: [aSuperview bounds]] autorelease];
  if (loadingView) {
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [aSuperview addSubview: loadingView];

  	const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
  	const CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
  	CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
  	UILabel *loadingLabel = [[[UILabel alloc] initWithFrame: labelFrame] autorelease];
    loadingLabel.text = @"Loading data...";
  	loadingLabel.textColor = [UIColor colorWithRed: 0.42 green: 0.43 blue: 0.45 alpha: 1.0];
  	loadingLabel.backgroundColor = [UIColor clearColor];
  	loadingLabel.textAlignment = UITextAlignmentCenter;
  	loadingLabel.font = [UIFont boldSystemFontOfSize: [UIFont labelFontSize]];
  	loadingLabel.autoresizingMask =
  		UIViewAutoresizingFlexibleLeftMargin |
  		UIViewAutoresizingFlexibleRightMargin |
  		UIViewAutoresizingFlexibleTopMargin |
  		UIViewAutoresizingFlexibleBottomMargin;
  	[loadingView addSubview: loadingLabel];

  	UIActivityIndicatorView *activityIndicatorView =
  		[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray]
  		autorelease];
  	activityIndicatorView.autoresizingMask =
  		UIViewAutoresizingFlexibleLeftMargin |
  		UIViewAutoresizingFlexibleRightMargin |
  		UIViewAutoresizingFlexibleTopMargin |
  		UIViewAutoresizingFlexibleBottomMargin;
  	[activityIndicatorView startAnimating];
  	[loadingView addSubview: activityIndicatorView];

  	CGFloat totalHeight = loadingLabel.frame.size.height + activityIndicatorView.frame.size.height;
  	labelFrame.origin.x = floor(0.5 * (loadingView.frame.size.width - DEFAULT_LABEL_WIDTH));
  	labelFrame.origin.y = floor(0.5 * (loadingView.frame.size.height - totalHeight));
  	loadingLabel.frame = labelFrame;

  	CGRect activityIndicatorRect = activityIndicatorView.frame;
  	activityIndicatorRect.origin.x = 0.5 * (loadingView.frame.size.width - activityIndicatorRect.size.width);
  	activityIndicatorRect.origin.y = loadingLabel.frame.origin.y + loadingLabel.frame.size.height;
  	activityIndicatorView.frame = activityIndicatorRect;

    // Set up the fade-in animation
    CATransition *animation = [CATransition animation];
    [animation setType: kCATransitionFade];
    [[aSuperview layer] addAnimation: animation forKey: @"layerAnimation"];
  }
  return loadingView;
}

- (void) drawRect: (CGRect) rect {
  rect.size.height -= 1;
  rect.size.width -= 1;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetRGBFillColor(context, 1, 1, 1, 1);
  CGContextFillRect(context, rect);
}

- (void) removeView {
	UIView *aSuperview = [self superview];
	[super removeFromSuperview];

	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType: kCATransitionFade];
	[[aSuperview layer] addAnimation: animation forKey: @"layerAnimation"];
}

@end

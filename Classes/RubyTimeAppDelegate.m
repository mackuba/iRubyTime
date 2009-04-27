//
//  RubyTimeAppDelegate.m
//  RubyTime
//
//  Created by Jakub Suder on 27-04-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RubyTimeAppDelegate.h"
#import "RootViewController.h"


@implementation RubyTimeAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

#import "AppDelegate.h"
#include "Window.h"

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification{
	NSLog(@"finished launching application");
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
	return YES;
}

@end


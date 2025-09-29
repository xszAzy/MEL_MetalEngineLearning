#import "AppDelegate.h"
#import "Window/WindowManager.h"

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification{
	NSRect frame=NSMakeRect(0, 0, 1280, 720);
	
	WindowManager* windowManager=[[WindowManager alloc] initWithFrame:frame title:@"Metal Learning - first triangle"];
	
	[windowManager show];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
	return YES;
}

@end

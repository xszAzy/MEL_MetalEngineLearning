#import "WindowManager.h"
#import "Window.h"
#import "ViewController.h"

@implementation WindowManager

- (instancetype)initWithFrame:(NSRect)frame title:(NSString *)title {
	self=[super init];
	if(self){
		NSWindowStyleMask style=
		NSWindowStyleMaskTitled |
		NSWindowStyleMaskClosable |
		NSWindowStyleMaskResizable |
		NSWindowStyleMaskMiniaturizable;
		
		_window=[[Window alloc] initWithFrame:frame styleMask:style title:title];
		_viewController=[[ViewController alloc] init];
		
		NSView* contentView=[[NSView alloc] initWithFrame:frame];
		[contentView addSubview:_viewController.view];
		_viewController.view.frame=contentView.bounds;
		
		_viewController.view.autoresizingMask=NSViewWidthSizable|NSViewHeightSizable;
		
		_window.contentView=contentView;
		_window.contentViewController=_viewController;
	}
	return self;
}


- (void)show {
	[_window makeKeyAndOrderFront:nil];
}


@end

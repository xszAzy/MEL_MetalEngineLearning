#import "CocoaWindow.h"

#import "Events/KeyEvent.h"
#import "Events/MouseEvent.h"
#import "Events/ApplicationEvent.h"
#include "imgui_impl_osx.h"
#include "MacInput.h"

@implementation CocoaWindow

- (instancetype)initWithFrame:(NSRect)frame styleMask:(NSWindowStyleMask)styleMask title:(NSString *)title {
	self=[super initWithContentRect:frame
						  styleMask:styleMask
							backing:NSBackingStoreBuffered
							  defer:NO];
	if(self){
		[self center];
		[self setTitle:title];
		[self setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
		[self setDelegate:self];
	}
	return self;
}

//Key Events
-(void)keyDown:(NSEvent *)event{
	//MEL::MacInput::OnKeyEvent(event, true);
	int action;
	action=[event isARepeat]?1:0;
	MEL::KeyPressedEvent keyPressedEvent((int)[event keyCode],action);
	MEL::MacInput::OnKeyEvent(event, true);

	[self dispatchEvent:keyPressedEvent];
	
	MEL::KeyTypedEvent keyTyped((int)[event keyCode]);
	[self dispatchEvent:keyTyped];
}

-(void)keyUp:(NSEvent *)event{
	MEL::MacInput::OnKeyEvent(event, false);
	MEL::KeyReleasedEvent keyReleasedEvent((int)[event keyCode]);
	[self dispatchEvent:keyReleasedEvent];
}

//Mouse Events
-(void)mouseDown:(NSEvent *)event{
	MEL::MacInput::OnMouseEvent(event);
	MEL::MouseButtonPressedEvent mousePressed(1);
	[self dispatchEvent:mousePressed];
}

-(void)mouseUp:(NSEvent *)event{
	MEL::MacInput::OnMouseEvent(event);
	MEL::MouseButtonReleasedEvent mouseReleased(0);
	[self dispatchEvent:mouseReleased];
}

-(void)mouseMoved:(NSEvent *)event{
	MEL::MacInput::OnMouseMovedEvent(event);
	NSPoint location=[event locationInWindow];
	MEL::MouseMovedEvent mouseMovedEvent(location.x,location.y);
	[self dispatchEvent:mouseMovedEvent];
}

-(void)scrollWheel:(NSEvent *)event{
	float deltaX=[event scrollingDeltaX];
	float deltaY=[event scrollingDeltaY];
	
	if([event hasPreciseScrollingDeltas]){
		deltaX*=0.1f;
		deltaY*=0.1f;
	}
	
	MEL::MouseScrolledEvent mouseScrolled(deltaX,deltaY);
	[self dispatchEvent:mouseScrolled];
}

//Window Events
-(void)windowDidResize:(NSNotification *)notification{
	NSRect frame=[self contentRectForFrameRect:[self frame]];
	MEL::WindowResizeEvent windowResize(frame.size.width,frame.size.height);
	[self dispatchEvent:windowResize];
}

-(void)windowWillClose:(NSNotification *)notification{
	MEL::WindowCloseEvent windowClosed;
	[self dispatchEvent:windowClosed];
}

-(void)dispatchEvent:(MEL::Event &)event{
	if(self.eventCallback){
		self.eventCallback(event);
	}
}

-(void)dealloc{
	[_eventCallback release];
	[super dealloc];
}
@end

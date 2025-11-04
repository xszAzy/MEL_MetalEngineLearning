#include "MacInput.h"
#include "Log.h"

namespace MEL{
	bool MacInput::s_Keys[256]={false};
	bool MacInput::s_MouseButton[3]={false};
	
	float MacInput::s_MouseX=.0f;
	float MacInput::s_MouseY=.0f;
	
	void MacInput::Init(){
		memset(s_Keys, 0, sizeof(s_Keys));
		memset(s_MouseButton, 0, sizeof(s_MouseButton));
		s_MouseX=s_MouseY=0.0f;
		MEL_CORE_INFO("MacInput Initialized");
	}
	
	void MacInput::OnKeyEvent(NSEvent *event, bool pressed){
		if([event isARepeat])return;
		uint16_t KeyCode=[event keyCode];
		if(KeyCode<256){
			s_Keys[KeyCode]=pressed;
		}
	}
	
	void MacInput::OnMouseEvent(NSEvent *event){
		int button=CocoaToEngineMouseButton(event);
		if(button>=0&&button<=3){
			NSEventType type=[event type];
			s_MouseButton[button]=(type==NSEventTypeLeftMouseDown||
								   type==NSEventTypeRightMouseDown||
								   type==NSEventTypeOtherMouseDown);
		}
	}
	
	void MacInput::OnMouseMovedEvent(NSEvent *event){
		NSPoint location=[event locationInWindow];
		NSWindow* window=[event window];
		if(window){
			NSRect frame=[window frame];
			
			s_MouseX=location.x;
			s_MouseY=frame.size.height-location.y;
		}
	}
	
	int MacInput::CocoaToEngineMouseButton(NSEvent *event){
		switch ([event type]) {
			case NSEventTypeLeftMouseDown:
			case NSEventTypeLeftMouseUp:
			case NSEventTypeLeftMouseDragged:
				return 0;
				break;
			case NSEventTypeRightMouseUp:
			case NSEventTypeRightMouseDown:
			case NSEventTypeRightMouseDragged:
				return 1;
				break;
			case NSEventTypeOtherMouseUp:
			case NSEventTypeOtherMouseDown:
			case NSEventTypeOtherMouseDragged:
				return 2;
				break;
			default:
				return -1;
				break;
		}
	}
	
	bool MacInput::IsKeyPressed(int KeyCode){
		return KeyCode<256?s_Keys[KeyCode]:false;
	}
	
	bool MacInput::IsMouseButtonPressed(int button){
		return button>=0&&button<3?s_MouseButton[button]:false;
	}
	
	std::pair<float,float> MacInput::GetMousePosition(){
		return {s_MouseX,s_MouseY};
	}
}

#include "MacInput.h"
#include "Application.h"
namespace MEL{
	std::unordered_map<uint16_t, Keycode> MacInput::s_KeyMap;
	std::unordered_map<Keycode, bool> MacInput::s_KeyState;
	std::unordered_map<int, bool> MacInput::s_MouseState;
	float MacInput::MouseX=.0f;
	float MacInput::MouseY=.0f;
	
	void MacInput::Init(){
		s_KeyState[Key::D1				]=false;
		s_KeyState[Key::D2				]=false;
		s_KeyState[Key::D3				]=false;
		s_KeyState[Key::D4				]=false;
		s_KeyState[Key::D5				]=false;
		s_KeyState[Key::D6				]=false;
		s_KeyState[Key::D7				]=false;
		s_KeyState[Key::D8				]=false;
		s_KeyState[Key::D9				]=false;
		s_KeyState[Key::D0				]=false;
		s_KeyState[Key::S1				]=false;
		s_KeyState[Key::S2				]=false;
		s_KeyState[Key::S3				]=false;
		s_KeyState[Key::S4				]=false;
		s_KeyState[Key::S6				]=false;
		s_KeyState[Key::S7				]=false;
		s_KeyState[Key::S8				]=false;
		s_KeyState[Key::S9				]=false;
		s_KeyState[Key::S10				]=false;
		s_KeyState[Key::S11				]=false;
		s_KeyState[Key::S12				]=false;
		s_KeyState[Key::N				]=false;
		s_KeyState[Key::M				]=false;
		s_KeyState[Key::Q				]=false;
		s_KeyState[Key::W				]=false;
		s_KeyState[Key::E				]=false;
		s_KeyState[Key::R				]=false;
		s_KeyState[Key::T				]=false;
		s_KeyState[Key::Y				]=false;
		s_KeyState[Key::U				]=false;
		s_KeyState[Key::I				]=false;
		s_KeyState[Key::O				]=false;
		s_KeyState[Key::P				]=false;
		s_KeyState[Key::A				]=false;
		s_KeyState[Key::S				]=false;
		s_KeyState[Key::D				]=false;
		s_KeyState[Key::F				]=false;
		s_KeyState[Key::G				]=false;
		s_KeyState[Key::H				]=false;
		s_KeyState[Key::J				]=false;
		s_KeyState[Key::K				]=false;
		s_KeyState[Key::L				]=false;
		s_KeyState[Key::Z				]=false;
		s_KeyState[Key::X				]=false;
		s_KeyState[Key::C				]=false;
		s_KeyState[Key::V				]=false;
		s_KeyState[Key::B				]=false;
		s_KeyState[Key::enter			]=false;
		
		s_MouseState[0]=false;
		s_MouseState[1]=false;
		s_MouseState[2]=false;
	}
	
	void MacInput::OnKeyEvent(NSEvent *event, bool pressed){
		Keycode keycode=[event keyCode];
		s_KeyState[keycode]=pressed;
	}
	
	void MacInput::OnMouseEvent(NSEvent *event){
		int button=CocoaToEngineMouseButton(event);
		NSEventType type=[event type];
		
		switch (type) {
			case NSEventTypeLeftMouseUp:
			case NSEventTypeRightMouseUp:
			case NSEventTypeOtherMouseUp:
				s_MouseState[button]=false;
				break;
			case NSEventTypeLeftMouseDown:
			case NSEventTypeRightMouseDown:
			case NSEventTypeOtherMouseDown:
				s_MouseState[button]=true;
				break;
			default:
				break;
		}
	}
	
	void MacInput::OnMouseMovedEvent(NSEvent *event){
		NSPoint location=[event locationInWindow];
		MouseX=location.x;
		MouseY=location.y;
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
	
	bool MacInput::IsKeyPressedImpl(Keycode keycode){
		auto it=s_KeyState.find(keycode);
		return (it != s_KeyState.end())?it->second:false;
	}
	
	bool MacInput::IsMouseButtonPressedImpl(int button){
		auto it=s_MouseState.find(button);
		return (it != s_MouseState.end())?it->second:false;
	}
	
	std::pair<float,float> MacInput::GetMousePositionImpl(){
		return {MouseX,MouseY};
	}
}

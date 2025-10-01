#pragma once
#include "Input.h"
#include <AppKit/AppKit.h>

namespace MEL{
	class MacInput:public Input{
	public:
		static void Init();
		
		static void OnKeyEvent(NSEvent* event,bool pressed);
		static void OnMouseEvent(NSEvent* event);
		static void OnMouseMovedEvent(NSEvent* event);
		
		static bool IsKeyPressedImpl(Keycode keycode);
		static bool IsMouseButtonPressedImpl(int button);
		static float GetMouseXImpl(){return MouseX;}
		static float GetMouseYImpl(){return MouseY;}
		static std::pair<float,float> GetMousePositionImpl();
		
	private:
		static std::unordered_map<Keycode, bool> s_KeyState;
		static std::unordered_map<int, bool> s_MouseState;
		static float MouseX,MouseY;
		
		static std::unordered_map<uint16_t, Keycode> s_KeyMap;
		
		static int CocoaToEngineMouseButton(NSEvent* event);
	};
}

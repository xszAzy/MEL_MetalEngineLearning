#pragma once
#include <AppKit/AppKit.h>
#include"MacKeycode.h"
#include <utility>

namespace MEL{
	class MacInput{
	public:
		static void Init();
		
		static void OnKeyEvent(NSEvent* event,bool pressed);
		static void OnMouseEvent(NSEvent* event);
		static void OnMouseMovedEvent(NSEvent* event);
	
		static bool IsKeyPressed(int keycode);
		static bool IsMouseButtonPressed(int button);
		static float GetMouseX(){return s_MouseX;}
		static float GetMouseY(){return s_MouseY;}
		static std::pair<float,float> GetMousePosition();
		
	private:
		static bool s_Keys[256];
		static bool s_MouseButton[3];
		static float s_MouseX,s_MouseY;
		
		static int CocoaToEngineMouseButton(NSEvent* event);
	};
}

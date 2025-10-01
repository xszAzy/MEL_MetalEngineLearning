#include "ImGuiLayer.h"

#import "imgui.h"
#import "imgui_impl_metal.h"
#import "imgui_impl_osx.h"

namespace MEL{
	ImGuiLayer::ImGuiLayer(NSWindow* window):m_NativeWindow(window){
		
	}
	
	void ImGuiLayer::OnAttach(){
		
	}
}

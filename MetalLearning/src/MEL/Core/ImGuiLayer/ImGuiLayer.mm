#include "ImGuiLayer.h"
#include "Renderer/Renderer.h"
#import "ViewController/ViewController.h"
#import "imgui.h"
#import "imgui_impl_metal.h"
#import "imgui_impl_osx.h"

namespace MEL{
	ImGuiLayer::ImGuiLayer():m_Renderer(nullptr){
	}
	ImGuiLayer::~ImGuiLayer(){
		
	}
	
	void ImGuiLayer::OnAttach(){
		m_Renderer=Application::Get().GetRenderer();
		ImGui::CreateContext();
		
		ImGuiIO& io=ImGui::GetIO();
		io.ConfigFlags |=ImGuiConfigFlags_NavEnableKeyboard;
		io.ConfigFlags |=ImGuiConfigFlags_DockingEnable;
		io.ConfigFlags |=ImGuiConfigFlags_ViewportsEnable;//dont support it for now
		
		ImGui_ImplMetal_Init(m_Renderer->GetMetalDevice());
		ImGui_ImplOSX_Init(m_Renderer->GetMTKView());
		ImGui::StyleColorsDark();
		
		m_Renderer->SetImGuiEnabled(true);
	}
	
	void ImGuiLayer::OnDetach(){
		ImGui_ImplOSX_Shutdown();
		ImGui_ImplMetal_Shutdown();
		ImGui::DestroyContext();
	}
	
	void ImGuiLayer::Begin(){
		m_Renderer->BeginImGui();
	}
	
	void ImGuiLayer::End(){
		m_Renderer->EndImGui();
	}
	
	void ImGuiLayer::OnImGuiRender(){
		
	}
}

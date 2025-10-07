#include "MEL.h"
#include "imgui.h"
#include <stdio.h>

class ExampleLayer:public MEL::Layer{
public:
	ExampleLayer()
	:Layer("Example"){
		
	}
	void OnImGuiRender()override{
		ImGui::Begin("MEL Engine - Metal Implementation");
		ImGui::Text("Hello, Metal! This is your engine");
		
		ImGui::Text("Application average %.3f ms/frame (%.1f FPS)",1000.0f/ImGui::GetIO().Framerate,ImGui::GetIO().Framerate);
		static bool show=1;
		if(show)
			ImGui::ShowDemoWindow(&show);
		
		ImGui::End();
	}
	
	void OnUpdate() override{
		//MEL_INFO("testing update");
	}
	
	void OnAttach() override{
		
	}
	
	void OnEvent(MEL::Event& e) override{
		MEL_INFO("testing event{0}",e.ToString());
	}
	
private:
	
};

class Sandbox:public MEL::Application{
public:
	Sandbox(){
		PushLayer(new ExampleLayer());
		
	}
	~Sandbox(){
		
	}
private:
	
};

MEL::Application* MEL::CreateApplication(){
	return new Sandbox();
}

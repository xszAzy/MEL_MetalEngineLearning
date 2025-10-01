#include "MEL.h"
#include <stdio.h>

class ExampleLayer:public MEL::Layer{
public:
	ExampleLayer()
	:Layer("Example"){
		
	}
	
	void OnUpdate() override{
		MEL_INFO("testing update");
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

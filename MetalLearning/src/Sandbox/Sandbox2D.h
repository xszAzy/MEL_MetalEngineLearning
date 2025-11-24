#pragma once
#include "Render.h"

class Sandbox2D:public MEL::Layer{
public:
	Sandbox2D();
	virtual ~Sandbox2D()=default;
	virtual void OnAttach() override;
	virtual void OnDetach() override;
	
	void OnUpdate(MEL::Timestep ts)override;
	virtual void OnImGuiRender() override;
	void OnEvent(MEL::Event& e)override;
private:
	MEL::CameraController m_CameraController;
	MEL::Renderer* m_Renderer;
	
	float m_SquareColor[4] ={.2f,.3f,.7f,1.0f};
	
	std::vector<MEL::Ref<MEL::GameObject>> m_GameObjects;
};

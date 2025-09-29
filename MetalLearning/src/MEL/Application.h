#pragma once
#include "Events/Event.h"
#include "Events/KeyEvent.h"
#include "Events/MouseEvent.h"
#include "Events/ApplicationEvent.h"
namespace MEL {
	class Application{
	public:
		Application();
		virtual ~Application();
		
		void OnEvent(MEL::Event& e);
		void Run();
	private:
		bool OnWindowClose(WindowCloseEvent& event);
		bool m_Running;
	};
	Application* CreateApplication();
}

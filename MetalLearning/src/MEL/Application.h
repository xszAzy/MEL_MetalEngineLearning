#pragma once
#include "Window.h"
#include "Events/Event.h"
#include "Events/KeyEvent.h"
#include "Events/MouseEvent.h"
#include "Events/ApplicationEvent.h"
namespace MEL{
	class Window;
}
namespace MEL {
	class Application{
	public:
		Application();
		virtual ~Application();
		void OnEvent(Event& e);
		
		void Run();
	private:
		bool OnWindowClose(WindowCloseEvent& event);
	private:
		std::unique_ptr<Window> m_Window;
		bool m_Running=true;
	};
	Application* CreateApplication();
}

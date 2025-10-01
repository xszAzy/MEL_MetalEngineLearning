#pragma once
#include "Window.h"
#include "Events/Event.h"
#include "Events/ApplicationEvent.h"
#include "Layer/LayerStack.h"

namespace MEL{
	class Window;
}
namespace MEL {
	class Application{
	public:
		Application();
		virtual ~Application();
		
		void Run();
		void OnEvent(Event& e);
		void PushLayer(Layer* layer);
		void PushOverlay(Layer* overlay);
		
		inline static Application& Get() {return * s_Instance;}
		inline Window& GetWindow(){return *m_Window;}
	private:
		bool OnWindowClose(WindowCloseEvent& event);
	private:
		std::unique_ptr<Window> m_Window;
		bool m_Running=true;
		LayerStack m_LayerStack;
		
		static Application* s_Instance;
	};
	Application* CreateApplication();
}

#pragma once
#include "Window.h"
#include "Events/Event.h"
#include "Events/ApplicationEvent.h"
#include "Layer/LayerStack.h"
#include "ImGuiLayer/ImGuiLayer.h"

namespace MEL{
	class Window;
	class Renderer;
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
		inline Renderer* GetRenderer(){return m_Renderer;}
	private:
		bool OnWindowClose(WindowCloseEvent& event);
	private:
		std::unique_ptr<Window> m_Window;
		Renderer* m_Renderer;
		ImGuiLayer* m_ImGuiLayer;
		bool m_Running=true;
		LayerStack m_LayerStack;
		
		static Application* s_Instance;
	};
	Application* CreateApplication();
}

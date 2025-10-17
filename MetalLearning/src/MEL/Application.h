#pragma once
#include "Window.h"
#include "Events/Event.h"
#include "Events/ApplicationEvent.h"
#include "Layer/LayerStack.h"
#include "ImGuiLayer/ImGuiLayer.h"
#include "Shader/Shader.h"
#include "Delegates.h"

#import "Buffer/VertexBuffer.h"
#import "Buffer/IndexBuffer.h"
#import "Buffer/UniformBuffer.h"
#import "Buffer/BufferLayout.h"

#import "Transforms/Camera.h"

#import "VertexArray/VertexArray.h"

namespace MEL{
	class Window;
	class Renderer;
	class Shader;
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
	public:
		//Metal unique render
		void RenderOneFrame();
	private:
		std::unique_ptr<Window> m_Window;
		MELMTKViewDelegate* m_ViewDelegate;
		
		Renderer* m_Renderer;
		
		ImGuiLayer* m_ImGuiLayer;
		LayerStack m_LayerStack;
		
		bool m_Running=true;
		static Application* s_Instance;
		
		float m_LastframeTime=0.0f;
	};
	Application* CreateApplication();
}

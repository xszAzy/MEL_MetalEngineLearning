#import "melpch.h"
#import "Renderer/AppDelegate.h"
#include "Application.h"
#include "MacWindow.h"

namespace MEL{
	Application* Application::s_Instance=nullptr;
	
	Application::Application(){
		s_Instance=this;
		m_Window=std::unique_ptr<Window>(Window::Create());
		m_Window->SetEventCallback(MEL_BIND_EVENT_FN(Application::OnEvent));
		
		auto* macWindow=static_cast<MacWindow*>(m_Window.get());
		m_Renderer=macWindow->GetRenderer();
		m_ImGuiLayer=new ImGuiLayer();
		PushOverlay(m_ImGuiLayer);
	}
	
	Application::~Application(){
		
	}
	
	void Application::OnEvent(Event &e){
		EventDispatcher dispathcher(e);
		dispathcher.Dispatch<WindowCloseEvent>(MEL_BIND_EVENT_FN(Application::OnWindowClose));
		
		MEL_CORE_INFO("{0}",e.ToString());
		
		for(auto it=m_LayerStack.end();it!=m_LayerStack.begin();){
			(*--it)->OnEvent(e);
			if(e.m_Handled)
				break;
		}
	}
	
	bool Application::OnWindowClose(WindowCloseEvent& event){
		m_Running=false;
		return true;
	}
	
	void Application::Run() {
		
		NSApplication* application=[NSApplication sharedApplication];
		AppDelegate* appDelegate=[[AppDelegate alloc] init];
		[application setDelegate:appDelegate];
		[application finishLaunching];
		[application activateIgnoringOtherApps:YES];
		while (m_Running){
			@autoreleasepool {
				NSEvent* event;
				while ((event=[application nextEventMatchingMask:NSEventMaskAny
													   untilDate:[NSDate distantPast]
														  inMode:NSDefaultRunLoopMode
														 dequeue:YES])){
					[application sendEvent:event];
				}
				
				if(m_Renderer){
					m_Renderer->BeginFrame();
					m_Renderer->BeginScene();
					m_Renderer->CreatePipelineState();
					m_ImGuiLayer->Begin();
					
					m_Renderer->DrawIndexed(3);
					for(Layer* layer:m_LayerStack)
						layer->OnUpdate();
					
					for (Layer* layer :m_LayerStack)
						layer->OnImGuiRender();
					
					m_ImGuiLayer->End();
					
					
					
					m_Renderer->EndScene();
					m_Renderer->EndFrame();
				}
				
				m_Window->OnUpdate();
				
				[NSThread sleepForTimeInterval:0.016];
				m_Window->Show();
			}
		}
		[application stop:nil];
	}
	
	void Application::PushLayer(Layer *layer){
		m_LayerStack.PushLayer(layer);
		layer->OnAttach();
	}
	
	void Application::PushOverlay(Layer *overlay){
		m_LayerStack.PushOverLay(overlay);
		overlay->OnAttach();
	}
	
}

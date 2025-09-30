#import "melpch.h"
#import "Renderer/AppDelegate.h"
#include "Log.h"
#include "Application.h"
#include "Events/ApplicationEvent.h"

namespace MEL{
	Application::Application(){
		m_Window=std::unique_ptr<Window>(Window::Create());
		m_Window->SetEventCallback([this](MEL::Event& e){
			this->OnEvent(e);
		});
	}
	
	Application::~Application(){
		
	}
	
	void Application::OnEvent(Event &e){
		EventDispatcher dispathcher(e);
		dispathcher.Dispatch<WindowCloseEvent>(MEL_BIND_EVENT_FN(Application::OnWindowClose));
		
		MEL_CORE_INFO("{0}",e.ToString());
	}
	
	void Application::Run() {
		m_Window->Show();
		NSApplication* application=[NSApplication sharedApplication];
		AppDelegate* appDelegate=[[AppDelegate alloc] init];
		[application setDelegate:appDelegate];
		[application run];
		while (m_Running){
			
			m_Window->OnUpdate();
		}
	}
	
	bool Application::OnWindowClose(WindowCloseEvent& event){
		m_Running=false;
		return true;
	}
	
}

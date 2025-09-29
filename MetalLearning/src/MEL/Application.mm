#import "melpch.h"
#import "Renderer/AppDelegate.h"
#include "Log.h"
#include "Application.h"
#include "Events/ApplicationEvent.h"

namespace MEL{
	Application::Application(){
		
	}
	
	Application::~Application(){
		
	}
	
	void Application::OnEvent(MEL::Event& e){
		
	}
	
	void Application::Run() {
		/*
		NSApplication* application=[NSApplication sharedApplication];
		AppDelegate* appDelegate=[[AppDelegate alloc] init];
		[application setDelegate:appDelegate];
		
		[application run];
		 */
		while (m_Running){
			
		}
	}
	
	bool Application::OnWindowClose(WindowCloseEvent& event){
		m_Running=false;
		return true;
	}
	
}

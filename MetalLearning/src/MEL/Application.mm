#import "melpch.h"
#import "Renderer/Delegates.h"
#include "Application.h"
#include "MacWindow.h"
#include "Core/Utils.h"
#include "Core/Timestep.h"
#include "RenderCommand.h"

namespace MEL{
	Application* Application::s_Instance=nullptr;
	
	Application::Application(){
		s_Instance=this;
		
		m_Window=std::unique_ptr<Window>(Window::Create());
		m_Window->SetEventCallback(MEL_BIND_EVENT_FN(Application::OnEvent));
		//Get Renderer first
		auto* macWindow=static_cast<MacWindow*>(m_Window.get());
		m_Renderer=macWindow->GetRenderer();
		
		RenderCommand::Init(m_Renderer);
		
		//then push imgui layer
		m_ImGuiLayer=new ImGuiLayer();
		PushOverlay(m_ImGuiLayer);
		
		//initialize layers
		for(Layer* layer:m_LayerStack)
			layer->OnAttach();
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
		
		MTKView* mtkView=m_Renderer->GetMTKView();
		
		m_ViewDelegate=[[MELMTKViewDelegate alloc] initWithApplication:this];
		[mtkView setDelegate:m_ViewDelegate];
		
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
				
				[NSThread sleepForTimeInterval:0.001];
				
				m_Window->Show();
			}
		}
		[m_ViewDelegate release];
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
	
	void Application::RenderOneFrame(){
		if(m_Renderer){
			float currentTime=Time::GetTime();
			Timestep timestep=currentTime-m_LastframeTime;
			m_LastframeTime=currentTime;
			//begin frame(command buffer)
			RenderCommand::BeginFrame();
			//begin scene(pipeline desc,encoder,with sets)
			RenderCommand::BeginScene(m_Renderer->GetSceneCamera());
			
			//layers
			for(Layer* layer:m_LayerStack)
				layer->OnUpdate(timestep);
			
			//ImGui UI frame begin
			m_ImGuiLayer->Begin();
			//ImGui draw
			for (Layer* layer :m_LayerStack)
				layer->OnImGuiRender();
			
			//end ImGui
			m_ImGuiLayer->End();
			//end scene
			RenderCommand::EndScene();
			//end frame
			RenderCommand::EndFrame();
		}
	}
	
}

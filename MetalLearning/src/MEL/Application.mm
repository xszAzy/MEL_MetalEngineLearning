#import "melpch.h"
#import "Renderer/AppDelegate.h"
#include "Application.h"
#include "MacWindow.h"

#import "Buffer/VertexBuffer.h"
#import "Buffer/IndexBuffer.h"
#import "Buffer/BufferLayout.h"
#import "VertexArray/VertexArray.h"

namespace MEL{
	Application* Application::s_Instance=nullptr;
	
	Application::Application(){
		s_Instance=this;
		m_Window=std::unique_ptr<Window>(Window::Create());
		m_Window->SetEventCallback(MEL_BIND_EVENT_FN(Application::OnEvent));
		//Get Renderer first
		auto* macWindow=static_cast<MacWindow*>(m_Window.get());
		m_Renderer=macWindow->GetRenderer();
		//then push imgui layer
		m_ImGuiLayer=new ImGuiLayer();
		PushOverlay(m_ImGuiLayer);
		//create vertex array
		m_VertexArray=MEL::VertexArray::Create();
		//set vertex and index buffer
		struct Vertex{
			float position[3];
			float color[4];
		};
		Vertex vertices[]={
			{{-0.5f,-0.5f,0.0f},
			{0.4f,0.2f,0.4f,1.0f}},
			
			{{0.5f,-0.5f,0.0f},
			{0.1f,0.7f,0.1f,1.0f}},
			
			{{0.0f,0.5f,0.0f},
			{0.1f,0.3f,0.4f,1.0f}}
		};
		
		uint32_t indices[]={0,1,2};
		//create bufferlayout
		BufferLayout layout={
			{ShaderDataType::Float3,"a_Position"},
			{ShaderDataType::Float4,"a_Color"}
		};
		//Set buffers
		auto basicVB=VertexBuffer::Create(vertices, sizeof(vertices));
		auto basicIB=IndexBuffer::Create(indices, 3);
		basicVB->SetSlot(0);
		basicVB->SetLayout(layout);
		
		m_VertexArray->AddVertexBuffer(basicVB);
		m_VertexArray->SetIndexBuffer(basicIB);
		
		
		//create shader(this can be done in sandbox)
		auto defaultShader=MEL::Shader::CreateFromDefaultLibrary("DefaultShader",
																 @"vertexShader",@"fragmentShader");
		if(defaultShader)
			defaultShader->CreatePipelineState(layout);
		m_CurrentShader=defaultShader;
		
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
			//begin frame(command buffer)
			m_Renderer->BeginFrame();
			//begin scene(pipeline desc,encoder,with sets)
			m_Renderer->BeginScene();
			//ImGui UI frame begin
			m_ImGuiLayer->Begin();
			//upper three must call
			
			if(m_CurrentShader&&m_VertexArray){
				m_CurrentShader->Bind();
				m_Renderer->DrawIndexed(m_VertexArray);
			}
			
			//layers
			for(Layer* layer:m_LayerStack)
				layer->OnUpdate();
			
			//ImGui draw
			for (Layer* layer :m_LayerStack)
				layer->OnImGuiRender();
			
			//end ImGui
			m_ImGuiLayer->End();
			//end scene
			m_Renderer->EndScene();
			//end frame
			m_Renderer->EndFrame();
		}
	}
	
}

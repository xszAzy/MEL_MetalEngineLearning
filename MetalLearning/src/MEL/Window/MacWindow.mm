#include "MacWindow.h"
#import "CocoaWindow.h"
#import "ViewController.h"

namespace MEL {
	Window* Window::Create(const WindowProps& props){
		return new MacWindow(props);
	}
	MacWindow::MacWindow(const WindowProps& props){
		Init(props);
	}
	MacWindow::~MacWindow(){
		ShutDown();
	}
	
	void MacWindow::Init(const WindowProps &props){
		m_Data.Title=props.Title;
		m_Data.Width=props.Width;
		m_Data.Height=props.Height;
		MEL_CORE_INFO("Create Window: {0},{1},{2}",props.Title,props.Width,props.Height);
		
		NSRect frame=NSMakeRect(0, 0, props.Width, props.Height);
		
		NSWindowStyleMask style=
		NSWindowStyleMaskTitled |
		NSWindowStyleMaskClosable |
		NSWindowStyleMaskResizable |
		NSWindowStyleMaskMiniaturizable;
		
		NSString* title =[NSString stringWithUTF8String:props.Title.c_str()];
		
		m_Window=[[CocoaWindow alloc] initWithFrame:frame
										  styleMask:style
											  title:title];
		
		ViewController* viewController=[[ViewController alloc] init];
		NSView* contentView=[[NSView alloc] initWithFrame:frame];
		
		viewController.view.frame=contentView.bounds;
		
		viewController.view.autoresizingMask=NSViewWidthSizable|NSViewHeightSizable;
		
		m_Window.contentView=contentView;
		m_Window.contentViewController=viewController;
		
		
		if([m_Window isKindOfClass:[CocoaWindow class]]){
			CocoaWindow* cocoaWindow=(CocoaWindow*)m_Window;
			
			cocoaWindow.eventCallback=^(MEL::Event& event){
				if(m_Data.EventCallback)
					m_Data.EventCallback(event);
			};
		}
		m_ImGuiLayer=new ImGuiLayer(m_Window);
		LayerStack::PushOverLay(m_ImGuiLayer);
	}
	
	void MacWindow::ShutDown(){
		
	}
	
	void MacWindow::OnUpdate(){
		
	}
	
	void MacWindow::SetSync(bool enable){
		m_Data.VSync=enable;
	}
	
	bool MacWindow::IsVSync()const{
		return m_Data.VSync;
	}
	
	void MacWindow::Show(){
		if(m_Window){
			if([NSThread isMainThread]){
				[m_Window makeKeyAndOrderFront:nil];
			}
		}
	}
}


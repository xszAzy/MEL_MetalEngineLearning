#pragma once

#import <Cocoa/Cocoa.h>
namespace MEL {
	class Event;
}
typedef void (*EventCallback)(MEL::Event& event);

@interface Window :NSWindow<NSWindowDelegate>

@property (nonatomic,assign)EventCallback eventCallback;

-(instancetype)initWithFrame:
(NSRect)frame styleMask:(NSWindowStyleMask)styleMask title:(NSString*)title;

-(void)dispatchEvent:
(MEL::Event&)event;

@end

#include "melpch.h"
#include "MEL.h"
namespace MEL {
	struct WindowProps{
		std::string Title;
		unsigned int Width;
		unsigned int Height;
		WindowProps(const std::string &title="MEL Engine",unsigned int width=1280,unsigned int height=720)
		:Title(title),Width(width),Height(height){}
	};
	class Window{
	public:
		using EventCallbackFN=std::function<void(Event&)>;
		Window(const WindowProps& props);
		~Window();
		
		void OnUpdate();
		unsigned int GetWidth();
		unsigned int GetHeight();
		
		void SetEventCallback(const EventCallback& callback);
		
		void SetSync(bool enable);
		
		bool IsVSync()const;
		
		static Window* Create(const WindowProps& props=WindowProps());
		
	private:
		virtual void Init(const WindowProps& props);
		virtual void ShutDown();
	private:
		NSWindow* m_Window;
		struct WindowData{
			std::string Title;
			unsigned int Width,Height;
			bool VSync;
			EventCallbackFN EventCallback;
		};
		WindowData m_Data;
	};
}

#pragma once
#include "melpch.h"
#include "MEL.h"
#include "Window.h"
#include "ImGuiLayer/ImGuiLayer.h"
#include "Renderer.h"

namespace MEL {
	class MetalRenderer;
	class MacWindow:public Window{
	public:
		MacWindow(const WindowProps& props);
		virtual ~MacWindow();
		
		void OnUpdate() override;
		unsigned int GetWidth() const override {return m_Data.Width;}
		unsigned int GetHeight()const override {return m_Data.Height;}
		
		void* GetNativeWindow() const override {return m_Window;}
	
		void SetEventCallback(const EventCallbackFn& callback) override {m_Data.EventCallback =callback;}
		
		void SetSync(bool enable) override;
		
		bool IsVSync()const override;
		
		static Window* Create(const WindowProps& props=WindowProps());
		
		void Show()override;
		
		virtual Renderer* GetRenderer()const override{return m_Renderer;}
	private:
		virtual void Init(const WindowProps& props);
		virtual void ShutDown();
	private:
		NSWindow* m_Window;
		struct WindowData{
			std::string Title;
			unsigned int Width,Height;
			bool VSync;
			EventCallbackFn EventCallback;
		};
		WindowData m_Data;
	private:
		ImGuiLayer* m_ImGuiLayer;
		Renderer* m_Renderer;
	};
}


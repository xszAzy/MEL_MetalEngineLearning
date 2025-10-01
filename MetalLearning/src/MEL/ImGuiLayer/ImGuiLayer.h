#pragma once
#include "Layer/Layer.h"
#include "Layer/LayerStack.h"

namespace MEL{
	class ImGuiLayer:public Layer{
	public:
		ImGuiLayer(NSWindow* window);
		~ImGuiLayer();
		
		virtual void OnAttach()override;
		virtual void OnDetach()override;
		virtual void OnUpdate()override;
		virtual void OnImGuiRender()override;
		virtual void OnEvent(Event& event)override;
		
		void Begin();
		void End();
		
	private:
		NSWindow* m_NativeWindow;
	};
}


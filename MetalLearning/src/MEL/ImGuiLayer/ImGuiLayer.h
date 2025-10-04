#pragma once
#include "Layer/Layer.h"
#include "Layer/LayerStack.h"

namespace MEL{
	class Renderer;
	class ImGuiLayer:public Layer{
	public:
		ImGuiLayer();
		~ImGuiLayer();
		
		virtual void OnAttach()override;
		virtual void OnDetach()override;
		virtual void OnImGuiRender()override;
		void Begin();
		void End();
	private:
		id<MTLCommandQueue> m_CommandQueue;
		Renderer* m_Renderer;
	};
}


#pragma once
#include "MEL.h"

#include "Log.h"
namespace MEL {
	class Renderer{
	public:
		Renderer(MTKView* mtkview);
		~Renderer();
		
		void BeginFrame();
		void BeginScene();
		void EndScene();
		void EndFrame();
		void DrawIndexed(uint32_t indexcount);
		
		void CreatePipelineState();
		void SetVertexBuffer(void* data,size_t size);
		void SetIndexBuffer(uint32_t* indices,uint32_t count);
		
		void OnResize(uint32_t width,uint32_t height);
		
		void SetupPipeline();
	public:
		void SetImGuiEnabled(bool enabled){m_ImGuiEnabled=enabled;};
		bool IsImGuiEnabled(){return m_ImGuiEnabled;}
		
		void BeginImGui();
		void EndImGui();
	public:
		MTKView* GetMTKView(){return m_View;}
		id<MTLDevice> GetMetalDevice(){return m_Device;}
	private:
		MTKView* m_View;
		
		id<MTLDevice> m_Device;
		id<MTLCommandQueue> m_CommandQueue;
		id<MTLCommandBuffer> m_CommandBuffer;
		id<MTLRenderCommandEncoder> m_CurrentEncoder;
		id<MTLRenderPipelineState> m_CurrentPipeline;
		vector_uint2 m_ViewportSize;
		id<MTLBuffer> m_VertexBuffer;
		id<MTLBuffer> m_IndexBuffer;
		
		bool m_FrameStarted;
		bool is_default=true;
		//imgui source
	private:
		bool m_ImGuiEnabled=false;
	};
}

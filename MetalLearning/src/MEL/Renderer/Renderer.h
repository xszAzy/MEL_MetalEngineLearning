#pragma once
#include "MEL.h"
#include "Shader/Shader.h"
#include "Log.h"
namespace MEL {
	class VertexArray;
	class Renderer{
	public:
		Renderer(MTKView* mtkview);
		~Renderer();
		
		void BeginFrame();
		void BeginScene();
		void EndScene();
		void EndFrame();
		
		void DrawIndexed(const std::shared_ptr<VertexArray>& vertexArray);
		
		void SetCurrentPipelineState(id<MTLRenderPipelineState> pipelineState);
		
		void OnResize(uint32_t width,uint32_t height);
		
	public:
		void SetImGuiEnabled(bool enabled){m_ImGuiEnabled=enabled;};
		bool IsImGuiEnabled(){return m_ImGuiEnabled;}
		
		void BeginImGui();
		void EndImGui();
	public:
		MTKView* GetMTKView(){return m_View;}
		id<MTLDevice> GetMetalDevice(){return m_Device;}
		id<MTLRenderCommandEncoder> GetCurrentEncoder(){return m_CurrentEncoder;}
		void UpdateViewport();
	private:
		MTKView* m_View;
		
		id<MTLDevice> m_Device;
		id<MTLCommandQueue> m_CommandQueue;
		id<MTLCommandBuffer> m_CommandBuffer;
		id<MTLRenderCommandEncoder> m_CurrentEncoder;
		id<MTLRenderPipelineState> m_CurrentPipeline=nil;
		vector_uint2 m_ViewportSize;
		
		
		bool is_default=true;
		
		MTLViewport m_MTLViewportSize;
	private:
		bool m_ImGuiEnabled=false;
	};
}

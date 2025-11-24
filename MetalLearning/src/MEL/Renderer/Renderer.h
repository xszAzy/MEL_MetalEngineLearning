#pragma once
#include "MEL.h"
#include "Shader.h"

namespace MEL {
	class VertexArray;
	class UniformBuffer;
	class Camera;
	class Renderer{
	public:
		//basic render
		Renderer(MTKView* mtkview);
		~Renderer();
		
		void BeginFrame();
		void BeginScene();
		void EndScene();
		void EndFrame();
		
		void DrawIndexed(const Ref<VertexArray>& vertexArray);
		
		void SetCurrentPipelineState(id<MTLRenderPipelineState> pipelineState);
		
		void OnResize(uint32_t width,uint32_t height);
		
	public:
		//imgui render
		void SetImGuiEnabled(bool enabled){m_ImGuiEnabled=enabled;};
		bool IsImGuiEnabled(){return m_ImGuiEnabled;}
		
		void BeginImGui();
		void EndImGui();
	public:
		//camera set
		void SetSceneCamera(const Ref<Camera>& camera);
		Ref<Camera> GetSceneCamera()const {return m_SceneCamera;}
		
		Ref<UniformBuffer> GetCameraUniform()const{return m_CameraUniform;}
		
		void UpdateCameraUniform();
	public:
		//basic source method
		MTKView* GetMTKView(){return m_View;}
		id<MTLDevice> GetMetalDevice(){return m_Device;}
		id<MTLRenderCommandEncoder> GetCurrentEncoder(){return m_CurrentEncoder;}
		void UpdateViewport();
		void SetDepthStencilState(id<MTLDepthStencilState> depthStencil){m_DepthStencilState=depthStencil;}
	public:
		ShaderLibrary& GetShaderLibrary(){return m_ShaderLibrary;}
	private:
		MTKView* m_View;
		
		id<MTLDevice> m_Device;
		id<MTLCommandQueue> m_CommandQueue;
		id<MTLCommandBuffer> m_CommandBuffer;
		id<MTLRenderCommandEncoder> m_CurrentEncoder;
		id<MTLRenderPipelineState> m_CurrentPipeline=nil;
		id<MTLDepthStencilState> m_DepthStencilState;
		vector_uint2 m_ViewportSize;
		
		bool is_default=true;
		
		MTLViewport m_MTLViewportSize;
		ShaderLibrary m_ShaderLibrary;
	private:
		bool m_ImGuiEnabled=false;
	private:
		Ref<Camera> m_SceneCamera;
		Ref<UniformBuffer> m_TransformUniform;
		Ref<UniformBuffer> m_CameraUniform;
		
		struct CameraData{
			simd::float4x4 viewProjectionMatrix;
			simd::float3 cameraPosition;
			float padding;
		};
	};
	struct TransformData{
		simd::float4x4 modelMatrix;
		simd::float4 color;
	};
}

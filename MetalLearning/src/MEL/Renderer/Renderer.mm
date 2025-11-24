#include "Renderer.h"
#import "imgui.h"
#import "imgui_impl_metal.h"
#import "imgui_impl_osx.h"

#include "VertexArray/VertexArray.h"
#import "Buffer/VertexBuffer.h"
#import "Buffer/IndexBuffer.h"
#include "Buffer/UniformBuffer.h"

namespace MEL{
	Renderer::Renderer(MTKView* mtkview):
	m_View(mtkview),
	m_Device([mtkview device]),
	m_CurrentPipeline(nullptr),
	m_CommandBuffer(nullptr),
	m_CurrentEncoder(nullptr)
	{
		m_CommandQueue=[m_Device newCommandQueue];
		m_ViewportSize={
			(uint32_t)m_View.frame.size.width,
			(uint32_t)m_View.frame.size.height
		};
	}
	
	Renderer::~Renderer(){
		if(m_CurrentPipeline)
			[m_CurrentPipeline release];
	}
	
	void Renderer::BeginFrame(){
		//debug mode
		//MEL_CORE_INFO("====Begin Frame====");
		
		if(!m_Device){
			//MEL_CORE_ERROR("NO DEVICE");
			return;
		}
		if(!m_CommandQueue){
			//MEL_CORE_ERROR("No Command queue");
			return;
		}
		//set viewport in this frame
		UpdateViewport();
		m_CommandBuffer=[m_CommandQueue commandBuffer];
		//MEL_CORE_INFO("Creates commandbuffer:{}",(void*)m_CommandBuffer);
	}
	
	void Renderer::BeginScene(){
		//debug mode
		//MEL_CORE_INFO("----Begin Scene----");

		//get render pass descriptor
		MTLRenderPassDescriptor* renderPassDescriptor=m_View.currentRenderPassDescriptor;
		
		//MEL_CORE_INFO("Descriptor{}",(void*)renderPassDescriptor);
		
		if(renderPassDescriptor==nil){
			NSLog(@"No renderpass");
			[m_CommandBuffer commit];
			return;
		}
		//clear depthstencil
		renderPassDescriptor.depthAttachment.loadAction=MTLLoadActionClear;
		renderPassDescriptor.depthAttachment.clearDepth=1.0;
		//create encoder for current scene
		m_CurrentEncoder=[m_CommandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
		
		//MEL_CORE_INFO("encoder{}",(void*)m_CurrentEncoder);
		
		//set viewport and pipeline state
		
		[m_CurrentEncoder setViewport:m_MTLViewportSize];
		
		//MEL_CORE_INFO("encoder viewport{}x{}",m_MTLViewportSize.width,m_MTLViewportSize.height);
		
		if(m_CurrentPipeline){
			[m_CurrentEncoder setRenderPipelineState:m_CurrentPipeline];
			//MEL_CORE_INFO("encoder pipeline set");
		}
		if(m_DepthStencilState){
			[m_CurrentEncoder setDepthStencilState:m_DepthStencilState];
		}
	}
	
	void Renderer::EndScene(){
		[m_CurrentEncoder endEncoding];
		//m_CurrentEncoder=nullptr;
		//MEL_CORE_INFO("----End Scene----");
	}
	
	void Renderer::EndFrame(){
		if(m_CommandBuffer){
			[m_CommandBuffer presentDrawable:[m_View currentDrawable]];
			//MEL_CORE_INFO("commandbuffer drawable{}",(void*)[m_View currentDrawable]);
			[m_CommandBuffer commit];
			//MEL_CORE_INFO("====End Frame====");
		}
	}
	
	void Renderer::DrawIndexed(const Ref<VertexArray>& vertexArray){
		if(!vertexArray){
			MEL_CORE_ERROR("No array");
			return;
		}
		if(!m_CurrentEncoder){
			MEL_CORE_ERROR("No encoder");
			return;
		}
		vertexArray->Bind();
		
		auto indexBuffer=vertexArray->GetIndexBuffer();
		if(indexBuffer&&indexBuffer->GetBuffer()){
			[m_CurrentEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
										 indexCount:indexBuffer->GetCount()
										  indexType:MTLIndexTypeUInt32
										indexBuffer:indexBuffer->GetBuffer()
								  indexBufferOffset:0];
		}
		else{
			auto vertexBuffers=vertexArray->GetVertexBuffers();
			if(!vertexBuffers.empty()&&vertexBuffers[0]){
				uint32_t vertexCount=vertexBuffers[0]->GetSize()/sizeof(float)/3;
				[m_CurrentEncoder drawPrimitives:MTLPrimitiveTypeTriangle
									 vertexStart:0
									 vertexCount:vertexCount];
			}
		}
	}
	
#pragma mark - Pipeline settings
	void Renderer::SetCurrentPipelineState(id<MTLRenderPipelineState> pipelineState){
		if(m_CurrentPipeline==pipelineState)return;
		
		if(m_CurrentPipeline){
			[m_CurrentPipeline release];
			//MEL_CORE_INFO("release pipeline to create new");
		}
		
		m_CurrentPipeline=[pipelineState retain];
		//MEL_CORE_INFO("Pipeline retain{}",(void*)m_CurrentPipeline);
		
		if(m_CurrentEncoder&&m_CurrentPipeline){
			[m_CurrentEncoder setRenderPipelineState:m_CurrentPipeline];
			//MEL_CORE_INFO("encoder set pipeline");
		}
	}
	
	void Renderer::OnResize(uint32_t width, uint32_t height){
		m_ViewportSize={width,height};
	}
	
#pragma mark - ImGui Controll
	void Renderer::BeginImGui(){
		ImGuiIO& io=ImGui::GetIO();
		io.DisplaySize=ImVec2(m_ViewportSize.x,m_ViewportSize.y);
		//MEL_CORE_INFO("Set ImGui display size{},{}",io.DisplaySize.x,io.DisplaySize.y);
		
		MTLRenderPassDescriptor* renderPassDescriptor=m_View.currentRenderPassDescriptor;
		if(!renderPassDescriptor){
			NSLog(@"no render pass descriptor");
			return;
		}
		
		ImGui_ImplMetal_NewFrame(renderPassDescriptor);
		ImGui_ImplOSX_NewFrame(m_View);
		ImGui::NewFrame();
		//MEL_CORE_INFO("ImGui new frame with pipe desc{}",(void*)renderPassDescriptor);
	}
	
	void Renderer::EndImGui(){
		if(!m_CommandBuffer||!m_CurrentEncoder){
			NSLog(@"No buffer or encoder,call begin scene first!");
			return;
		}
		ImGui::Render();
		ImDrawData* drawData=ImGui::GetDrawData();
		
		ImGui_ImplMetal_RenderDrawData(drawData, m_CommandBuffer, m_CurrentEncoder);
		
		if(ImGui::GetIO().ConfigFlags&ImGuiConfigFlags_ViewportsEnable){
			ImGui::UpdatePlatformWindows();
			ImGui::RenderPlatformWindowsDefault();
		}
		//MEL_CORE_INFO("ImGui draw with data{}",(void*)drawData);
	}

#pragma mark - Test methods
	void Renderer::UpdateViewport(){
		m_ViewportSize={
			(uint32_t)m_View.currentRenderPassDescriptor.colorAttachments[0].texture.width,
			(uint32_t)m_View.currentRenderPassDescriptor.colorAttachments[0].texture.height
		};
		m_MTLViewportSize={
			0,0,
			(double)m_ViewportSize.x,
			(double)m_ViewportSize.y,
			1,0
		};
	}
#pragma mark - Camera settings
	void Renderer::SetSceneCamera(const Ref<Camera>& camera){
		m_SceneCamera=camera;
		
		if(!m_CameraUniform){
			m_CameraUniform=UniformBuffer::Create(sizeof(CameraData));
			m_CameraUniform->SetBindSlot(1);
		}
	}
	
	void Renderer::UpdateCameraUniform(){
		if(m_SceneCamera&&m_CameraUniform){
			CameraData cameraData;
			cameraData.viewProjectionMatrix=m_SceneCamera->GetViewProjectionMatrix();
			cameraData.cameraPosition=m_SceneCamera->GetPosition();
			
			m_CameraUniform->SetData(cameraData);
		}
	}
}

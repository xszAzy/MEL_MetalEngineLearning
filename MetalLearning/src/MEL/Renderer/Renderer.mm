#include "Renderer.h"
#import "imgui.h"
#import "imgui_impl_metal.h"
#import "imgui_impl_osx.h"

namespace MEL{
	Renderer::Renderer(MTKView* mtkview):
	m_View(mtkview),
	m_Device([mtkview device]),
	m_CurrentPipeline(nullptr),
	m_VertexBuffer(nil),
	m_IndexBuffer(nil),
	m_CommandBuffer(nullptr),
	m_CurrentEncoder(nullptr)
	{
		m_CommandQueue=[m_Device newCommandQueue];
		m_ViewportSize={
			(uint32_t)m_View.frame.size.width,
			(uint32_t)m_View.frame.size.height
		};
		MEL_CORE_INFO("Viewport size:{0} x {1}",(int)m_ViewportSize.x,(int)m_ViewportSize.y);
		//SetupPipeline();
	}
	
	Renderer::~Renderer(){
		if(m_CurrentPipeline)
			[m_CurrentPipeline release];
	}
	
	void Renderer::BeginFrame(){
		m_CommandBuffer=[m_CommandQueue commandBuffer];
		//set viewport in this frame
		m_ViewportSize={
			(uint32_t)m_View.drawableSize.width,
			(uint32_t)m_View.drawableSize.height
		};
		m_FrameStarted=true;
	}
	
	void Renderer::BeginScene(){
		if(!m_FrameStarted){
			NSLog(@"Call BeginFrame() first");
			return;
		}
		//create render pass descriptor
		MTLRenderPassDescriptor* renderPassDescriptor=m_View.currentRenderPassDescriptor;
		if(renderPassDescriptor==nil){
			NSLog(@"No renderpass");
			[m_CommandBuffer commit];
			return;
		}
		//create encoder for current scene
		m_CurrentEncoder=[m_CommandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
		//set viewport and pipeline state
		MTLViewport viewport={0,0,(double)m_ViewportSize.x,(double)m_ViewportSize.y,0,1};
		[m_CurrentEncoder setViewport:viewport];
		
		if(m_CurrentPipeline){
			[m_CurrentEncoder setRenderPipelineState:m_CurrentPipeline];
		}
	}
	
	void Renderer::EndScene(){
		[m_CurrentEncoder endEncoding];
		m_CurrentEncoder=nullptr;
	}
	
	void Renderer::EndFrame(){
		if(!m_FrameStarted)return;
		if(m_CommandBuffer){
			[m_CommandBuffer presentDrawable:[m_View currentDrawable]];
			[m_CommandBuffer commit];
		}
		m_CommandBuffer=nullptr;
		m_CurrentEncoder=nullptr;
		m_FrameStarted=false;
	}
	
	void Renderer::DrawIndexed(uint32_t indexcount){
		if(m_CurrentPipeline)
			[m_CurrentEncoder setRenderPipelineState:m_CurrentPipeline];
		
		if(m_VertexBuffer)
			[m_CurrentEncoder setVertexBuffer:m_VertexBuffer offset:0 atIndex:0];
		bool using_auto_draw=true;
		if(!using_auto_draw){
			[m_CurrentEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
										 indexCount:indexcount
										  indexType:MTLIndexTypeUInt32
										indexBuffer:m_IndexBuffer
								  indexBufferOffset:0];
		}
		else{
			[m_CurrentEncoder drawPrimitives:MTLPrimitiveTypeTriangle
								 vertexStart:0
								 vertexCount:indexcount];
		}
	}
	
	void Renderer::CreatePipelineState(){
		id<MTLLibrary> defaultLibrary=[m_Device newDefaultLibrary];
		
		NSError* error=nil;
		
		if(!defaultLibrary){
			NSLog(@"Failed to load Metal library: %@",error);
		}
		error=nil;
		
		id<MTLFunction> vertexFunction=[defaultLibrary newFunctionWithName:@"vertexShader"];
		id<MTLFunction> fragmentFunction=[defaultLibrary newFunctionWithName:@"fragmentShader"];
		
		if(!vertexFunction || !fragmentFunction){
			NSLog(@"Note:Custom shaders not found,only ImGui rendering will be available!");
			return;
		}
		
		MTLRenderPipelineDescriptor* pipeLineDescriptor=[[MTLRenderPipelineDescriptor alloc] init];
		
		pipeLineDescriptor.vertexFunction=vertexFunction;
		pipeLineDescriptor.fragmentFunction=fragmentFunction;
		
		pipeLineDescriptor.colorAttachments[0].pixelFormat=MTLPixelFormatBGRA8Unorm;
		
		m_CurrentPipeline=[m_Device newRenderPipelineStateWithDescriptor:pipeLineDescriptor
																   error:&error];
		
		if(!m_CurrentPipeline){
			NSLog(@"create pipeline state failed:%@",error);
		}
	}
	
	void Renderer::OnResize(uint32_t width, uint32_t height){
		m_ViewportSize={width,height};
	}
	
	void Renderer::SetupPipeline(){
		CreatePipelineState();
	}
	
#pragma mark - ImGui Controll
	void Renderer::BeginImGui(){
		MTLRenderPassDescriptor* renderPassDescriptor=m_View.currentRenderPassDescriptor;
		if(!renderPassDescriptor){
			NSLog(@"no render pass descriptor");
			return;
		}
		ImGui_ImplMetal_NewFrame(renderPassDescriptor);
		ImGui_ImplOSX_NewFrame(m_View);
		ImGui::NewFrame();
	}
	
	void Renderer::EndImGui(){
		if(!m_CommandBuffer||!m_CurrentEncoder){
			NSLog(@"No buffer or encoder,call begin scene first!");
			return;
		}
		ImGui::Render();
		ImDrawData* drawData=ImGui::GetDrawData();
		
		ImGui_ImplMetal_RenderDrawData(drawData, m_CommandBuffer, m_CurrentEncoder);
		MTLViewport viewport={0,0,(double)m_ViewportSize.x,(double)m_ViewportSize.y,0,1};
		[m_CurrentEncoder setViewport:viewport];
	}
#pragma mark - Buffer sets
	void Renderer::SetVertexBuffer(void *data, size_t size){
		is_default=false;
		m_VertexBuffer=[m_Device newBufferWithBytes:data
											 length:size
											options:MTLResourceStorageModeShared];
	}
	
	void Renderer::SetIndexBuffer(uint32_t *indices, uint32_t count){
		is_default=false;
		m_IndexBuffer=[m_Device newBufferWithBytes:indices
											length:count*sizeof(uint32_t)
										   options:MTLResourceStorageModeShared];
	}
}

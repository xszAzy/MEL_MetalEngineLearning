#include "VertexBuffer.h"
#include "Application.h"
namespace MEL{
	/////////////VertexBuffer////////////////////
	std::shared_ptr<VertexBuffer> VertexBuffer::Create(void *data, uint32_t size,BufferUsage usage){
		return std::make_shared<VertexBuffer>(data,size,usage);
	}
	
	std::shared_ptr<VertexBuffer> VertexBuffer::Create(uint32_t size){
		return std::make_shared<VertexBuffer>(nullptr,size,BufferUsage::Dynamic);
	}
	
	VertexBuffer::VertexBuffer(void* data,uint32_t size,BufferUsage usage)
	:Buffer(BufferType::Vertex, usage){
		auto renderer=Application::Get().GetRenderer();
		id<MTLDevice> device=renderer->GetMetalDevice();
		
		MTLResourceOptions options=MTLResourceStorageModeShared;
		
		if(data){
			m_MetalBuffer=[device newBufferWithBytes:data
											  length:size
											 options:options];
		}
		else{
			m_MetalBuffer=[device newBufferWithLength:size
											  options:options];
		}
		
		if(m_MetalBuffer){
			[m_MetalBuffer retain];
			MEL_CORE_INFO("Created VertexBuffer:{} bytes",size);
		}
		else{
			MEL_CORE_ERROR("Failed to create VertexBuffer:{} bytes",size);
		}
	}
	
	void VertexBuffer::Bind(){
		auto renderer=Application::Get().GetRenderer();
		id<MTLRenderCommandEncoder> encoder=renderer->GetCurrentEncoder();
		
		if(encoder&&m_MetalBuffer){
			[encoder setVertexBuffer:m_MetalBuffer
							  offset:0
							 atIndex:m_Slot];
		}
	}
	
	void VertexBuffer::SetData(void *data, uint32_t size){
		if(!m_MetalBuffer)return;
		
		if(size>m_Size){
			MEL_CORE_WARN("VertexBuffer::SetData: size{} exceeds buffer capacity{}",size,m_Size);
			return;
		}
		
		void* BufferContents=[m_MetalBuffer contents];
		if(BufferContents&&data){
			memcpy(BufferContents, data, size);
		}
	}
}

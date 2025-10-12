#include "UniformBuffer.h"
#include"Application.h"

namespace MEL{
	std::shared_ptr<UniformBuffer> UniformBuffer::Create(uint32_t size,BufferUsage usage){
		return std::make_shared<UniformBuffer>(size,usage);
	}
	
	UniformBuffer::UniformBuffer(uint32_t size,BufferUsage usage):Buffer(BufferType::Uniform, usage){
		m_Size=size;
		auto renderer=Application::Get().GetRenderer();
		id<MTLDevice> device=renderer->GetMetalDevice();
		
		MTLResourceOptions options=MTLResourceStorageModeShared;
		m_MetalBuffer=[device newBufferWithLength:size
										  options:options];
		
		if(m_MetalBuffer){
			[m_MetalBuffer retain];
			MEL_CORE_INFO("Created UniformBuffer:{} bytes",size);
		}
	}
	
	void UniformBuffer::Bind(){
		auto renderer=Application::Get().GetRenderer();
		id<MTLRenderCommandEncoder> encoder=renderer->GetCurrentEncoder();
		
		if(encoder&&m_MetalBuffer){
			[encoder setVertexBuffer:m_MetalBuffer
							  offset:0
							 atIndex:m_Slot];
		}
	}
	
	void UniformBuffer::SetData(void *data, uint32_t size){
		if(!m_MetalBuffer)return;
		
		if(size>m_Size){
			MEL_CORE_WARN("UniformBuffer::SetData: size {} exceeds buffer capacity {}",size,m_Size);
			return;
		}
		
		void* bufferContents=[m_MetalBuffer contents];
		if(bufferContents&&data){
			memcpy(bufferContents, data, size);
		}
	}
}

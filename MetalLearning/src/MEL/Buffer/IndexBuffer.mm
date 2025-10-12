#include "IndexBuffer.h"
#include "Application.h"

namespace MEL{
	/////////////IndexBuffer////////////////////
	std::shared_ptr<IndexBuffer> IndexBuffer::Create(uint32_t *indices, uint32_t count){
		return std::make_shared<IndexBuffer>(indices,count);
	}
	
	IndexBuffer::IndexBuffer(uint32_t* indices,uint32_t count)
	:Buffer(BufferType::Index, BufferUsage::Static),m_Count(count){
		m_Size=count*sizeof(uint32_t);
		auto renderer=Application::Get().GetRenderer();
		id<MTLDevice> device=renderer->GetMetalDevice();
		
		MTLResourceOptions options=MTLResourceStorageModeShared;
		m_MetalBuffer=[device newBufferWithBytes:indices
										  length:m_Size
										 options:options];
		if(m_MetalBuffer){
			[m_MetalBuffer retain];
			MEL_CORE_INFO("Created IndexBuffer:{} indices({} bytes)",count,m_Size);
		}
		else{
			MEL_CORE_ERROR("Failed to create IndexBuffer:{} indices",count);
		}
	}
	
	void IndexBuffer::Bind(){}//Index don't need to bind manually
	
	void IndexBuffer::SetData(void *data, uint32_t size){
		if(m_MetalBuffer)return;
		
		if(size>m_Size){
			MEL_CORE_WARN("IndexBuffer::SetData: size{} exceeds buffer capacity{}",size,m_Size);
			return;
		}
		
		void* BufferContents=[m_MetalBuffer contents];
		if(BufferContents&&data){
			memcpy(BufferContents, data, size);
		}
	}
}

#include "VertexArray.h"
#include "Renderer.h"

namespace MEL{
	std::shared_ptr<VertexArray> VertexArray::Create(){
		return std::make_shared<VertexArray>();
	}
	
	VertexArray::VertexArray():m_CurrentSlot(0){
	}
	
	VertexArray::~VertexArray(){
	}
	
	void VertexArray::Bind() const{
		auto renderer=Application::Get().GetRenderer();
		id<MTLRenderCommandEncoder> encoder=renderer->GetCurrentEncoder();
		
		if(!encoder){
			MEL_CORE_WARN("VertexArray::Bind: No active render command encoder");
			return;
		}
		
		m_CurrentSlot=0;
		for(const auto& vertexBuffer:m_VertexBuffers){
			if(vertexBuffer&&vertexBuffer->GetBuffer()){
				[encoder setVertexBuffer:vertexBuffer->GetBuffer()
								  offset:0
								 atIndex:m_CurrentSlot];
				m_CurrentSlot++;
			}
		}
		
	}
	
	void VertexArray::Unbind()const{
	}
	
	void VertexArray::AddVertexBuffer(const std::shared_ptr<VertexBuffer> &vertexBuffer){
		if(vertexBuffer){
			m_VertexBuffers.push_back(vertexBuffer);
			MEL_CORE_INFO("VertexArray:Added vertex buffer at slot {}",m_VertexBuffers.size()-1);
		}
	}
	
	void VertexArray::SetIndexBuffer(const std::shared_ptr<IndexBuffer> &indexBuffer){
		m_IndexBuffer=indexBuffer;
		if(indexBuffer){
			MEL_CORE_INFO("VertexArray: Set index buffer with {} indices",indexBuffer->GetCount());
		}
	}
}

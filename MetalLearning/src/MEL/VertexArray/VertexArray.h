#pragma once
#include "Buffer/VertexBuffer.h"
#include "Buffer/IndexBuffer.h"

namespace MEL{
	class VertexArray{
	public:
		static std::shared_ptr<VertexArray> Create();
		
		VertexArray();
		~VertexArray();
		
		void Bind()const;
		void Unbind()const;
		
		void AddVertexBuffer(const std::shared_ptr<VertexBuffer>& vertexBuffer);
		void SetIndexBuffer(const std::shared_ptr<IndexBuffer>& indexBuffer);
		
		const std::vector<std::shared_ptr<VertexBuffer>>& GetVertexBuffers() const{return m_VertexBuffers;}
		const std::shared_ptr<IndexBuffer>& GetIndexBuffer()const {return m_IndexBuffer;}
		
		uint32_t GetIndexCount()const {return m_IndexBuffer?m_IndexBuffer->GetCount():0;}
		
	private:
		std::vector<std::shared_ptr<VertexBuffer>> m_VertexBuffers;
		std::shared_ptr<IndexBuffer> m_IndexBuffer;
		mutable uint32_t m_CurrentSlot;
	};
}

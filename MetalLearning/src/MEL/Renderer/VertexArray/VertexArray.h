#pragma once
#include "Buffer/VertexBuffer.h"
#include "Buffer/IndexBuffer.h"

namespace MEL{
	class VertexArray{
	public:
		static Ref<VertexArray> Create();
		
		VertexArray();
		~VertexArray();
		
		void Bind()const;
		void Unbind()const;
		
		void AddVertexBuffer(const Ref<VertexBuffer>& vertexBuffer);
		void SetIndexBuffer(const Ref<IndexBuffer>& indexBuffer);
		
		const std::vector<Ref<VertexBuffer>>& GetVertexBuffers() const{return m_VertexBuffers;}
		const Ref<IndexBuffer>& GetIndexBuffer()const {return m_IndexBuffer;}
		
		uint32_t GetIndexCount()const {return m_IndexBuffer?m_IndexBuffer->GetCount():0;}
		
	private:
		std::vector<Ref<VertexBuffer>> m_VertexBuffers;
		Ref<IndexBuffer> m_IndexBuffer;
		mutable uint32_t m_CurrentSlot;
	};
}

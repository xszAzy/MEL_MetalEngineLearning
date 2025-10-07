#pragma once
#include<Metal/Metal.h>
#import "Buffer.h"

namespace MEL {
	class  VertexBuffer: public Buffer{
	public:
		static std::shared_ptr<VertexBuffer> Create(void *data, uint32_t size,BufferUsage usage=BufferUsage::Static);
		
		static std::shared_ptr<VertexBuffer> Create(uint32_t size);
		
		VertexBuffer(void* data,uint32_t size,BufferUsage usage);
		void Bind() override;
		void SetData(void *data, uint32_t size) override;
		
		void SetSlot(uint32_t slot){m_Slot=slot;}
		uint32_t GetSlot()const{return m_Slot;}
		
		void SetLayout(const BufferLayout& layout){m_Layout=layout;}
		const BufferLayout& GetLayout()const{return m_Layout;}
	private:
		uint32_t m_Slot=0;
		BufferLayout m_Layout;
	};
}

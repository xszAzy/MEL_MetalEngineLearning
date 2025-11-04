#pragma once
#include<Metal/Metal.h>
#import "Buffer.h"

namespace MEL {
	class  IndexBuffer: public Buffer{
	public:
		static Ref<IndexBuffer> Create(uint32_t* indices,uint32_t count);
		
		IndexBuffer(uint32_t* indices,uint32_t count);
		~IndexBuffer(){};
		
		void Bind() override;
		void SetData(void* data,uint32_t size)override;
		
		uint32_t GetCount()const {return m_Count;}
		MTLIndexType GetIndexType()const {return MTLIndexTypeUInt32;}
		
	private:
		uint32_t m_Count=0;
	};
}

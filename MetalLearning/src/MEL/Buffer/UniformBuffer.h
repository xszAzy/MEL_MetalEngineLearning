#pragma once
#import <Metal/Metal.h>
#include "Buffer.h"
#include "Log.h"

namespace MEL {
	class UniformBuffer:public Buffer{
	public:
		static std::shared_ptr<UniformBuffer> Create(uint32_t size,BufferUsage usage=BufferUsage::Dynamic);
		
		UniformBuffer(uint32_t size,BufferUsage usage);
		
		void Bind() override;
		
		void SetData(void* data,uint32_t size)override;
		template<typename T>
		void SetData(const T& data){
			if(sizeof(T)>m_Size){
				MEL_CORE_ERROR("UniformBuffer::SetData:Data size {} exceeds buffer capacity {}",sizeof(T),m_Size);
				return;
			}
			SetData((void*)& data,sizeof(T));
		}
		
		void SetBindSlot(uint32_t slot){m_Slot=slot;}
		uint32_t GetBindSlot(){return m_Slot;}
	private:
		uint32_t m_Slot=0;
	};
}

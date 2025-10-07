#pragma once
#include<Metal/Metal.h>
#include "Application.h"
#include "BufferLayout.h"

namespace MEL{
	enum class BufferUsage{
		Static,
		Dynamic,
		Stream
	};
	enum class BufferType{
		Vertex,
		Index,
		Uniform
	};
	
	class Buffer{
	public:
		virtual ~Buffer();
		
		virtual void Bind()=0;
		virtual void SetData(void* data,uint32_t size)=0;
		
		id<MTLBuffer> GetBuffer()const{return m_MetalBuffer;}
		BufferType GetType()const{return m_Type;}
		BufferUsage GetUsage()const{return m_Usage;}
		uint32_t GetSize()const{return m_Size;}
	protected:
		Buffer(BufferType type,BufferUsage usage);
		id<MTLBuffer> m_MetalBuffer=nil;
		BufferType m_Type;
		BufferUsage m_Usage;
		uint32_t m_Size=0;
	};
}

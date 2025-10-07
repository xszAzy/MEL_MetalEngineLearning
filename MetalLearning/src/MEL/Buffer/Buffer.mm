#include "Buffer.h"

namespace MEL {
	Buffer::Buffer(BufferType type,BufferUsage usage)
	:m_Type(type),m_Usage(usage){
	}
	Buffer::~Buffer(){
		if(m_MetalBuffer){
			m_MetalBuffer=nil;
		}
	}
}

#pragma once
#include"Log.h"
#import<Metal/Metal.h>
#import<MetalKit/MetalKit.h>

namespace MEL{
	class MetalTexture2D{
	public:
		MetalTexture2D(const std::string path);
		~MetalTexture2D();
		uint32_t GetWidth()const {return m_Width;}
		uint32_t GetHeight()const {return m_Height;}
		void Bind(uint32_t slot=2)const;
		id<MTLTexture> GetMetalTexture()const{return m_Texture;}
	private:
		void LoadWithTextureLoader(NSURL* textureURL);
		std::string m_Path;
		uint32_t m_Width,m_Height;
		id<MTLTexture> m_Texture=nil;
	};
}

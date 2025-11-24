#include "MetalTexture2D.h"
#include "Application.h"
#include "Renderer.h"
namespace MEL {
	MetalTexture2D::MetalTexture2D(const std::string path):m_Path(path){
		NSString* nsPath=[NSString stringWithUTF8String:path.c_str()];
		NSString* name=[nsPath stringByDeletingPathExtension];
		NSString* ext=[nsPath pathExtension];
		NSURL* textureURL=[[NSBundle mainBundle] URLForResource:name
												  withExtension:ext];
		
		LoadWithTextureLoader(textureURL);
	}
	
	void MetalTexture2D::LoadWithTextureLoader(NSURL *textureURL){
		NSError* error=nil;
		auto renderer=Application::Get().GetRenderer();
		id<MTLDevice> device=renderer->GetMetalDevice();
		MTKTextureLoader* textureLoader=[[[MTKTextureLoader alloc]initWithDevice:device] autorelease];
		
		NSDictionary* options=@{
			MTKTextureLoaderOptionTextureUsage:
			@(MTLTextureUsageShaderRead),
			MTKTextureLoaderOptionTextureStorageMode:
			@(MTLStorageModePrivate),
			MTKTextureLoaderOptionSRGB:@(YES)
		};
		
		m_Texture=[textureLoader newTextureWithContentsOfURL:textureURL
													 options:options
													   error:&error];
		if(error){
			NSLog(@"Texture loading error:%@",error);
			
			uint32_t whitePixel=0xFFFFFFFF;
			MTLTextureDescriptor* textureDescriptor=[MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
																									   width:1
																									  height:1
																								   mipmapped:NO];
			m_Texture=[device newTextureWithDescriptor:textureDescriptor];
			
			MTLRegion region={{0,0,0},{1,1,1}};
			[m_Texture replaceRegion:region
						 mipmapLevel:0
						   withBytes:&whitePixel
						 bytesPerRow:4];
			
			m_Width=1;
			m_Height=1;
		}
		else{
			m_Width=static_cast<uint32_t>(m_Texture.width);
			m_Height=static_cast<uint32_t>(m_Texture.height);
			MEL_CORE_INFO("Load texture:",m_Path,",(width:{},height:{})",m_Width,m_Height);
		}
	}
	MetalTexture2D::~MetalTexture2D(){
		if(m_Texture){
			[m_Texture release];
			m_Texture=nil;
		}
	}
	
	void MetalTexture2D::Bind(uint32_t slot)const{
		auto renderer=Application::Get().GetRenderer();
		id<MTLRenderCommandEncoder> encoder=renderer->GetCurrentEncoder();
		
		if(encoder&&m_Texture){
			[encoder setFragmentTexture:m_Texture
								atIndex:0];
		}
	}
}

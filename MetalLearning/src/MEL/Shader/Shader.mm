#include "Shader.h"

namespace MEL{
	Shader::Shader(const std::string& name):m_Name(name){
	}
	std::shared_ptr<Shader> Shader::CreateFromSource(const std::string& name, const std::string &source){
		auto shader=std::make_shared<Shader>(name);
		if(shader->LoadFromSource(source))
			return shader;
		return nullptr;
	}
	std::shared_ptr<Shader> Shader::CreateFromLibrary(const std::string& name,const std::string& librarypath){
		auto shader=std::make_shared<Shader>(name);
		if(shader->LoadFromLibrary(librarypath))
			return shader;
		return nullptr;
	}
	
	bool Shader::LoadFromSource(const std::string &source){
		auto renderer=Application::Get().GetRenderer();
		id<MTLDevice> device=renderer->GetMetalDevice();
		
		NSError* error=nil;
		NSString* sourceData=[NSString stringWithUTF8String:source.c_str()];
		id<MTLLibrary> library=[device newLibraryWithSource:sourceData
													options:nil
													  error:&error];
		
		if(!library){
			MEL_CORE_ERROR("Failed to compile shader {}:{}",m_Name,[[error localizedDescription] UTF8String]);
			return false;
		}
		
		m_VertexFunction=[library newFunctionWithName:@"vertexShader"];
		m_FragmentFunction=[library newFunctionWithName:@"fragmentShader"];
		
		if(!m_VertexFunction||!m_FragmentFunction){
			MEL_CORE_ERROR("No vertex or fragment function:{}",m_Name);
			return false;
		}
		[library retain];
		MEL_CORE_INFO("Shader from source:{}",m_Name);
		return true;
	}
	
	
	
	Shader::~Shader(){
		//maybe auto release
	}
	
	
}

#include "Shader.h"
#include "Application.h"

namespace MEL{
	Shader::Shader(const std::string& name):m_Name(name){
	}
	std::shared_ptr<Shader> Shader::CreateFromSource(const std::string& name, const std::string &source,
													 NSString* vertexFuncName,NSString* fragmentFuncName){
		auto shader=std::make_shared<Shader>(name);
		if(shader->LoadFromSource(source,vertexFuncName,fragmentFuncName))
			return shader;
		return nullptr;
	}
	std::shared_ptr<Shader> Shader::CreateFromLibrary(const std::string& name,const std::string& librarypath,
													  NSString* vertexFuncName,NSString* fragmentFuncName){
		auto shader=std::make_shared<Shader>(name);
		if(shader->LoadFromLibrary(librarypath,vertexFuncName,fragmentFuncName))
			return shader;
		return nullptr;
	}
	std::shared_ptr<Shader> Shader::CreateFromDefaultLibrary(const std::string& name,
															 NSString* vertexFuncName,NSString* fragmentFuncName){
		auto shader=std::make_shared<Shader>(name);
		if(shader->LoadFromDefaultLibrary(vertexFuncName,fragmentFuncName))
			return shader;
		return nullptr;
	}
	
	bool Shader::LoadFromSource(const std::string &source,
								NSString* vertexFuncName,NSString* fragmentFuncName){
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
		
		m_VertexFunction=[library newFunctionWithName:vertexFuncName];
		m_FragmentFunction=[library newFunctionWithName:fragmentFuncName];
		
		if(!m_VertexFunction||!m_FragmentFunction){
			MEL_CORE_ERROR("No vertex or fragment function:{}",m_Name);
			return false;
		}
		m_Library=library;
		MEL_CORE_INFO("Shader from source:{}",m_Name);
		return true;
	}
	
	bool Shader::LoadFromLibrary(const std::string &librarypath,
								 NSString* vertexFuncName,NSString* fragmentFuncName){
		auto renderer=Application::Get().GetRenderer();
		id<MTLDevice> device=renderer->GetMetalDevice();
		
		NSError* error=nil;
		NSString* path=[NSString stringWithUTF8String:librarypath.c_str()];
		NSURL* libraryURL=[NSURL fileURLWithPath:path];
		
		id<MTLLibrary> library=[device newLibraryWithURL:libraryURL
												   error:&error];
		if(!library){
			MEL_CORE_ERROR("Failed to load metallib {},{}",librarypath,[[error localizedDescription] UTF8String]);
			return false;
		}
		
		m_VertexFunction=[library newFunctionWithName:vertexFuncName];
		m_FragmentFunction=[library newFunctionWithName:fragmentFuncName];
		
		if(!m_VertexFunction||!m_FragmentFunction){
			MEL_CORE_ERROR("Metallib '{}' missing required functions",librarypath);
			return false;
		}
		
		MEL_CORE_INFO("Load Shader from metlallib:{}",m_Name);
		return true;
	}
	
	bool Shader::LoadFromDefaultLibrary(NSString* vertexFuncName,NSString* fragmentFuncName){
		auto renderer=Application::Get().GetRenderer();
		id<MTLDevice> device=renderer->GetMetalDevice();
		
		id<MTLLibrary>defaultLibrary=[device newDefaultLibrary];
		if(!defaultLibrary){
			MEL_CORE_ERROR("Failed to load default library:{}",m_Name);
			return false;
		}
		
		m_VertexFunction=[defaultLibrary newFunctionWithName:vertexFuncName];
		m_FragmentFunction=[defaultLibrary newFunctionWithName:fragmentFuncName];
		
		if(!m_VertexFunction||!m_FragmentFunction){
			MEL_CORE_ERROR("Default library missing vertex or fragment function,only render imgui");
			return false;
		}
		MEL_CORE_INFO("Load Shader from default library:{}",m_Name);
		return true;
	}
	
	bool Shader::CreatePipelineState(const BufferLayout& layout){
		auto renderer=Application::Get().GetRenderer();
		id<MTLDevice> device=renderer->GetMetalDevice();
		
		if(!m_VertexFunction||!m_FragmentFunction){
			MEL_CORE_WARN("No shader function:{}",m_Name);
			return false;
		}
		
		MTLRenderPipelineDescriptor* pipelineDescriptor=[[MTLRenderPipelineDescriptor alloc]init];
		pipelineDescriptor.vertexFunction=m_VertexFunction;
		pipelineDescriptor.fragmentFunction=m_FragmentFunction;
		pipelineDescriptor.colorAttachments[0].pixelFormat=MTLPixelFormatBGRA8Unorm;
		
		MTLVertexDescriptor* vertexDescriptor=CreateVertexDescriptor(layout);
		pipelineDescriptor.vertexDescriptor=vertexDescriptor;
		
		NSError* error=nil;
		m_PipelineState=[device newRenderPipelineStateWithDescriptor:pipelineDescriptor
															   error:&error];
		//[pipelineDescriptor release];
		if(!m_PipelineState){
			MEL_CORE_ERROR("Failed to create pipeline state for shader:{},{}",m_Name,[[error localizedDescription]UTF8String]);
			return false;
		}
		
		MEL_CORE_INFO("Create pipeline state for shader:{}",m_Name);
		return true;
	}
	
	MTLVertexDescriptor* Shader::CreateVertexDescriptor(const BufferLayout &layout){
		MTLVertexDescriptor* vertexDescriptor=[MTLVertexDescriptor vertexDescriptor];
		
		uint32_t attributeIndex=0;
		uint32_t bufferIndex=0;
		
		for(const auto& element:layout){
			MTLVertexAttributeDescriptor* attribute=vertexDescriptor.attributes[attributeIndex];
			
			attribute.format=ShaderDataTypeToMetal(element.Type);
			attribute.offset=element.Offset;
			attribute.bufferIndex=bufferIndex;
			
			MEL_CORE_INFO("Vertex Attribute[{}]:{} at buffer {},offset {},format {}",
						  attributeIndex,element.Name,bufferIndex,element.Offset,(int)attribute.format);
			attributeIndex++;
		}
		
		MTLVertexBufferLayoutDescriptor* bufferLayout=vertexDescriptor.layouts[bufferIndex];
		bufferLayout.stride=layout.GetStride();
		bufferLayout.stepRate=1;
		bufferLayout.stepFunction=MTLVertexStepFunctionPerVertex;
		
		return vertexDescriptor;
	}
	
	void Shader::Bind(){
		auto renderer=Application::Get().GetRenderer();
		renderer->SetCurrentPipelineState(m_PipelineState);
	}
	
	Shader::~Shader(){
		//maybe auto release
		if(m_VertexFunction)
			[m_VertexFunction release];
		if(m_FragmentFunction)
			[m_FragmentFunction release];
	}
}


#include "Shader.h"
#include "Renderer.h"
#include "Application.h"

namespace MEL{
	Shader::Shader(const std::string& name):m_Name(name){
	}
	Ref<Shader> Shader::CreateFromSource(const std::string& name, const std::string &source,
													 NSString* vertexFuncName,NSString* fragmentFuncName){
		auto shader=std::make_shared<Shader>(name);
		if(shader->LoadFromSource(source,vertexFuncName,fragmentFuncName))
			return shader;
		return nullptr;
	}
	Ref<Shader> Shader::CreateFromLibrary(const std::string& name,const std::string& librarypath,
													  NSString* vertexFuncName,NSString* fragmentFuncName){
		auto shader=std::make_shared<Shader>(name);
		if(shader->LoadFromLibrary(librarypath,vertexFuncName,fragmentFuncName))
			return shader;
		return nullptr;
	}
	Ref<Shader> Shader::CreateFromDefaultLibrary(const std::string& name,
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
		id<MTLLibrary> library=[[device newLibraryWithSource:sourceData
													 options:nil
													   error:&error]
								autorelease];
		
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
		NSString* filePath=[NSString stringWithUTF8String:librarypath.c_str()];
		
		NSString* name=[filePath stringByDeletingPathExtension];
		NSString* ext=[filePath pathExtension];
		NSString* bundlePath=[[NSBundle mainBundle] pathForResource:name
															 ofType:ext];
		NSString* nsPath=[NSString stringWithUTF8String:[bundlePath UTF8String]];
		
		if(![[NSFileManager defaultManager]fileExistsAtPath:nsPath]){
			MEL_CORE_ERROR("Metal file not found,using bundle: {}",librarypath);
			return false;
		}
		
		NSError* error=nil;
		NSString* source=[NSString stringWithContentsOfFile:nsPath
												   encoding:NSUTF8StringEncoding
													  error:&error];
		
		if(error)
			MEL_CORE_ERROR("Failed to read metal file: {}, {}",librarypath,[[error localizedDescription] UTF8String]);
		
		
		return LoadFromSource([source UTF8String], vertexFuncName, fragmentFuncName);
	}
	
	bool Shader::LoadFromDefaultLibrary(NSString* vertexFuncName,NSString* fragmentFuncName){
		auto renderer=Application::Get().GetRenderer();
		id<MTLDevice> device=renderer->GetMetalDevice();
		
		id<MTLLibrary>defaultLibrary=[[device newDefaultLibrary] autorelease];
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
		
		MTLRenderPipelineDescriptor* pipelineDescriptor=[[[MTLRenderPipelineDescriptor alloc]init] autorelease];
		pipelineDescriptor.vertexFunction=m_VertexFunction;
		pipelineDescriptor.fragmentFunction=m_FragmentFunction;
		pipelineDescriptor.colorAttachments[0].pixelFormat=MTLPixelFormatBGRA8Unorm;
		pipelineDescriptor.depthAttachmentPixelFormat=MTLPixelFormatDepth32Float;
		MTLDepthStencilDescriptor* depthStencilDescriptor=[[[MTLDepthStencilDescriptor alloc] init] autorelease];
		SetBlend(m_BlendType, pipelineDescriptor,depthStencilDescriptor);
		
		renderer->SetDepthStencilState([[device newDepthStencilStateWithDescriptor:depthStencilDescriptor] autorelease]);
		
		MTLVertexDescriptor* vertexDescriptor=CreateVertexDescriptor(layout);
		pipelineDescriptor.vertexDescriptor=vertexDescriptor;
		
		NSError* error=nil;
		m_PipelineState=[[device newRenderPipelineStateWithDescriptor:pipelineDescriptor
																error:&error] autorelease];
		
		if(!m_PipelineState){
			MEL_CORE_ERROR("Failed to create pipeline state for shader:{},{}",m_Name,[[error localizedDescription]UTF8String]);
			return false;
		}
		MEL_CORE_INFO("Create pipeline state for shader:{}",m_Name);
		return true;
	}
	
	MTLVertexDescriptor* Shader::CreateVertexDescriptor(const BufferLayout &layout){
		MTLVertexDescriptor* vertexDescriptor=[[MTLVertexDescriptor vertexDescriptor] autorelease];
		
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
		
		MTLVertexBufferLayoutDescriptor* bufferLayout=[vertexDescriptor.layouts[bufferIndex] autorelease];
		bufferLayout.stride=layout.GetStride();
		bufferLayout.stepRate=1;
		bufferLayout.stepFunction=MTLVertexStepFunctionPerVertex;
		
		return vertexDescriptor;
	}
	
	void Shader::SetOpaqueBlend(MTLRenderPipelineDescriptor *pipelinedesc,MTLDepthStencilDescriptor* depthStencilDescriptor){
		pipelinedesc.colorAttachments[0].blendingEnabled=NO;
		//depth
		depthStencilDescriptor.depthCompareFunction=MTLCompareFunctionLess;
		depthStencilDescriptor.depthWriteEnabled=YES;
	}
	
	void Shader::SetAlphaBlend(MTLRenderPipelineDescriptor *pipelinedesc,MTLDepthStencilDescriptor* depthStencilDescriptor){
		pipelinedesc.colorAttachments[0].blendingEnabled=YES;
		//rgbblend
		pipelinedesc.colorAttachments[0].sourceRGBBlendFactor=MTLBlendFactorSourceAlpha;
		pipelinedesc.colorAttachments[0].destinationRGBBlendFactor=MTLBlendFactorOneMinusSourceAlpha;
		pipelinedesc.colorAttachments[0].rgbBlendOperation=MTLBlendOperationAdd;
		//alphablend
		pipelinedesc.colorAttachments[0].sourceAlphaBlendFactor=MTLBlendFactorOne;
		pipelinedesc.colorAttachments[0].destinationAlphaBlendFactor=MTLBlendFactorOneMinusSourceAlpha;
		pipelinedesc.colorAttachments[0].alphaBlendOperation=MTLBlendOperationAdd;
		//depth
		depthStencilDescriptor.depthCompareFunction=MTLCompareFunctionLess;
		depthStencilDescriptor.depthWriteEnabled=NO;
	}
	
	void Shader::SetAddictiveBlend(MTLRenderPipelineDescriptor *pipelinedesc,MTLDepthStencilDescriptor* depthStencilDescriptor){
		pipelinedesc.colorAttachments[0].blendingEnabled=YES;
		//rgb
		pipelinedesc.colorAttachments[0].sourceRGBBlendFactor=MTLBlendFactorOne;
		pipelinedesc.colorAttachments[0].destinationRGBBlendFactor=MTLBlendFactorOne;
		pipelinedesc.colorAttachments[0].rgbBlendOperation=MTLBlendOperationAdd;
		//alpha
		pipelinedesc.colorAttachments[0].sourceAlphaBlendFactor=MTLBlendFactorOne;
		pipelinedesc.colorAttachments[0].destinationAlphaBlendFactor=MTLBlendFactorOne;
		pipelinedesc.colorAttachments[0].alphaBlendOperation=MTLBlendOperationAdd;
		//depth
		depthStencilDescriptor.depthCompareFunction=MTLCompareFunctionAlways;
		depthStencilDescriptor.depthWriteEnabled=NO;
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
#pragma mark - ShaderLibrary
	void ShaderLibrary::Add(const std::string &name, const std::shared_ptr<Shader> &shader){
		if(Exists(name)){
			MEL_CORE_WARN("Shader '{}' already exists,replacing with new one",name);
		}
		m_Shaders[name]=shader;
	}
	
	std::shared_ptr<Shader> ShaderLibrary::LoadFromFile(const std::string &name, const std::string &filepath,
														NSString *vertexFuncName, NSString *fragmentFuncName,
														const BufferLayout& layout,BlendType blendType){
		auto shader=Shader::CreateFromLibrary(name, filepath, vertexFuncName, fragmentFuncName);
		shader->SetBlendType(blendType);
		if(shader){
			shader->CreatePipelineState(layout);
			Add(name,shader);
		}
		else{
			shader=Shader::CreateFromDefaultLibrary(name, vertexFuncName, fragmentFuncName);
			shader->CreatePipelineState(layout);
			Add(name,shader);
		}
		return shader;
	}
	
	std::shared_ptr<Shader> ShaderLibrary::LoadFromSource(const std::string &name, const std::string &source,
														  NSString *vertexFuncName, NSString *fragmentFuncName,
														  const BufferLayout& layout,BlendType blendType){
		auto shader=Shader::CreateFromSource(name, source, vertexFuncName, fragmentFuncName);
		shader->SetBlendType(blendType);
		if(shader){
			shader->CreatePipelineState(layout);
			Add(name,shader);
		}
		else{
			shader=Shader::CreateFromDefaultLibrary(name, vertexFuncName, fragmentFuncName);
			shader->CreatePipelineState(layout);
			Add(name,shader);
		}
		return shader;
	}
	
	bool ShaderLibrary::Exists(const std::string &name)const {
		return m_Shaders.find(name)!=m_Shaders.end();
	}
	
	std::shared_ptr<Shader> ShaderLibrary::Get(const std::string &name){
		auto it =m_Shaders.find(name);
		if(it!=m_Shaders.end()){
			return it->second;
		}
		MEL_CORE_ERROR("Shader '{}' not found in library",name);
		return nullptr;
	}
}


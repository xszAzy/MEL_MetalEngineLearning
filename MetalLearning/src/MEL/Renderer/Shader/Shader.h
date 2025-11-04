#pragma once

#include<string>
#include<unordered_map>
#include"Buffer/BufferLayout.h"
#include"Core.h"

namespace MEL{
	enum class BlendType{
		Opaque=0,
		Alpha,
		Addictive
	};
	class Shader{
	public:
		Shader(const std::string& name);
		~Shader();
		
		static Ref<Shader>CreateFromSource(const std::string& name,const std::string& source,
													   NSString* vertexFuncName,NSString* fragmentFuncName);
		static Ref<Shader>CreateFromLibrary(const std::string& name,const std::string& librarypath,
														NSString* vertexFuncName,NSString* fragmentFuncName);
		static Ref<Shader>CreateFromDefaultLibrary(const std::string& name,
															   NSString* vertexFuncName,NSString* fragmentFuncName);
		
		id<MTLFunction> GetVertexFunction()const {return m_VertexFunction;}
		id<MTLFunction> GetFragmentFunction()const {return m_FragmentFunction;}
		
		const std::string& GetName(){return m_Name;}
		
		bool CreatePipelineState(const BufferLayout& layout);
		MTLVertexDescriptor* CreateVertexDescriptor(const BufferLayout& layout);
		id<MTLRenderPipelineState> GetPipelineState()const{return m_PipelineState;}
		
		void SetBlendType(BlendType type){m_BlendType=type;}
		void SetBlend(BlendType type,MTLRenderPipelineDescriptor* pipelinedesc,MTLDepthStencilDescriptor* depthStencilDescriptor){
			switch (type) {
				case BlendType::Opaque:		SetOpaqueBlend(pipelinedesc,depthStencilDescriptor);	break;
				case BlendType::Alpha:		SetAlphaBlend(pipelinedesc,depthStencilDescriptor);		break;
				case BlendType::Addictive:	SetAddictiveBlend(pipelinedesc,depthStencilDescriptor);	break;
				default:					SetOpaqueBlend(pipelinedesc,depthStencilDescriptor);	break;
			}
		}
		
		void Bind();
	private:
		bool LoadFromSource(const std::string& source,
							NSString* vertexFuncName,NSString* fragmentFuncName);
		bool LoadFromLibrary(const std::string& librarypath,
							 NSString* vertexFuncName,NSString* fragmentFuncName);
		bool LoadFromDefaultLibrary(NSString* vertexFuncName,NSString* fragmentFuncName);
	private:
		void SetOpaqueBlend(MTLRenderPipelineDescriptor* pipelinedesc,MTLDepthStencilDescriptor* depthStencilDescriptor);
		void SetAlphaBlend(MTLRenderPipelineDescriptor* pipelinedesc,MTLDepthStencilDescriptor* depthStencilDescriptor);
		void SetAddictiveBlend(MTLRenderPipelineDescriptor* pipelinedesc,MTLDepthStencilDescriptor* depthStencilDescriptor);
	private:
		std::string m_Name;
		id<MTLFunction> m_VertexFunction=nil;
		id<MTLFunction> m_FragmentFunction=nil;
		
		id<MTLLibrary> m_Library;
		id<MTLRenderPipelineState> m_PipelineState=nil;
		BlendType m_BlendType=BlendType::Opaque;
	};
	class ShaderLibrary{
	public:
		void Add(const std::string& name,const std::shared_ptr<Shader>& shader);
		std::shared_ptr<Shader> LoadFromSource(const std::string& name,const std::string& source,
											   NSString* vertexFuncName,NSString* fragmentFuncName,
											   const BufferLayout& layout);
		std::shared_ptr<Shader> LoadFromFile(const std::string& name,const std::string& filepath,
											 NSString* vertexFuncName,NSString* fragmentFuncName,
											 const BufferLayout& layout);
		bool Exists(const std::string& name)const;
		std::shared_ptr<Shader> Get(const std::string& name);
	private:
		std::unordered_map<std::string, std::shared_ptr<Shader>> m_Shaders;
	};
}


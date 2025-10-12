#pragma once

#include<string>
#include<unordered_map>
#include"Buffer/BufferLayout.h"

namespace MEL{
	class Shader{
	public:
		Shader(const std::string& name);
		~Shader();
		
		static std::shared_ptr<Shader>CreateFromSource(const std::string& name,const std::string& source,
													   NSString* vertexFuncName,NSString* fragmentFuncName);
		static std::shared_ptr<Shader>CreateFromLibrary(const std::string& name,const std::string& librarypath,
														NSString* vertexFuncName,NSString* fragmentFuncName);
		static std::shared_ptr<Shader>CreateFromDefaultLibrary(const std::string& name,
															   NSString* vertexFuncName,NSString* fragmentFuncName);
		
		id<MTLFunction> GetVertexFunction()const {return m_VertexFunction;}
		id<MTLFunction> GetFragmentFunction()const {return m_FragmentFunction;}
		
		const std::string& GetName(){return m_Name;}
		
		bool CreatePipelineState(const BufferLayout& layout);
		MTLVertexDescriptor* CreateVertexDescriptor(const BufferLayout& layout);
		id<MTLRenderPipelineState> GetPipelineState()const{return m_PipelineState;}
		void Bind();
	private:
		bool LoadFromSource(const std::string& source,
							NSString* vertexFuncName,NSString* fragmentFuncName);
		bool LoadFromLibrary(const std::string& librarypath,
							 NSString* vertexFuncName,NSString* fragmentFuncName);
		bool LoadFromDefaultLibrary(NSString* vertexFuncName,NSString* fragmentFuncName);
		
	private:
		std::string m_Name;
		id<MTLFunction> m_VertexFunction=nil;
		id<MTLFunction> m_FragmentFunction=nil;
		
		id<MTLLibrary> m_Library;
		id<MTLRenderPipelineState> m_PipelineState=nil;
	};
}


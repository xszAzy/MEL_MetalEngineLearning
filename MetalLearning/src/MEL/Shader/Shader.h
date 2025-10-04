#pragma once

#include "MEL.h"
#include<string>

namespace MEL{
	class Shader{
	public:
		~Shader();
		
		static std::shared_ptr<Shader>CreateFromSource(const std::string& name,const std::string& source);
		static std::shared_ptr<Shader>CreateFromLibrary(const std::string& name,const std::string& librarypath);
		
		id<MTLFunction> GetVertexFunction()const {return m_VertexFunction;}
		id<MTLFunction> GetIndexFunction()const {return m_FragmentFunction;}
		
		const std::string& GetName(){return m_Name;}
		
	private:
		Shader(const std::string& name);
		bool LoadFromSource(const std::string& source);
		bool LoadFromLibrary(const std::string& librarypath);
		
	private:
		std::string m_Name;
		id<MTLFunction> m_VertexFunction=nil;
		id<MTLFunction> m_FragmentFunction=nil;
	};
}

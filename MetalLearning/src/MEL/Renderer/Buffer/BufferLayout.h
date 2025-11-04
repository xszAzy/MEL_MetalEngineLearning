#pragma once
#import <Metal/Metal.h>
#include <vector>
#include <cstdint>

namespace MEL {
	enum class ShaderDataType{
		None=0,
		Float,Float2,Float3,Float4,
		Mat3,Mat4,
		Int,Int2,Int3,Int4,
		Bool
	};
	
	static uint32_t ShaderDataTypeSize(ShaderDataType type){
		switch(type){
			case ShaderDataType::Float:		return 4;		break;
			case ShaderDataType::Float2:	return 4*2;		break;
			case ShaderDataType::Float3:	return 4*3;		break;
			case ShaderDataType::Float4:	return 4*4;		break;
			case ShaderDataType::Mat3:		return 4*3*3; 	break;
			case ShaderDataType::Mat4:		return 4*4*4;	break;
			case ShaderDataType::Int:		return 4;		break;
			case ShaderDataType::Int2:		return 4*2;		break;
			case ShaderDataType::Int3:		return 4*3;		break;
			case ShaderDataType::Int4:		return 4*4;		break;
			case ShaderDataType::Bool:		return true;	break;
			default:						return 0;		break;
		}
	}
	
	static MTLVertexFormat ShaderDataTypeToMetal(ShaderDataType type){
		switch(type){
			case ShaderDataType::Float:		return MTLVertexFormatFloat;		break;
			case ShaderDataType::Float2:	return MTLVertexFormatFloat2;		break;
			case ShaderDataType::Float3:	return MTLVertexFormatFloat3;		break;
			case ShaderDataType::Float4:	return MTLVertexFormatFloat4;		break;
			case ShaderDataType::Mat3:		return MTLVertexFormatFloat3; 		break;
			case ShaderDataType::Mat4:		return MTLVertexFormatFloat3;		break;
			case ShaderDataType::Int:		return MTLVertexFormatInt;			break;
			case ShaderDataType::Int2:		return MTLVertexFormatInt2;			break;
			case ShaderDataType::Int3:		return MTLVertexFormatInt3;			break;
			case ShaderDataType::Int4:		return MTLVertexFormatInt4; 		break;
			case ShaderDataType::Bool:		return MTLVertexFormatChar;			break;
			default:						return MTLVertexFormatFloat;		break;
		}
	}
	
	struct BufferElement{
		std::string Name;
		ShaderDataType Type;
		uint32_t Size;
		uint32_t Offset;
		bool Normalized;
		
		BufferElement()=default;
		
		BufferElement(ShaderDataType type,const std::string& name,bool normalized=false)
		:Name(name),Type(type),Size(ShaderDataTypeSize(type)),Offset(0),Normalized(normalized){}
		
		uint32_t GetComponentCount()const{
			switch (Type){
				case ShaderDataType::Float:		return 1;		break;
				case ShaderDataType::Float2:	return 2;		break;
				case ShaderDataType::Float3:	return 3;		break;
				case ShaderDataType::Float4:	return 4;		break;
				case ShaderDataType::Mat3:		return 3; 		break;
				case ShaderDataType::Mat4:		return 4;		break;
				case ShaderDataType::Int:		return 1;		break;
				case ShaderDataType::Int2:		return 2;		break;
				case ShaderDataType::Int3:		return 3;		break;
				case ShaderDataType::Int4:		return 4;		break;
				case ShaderDataType::Bool:		return 1;		break;
				default:						return 0;		break;
			}
		}
	};
	
	class BufferLayout{
	public:
		BufferLayout()=default;
		
		BufferLayout(const std::initializer_list<BufferElement>& elements)
		:m_Elements(elements){
			CalculateOffsetAndStride();
		}
		
		const std::vector<BufferElement>& GetElements() const{return m_Elements;}
		uint32_t GetStride()const {return m_Stride;}
		
		std::vector<BufferElement>::iterator begin(){return m_Elements.begin();}
		std::vector<BufferElement>::iterator end(){return m_Elements.end();}
		
		std::vector<BufferElement>::const_iterator begin()const{return m_Elements.begin();}
		std::vector<BufferElement>::const_iterator end()const{return m_Elements.end();}
		
		static BufferLayout Default(){
			return {
				{ShaderDataType::Float3,"a_Position"},
				{ShaderDataType::Float4,"a_Color"}
			};
		}
		
		static BufferLayout SimplePosition(){
			return{
				{ShaderDataType::Float3,"a_Position"}
			};
		}
		
		static BufferLayout PositionColor(){
			return {
				{ShaderDataType::Float3,"a_Position"},
				{ShaderDataType::Float4,"a_Color"}
			};
		}
		
		static BufferLayout PositionTexture(){
			return {
				{ShaderDataType::Float3,"a_Position"},
				{ShaderDataType::Float2,"a_TexCoord"}
			};
		}
		
		static BufferLayout PositionNormalTexture(){
			return {
				{ShaderDataType::Float3,"a_Position"},
				{ShaderDataType::Float3,"a_Normal"},
				{ShaderDataType::Float2,"a_TexCoord"}
			};
		}
		
	private:
		void CalculateOffsetAndStride(){
			uint32_t offset=0;
			m_Stride=0;
			for(auto& element:m_Elements){
				element.Offset=offset;
				offset+=element.Size;
				m_Stride+=element.Size;
			}
		}
	private:
		std::vector<BufferElement> m_Elements;
		uint32_t m_Stride=0;
	};
}

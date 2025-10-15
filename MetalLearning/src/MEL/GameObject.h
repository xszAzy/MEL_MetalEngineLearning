#pragma once

#include "Transforms/Transform.h"
#include "VertexArray/VertexArray.h"
#include "Buffer/UniformBuffer.h"
#include <memory>
#include <string>

namespace MEL{
	class GameObject{
	public:
		GameObject(const std::string& name="GameObject"):m_Name(name),m_IsActive(true){
			m_TransformUniform=UniformBuffer::Create(sizeof(TransformData));
			if(m_TransformUniform){
				m_TransformUniform->SetBindSlot(2);
			}
		}
		
		GameObject(const GameObject&&)=delete;
		GameObject& operator=(const GameObject&)=delete;
		
		GameObject(GameObject&&)=default;
		
		const std::string& GetName() const{return m_Name;}
		void SetName(const std::string& name){m_Name=name;}
		
		bool IsActive() const{return m_IsActive;}
		void SetActive(bool active){m_IsActive=active;}
		
		Transform& GetTransform(){return m_Transform;}
		const Transform& GetTransform()const{return m_Transform;}
		
		std::shared_ptr<VertexArray> GetVertexArray()const{return m_VertexArray;}
		void SetVertexArray(const std::shared_ptr<VertexArray>& va){m_VertexArray=va;}
		
		void BindTransform(){
			if(!m_TransformUniform||!m_IsActive)return;
			
			TransformData transformData;
			transformData.modelMatrix=m_Transform.GetLocalToWorldMatrix();
			transformData.color=m_Color;
			m_TransformUniform->SetData(&transformData, sizeof(transformData));
			m_TransformUniform->Bind();
		}
		
		void SetColor(simd::float3 color){
			m_Color={color.x,color.y,color.z,1.0f};
		}
		
	private:
		std::string m_Name;
		Transform m_Transform;
		std::shared_ptr<VertexArray> m_VertexArray;
		std::shared_ptr<UniformBuffer> m_TransformUniform;
		simd::float4 m_Color={0.7,0.7,0.4,1};
		
		bool m_IsActive=true;
	};
}

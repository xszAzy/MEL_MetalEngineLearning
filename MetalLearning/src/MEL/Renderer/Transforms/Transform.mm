#include "Transform.h"
#include "Log.h"

namespace MEL {
	Transform::Transform(){
		m_LocalToWorldMatrix=matrix_identity_float4x4;
		m_WorldToLocalMatrix=matrix_identity_float4x4;
	}
	
	void Transform::SetPosition(const simd::float3 &position){
		m_Position=position;
		m_MatrixDirty=true;
	}
	
	void Transform::SetRotation(const simd::float3 &euler_angles){
		m_Rotation=euler_angles;
		m_MatrixDirty=true;
	}
	
	void Transform::SetScale(const simd::float3 &scale){
		m_Scale=scale;
		m_MatrixDirty=true;
	}
	
	void Transform::Translate(const simd::float3 &translation){
		m_Position+=translation;
		m_MatrixDirty=true;
	}
	
	void Transform::Rotate(const simd::float3 &eular_angles){
		m_Rotation+=eular_angles;
		m_MatrixDirty=true;
	}
	
	void Transform::Scale(const simd::float3 &scale){
		m_Scale*=scale;
		m_MatrixDirty=true;
	}
	
	simd::float4x4 Transform::GetLocalToWorldMatrix()const {
		if(m_MatrixDirty){
			UpdateMatrices();
		}
		return m_LocalToWorldMatrix;
	}
	
	simd::float4x4 Transform::GetWorldToLocalMatrix()const {
		if(m_MatrixDirty){
			UpdateMatrices();
		}
		return m_WorldToLocalMatrix;
	}
	
	void Transform::UpdateMatrices()const {
		if(!m_MatrixDirty)return;
		
		simd::float4x4 scale_matrix={
			simd::float4{m_Scale.x,0,0,0},
			simd::float4{0,m_Scale.y,0,0},
			simd::float4{0,0,m_Scale.z,0},
			simd::float4{0,0,0		  ,1}
		};
		
		float rx=m_Rotation.x*M_PI/180.0f;
		float ry=m_Rotation.y*M_PI/180.0f;
		float rz=m_Rotation.z*M_PI/180.0f;
		
		float cosX=cosf(rx),sinX=sinf(rx);
		float cosY=cosf(ry),sinY=sinf(ry);
		float cosZ=cosf(rz),sinZ=sinf(rz);
		
		simd::float4x4 rotation_matrix={
			simd::float4{cosY*cosZ				 ,cosY*sinZ				  ,-sinY	,0},
			simd::float4{sinX*sinY*cosZ-cosX*sinZ,sinX*sinY*sinZ+cosX*cosZ,sinX*cosY,0},
			simd::float4{cosX*sinY*cosZ+sinX*sinZ,cosX*sinY*sinZ-sinX*cosZ,cosX*cosY,0},
			simd::float4{0						 ,0						  ,0		,1}
		};
		
		simd::float4x4 translation_matrix{
			simd::float4{1			 ,0			  ,0		   ,0},
			simd::float4{0			 ,1			  ,0		   ,0},
			simd::float4{0			 ,0			  ,1		   ,0},
			simd::float4{m_Position.x,m_Position.y,m_Position.z,1}
		};
		
		m_LocalToWorldMatrix=translation_matrix*rotation_matrix*scale_matrix;
		
		m_WorldToLocalMatrix=simd_inverse(m_LocalToWorldMatrix);
		//MEL_CORE_INFO("Update transform matrix");
		m_MatrixDirty=false;
	}
	
	simd::float3 Transform::GetForward()const{
		if(m_MatrixDirty){
			UpdateMatrices();
		}
		return simd::normalize(simd::float3{
			m_LocalToWorldMatrix.columns[2].x,
			m_LocalToWorldMatrix.columns[2].y,
			m_LocalToWorldMatrix.columns[2].z,
		});
	}
	
	simd::float3 Transform::GetRight()const{
		if(m_MatrixDirty){
			UpdateMatrices();
		}
		return simd::normalize(simd::float3{
			m_LocalToWorldMatrix.columns[0].x,
			m_LocalToWorldMatrix.columns[0].y,
			m_LocalToWorldMatrix.columns[0].z,
		});
	}
	
	simd::float3 Transform::GetUp()const{
		if(m_MatrixDirty){
			UpdateMatrices();
		}
		return simd::normalize(simd::float3{
			m_LocalToWorldMatrix.columns[1].x,
			m_LocalToWorldMatrix.columns[1].y,
			m_LocalToWorldMatrix.columns[1].z,
		});
	}
	
	void Transform::Reset(){
		m_Position={0,0,0};
		m_Rotation={0,0,0};
		m_Scale={1,1,1};
		m_MatrixDirty=true;
	}
}

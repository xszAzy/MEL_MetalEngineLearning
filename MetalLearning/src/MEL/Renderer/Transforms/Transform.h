#pragma once

#include <simd/simd.h>

namespace MEL {
	class Transform{
	public:
		Transform();
		
		void SetPosition(const simd::float3& position);
		void SetRotation(const simd::float3& euler_angles);
		void SetScale(const simd::float3& scale);
		
		const simd::float3& GetPosition() const{return m_Position;}
		const simd::float3& GetRotation() const{return m_Rotation;}
		const simd::float3& GetScale() const{return m_Scale;}
		
		simd::float4x4 GetLocalToWorldMatrix()const;
		simd::float4x4 GetWorldToLocalMatrix()const;
		
		void Translate(const simd::float3& translation);
		void Rotate(const simd::float3& eular_angles);
		void Scale(const simd::float3& scale);
		
		simd::float3 GetForward()const;
		simd::float3 GetRight()const;
		simd::float3 GetUp()const;
		
		void Reset();
	private:
		void UpdateMatrices()const;
		simd::float3 m_Position={0.0f,0.0f,0.0f};
		simd::float3 m_Rotation={0.0f,0.0f,0.0f};
		simd::float3 m_Scale={1.0f,1.0f,1.0f};
		
		mutable bool m_MatrixDirty=true;
		mutable simd::float4x4 m_LocalToWorldMatrix=matrix_identity_float4x4;
		mutable simd::float4x4 m_WorldToLocalMatrix=matrix_identity_float4x4;
	};
}

#pragma once
#include <simd/simd.h>

namespace MEL {
	class Camera{
	public:
		Camera();
		
		static Camera CreatePerspective(float fovDegrees,float aspectRatio,
										float nearZ,float farZ);
		
		static Camera CreateOrthographic(float left,float right,
										 float bottom,float top,
										 float nearZ,float farZ);
		
		void SetPosition(const simd::float3& position);
		void SetRotation(const simd::float3& eulerAngles);
		void RotatePitch(float delta);
		void RotateYaw(float delta);
		void RotateRoll(float delta);

		void SetTopDownView();
		void LookAt(const simd::float3& target);
		
		const simd::float4x4& GetViewMatrix()const {return m_ViewMatrix;}
		const simd::float4x4& GetProjectionMatrix()const {return m_ProjectionMatrix;}
		const simd::float4x4& GetViewProjectionMatrix()const {return m_ViewProjectionMatrix;}
		
		simd::float3 GetPosition()const {return m_Position;}
		simd::float3 GetForward()const {return m_Forward;}
		simd::float3 GetRight()const {return m_Right;}
		simd::float3 GetUp()const {return m_Up;}
		
	private:
		void UpdateViewMatrix();
		void UpdateProjectionMatrix();
		void UpdateDirections();
		
		simd::float3 m_Position={0.0f,0.0f,-1.0f};
		simd_quatf m_Orientation=simd_quaternion(0.0f, 0,0,-1);
		
		simd::float3 m_Forward={0.0f,0.0f,-1.0f};
		simd::float3 m_Right={1.0f,0.0f,0.0f};
		simd::float3 m_Up={0.0f,1.0f,0.0f};
		
		simd::float4x4 m_ViewMatrix=matrix_identity_float4x4;
		simd::float4x4 m_ProjectionMatrix=matrix_identity_float4x4;
		simd::float4x4 m_ViewProjectionMatrix=matrix_identity_float4x4;
		
		float m_FOV=60.0f;
		float m_AspectRatio=16.0f/9.0f;
		
		float m_NearZ=0.1f;
		float m_FarZ=1000.0f;
		
		bool m_IsPerspective=true;
		
		float m_OrthoLeft=-1.0f,m_OrthoRight=1.0f;
		float m_OrthoBottom=-1.0f,m_OrthoTop=1.0f;
	};
}

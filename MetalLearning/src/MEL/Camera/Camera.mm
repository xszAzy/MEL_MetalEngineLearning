#include "Camera.h"
#include <cmath>

namespace MEL {
	Camera::Camera(){
		UpdateViewMatrix();
		UpdateProjectionMatrix();
	}
	
	Camera Camera::CreatePerspective(float fovDegrees, float aspectRatio, float nearZ, float farZ){
		Camera camera;
		camera.m_IsPerspective=true;
		camera.m_FOV=fovDegrees;
		camera.m_AspectRatio=aspectRatio;
		camera.m_NearZ=nearZ;
		camera.m_FarZ=farZ;
		camera.UpdateProjectionMatrix();
		return camera;
	}
	
	Camera Camera::CreateOrthographic(float left, float right, float bottom, float top, float nearZ, float farZ){
		Camera camera;
		camera.m_IsPerspective=false;
		camera.m_OrthoLeft=left;
		camera.m_OrthoRight=right;
		camera.m_OrthoTop=top;
		camera.m_OrthoBottom=bottom;
		camera.m_NearZ=nearZ;
		camera.m_FarZ=farZ;
		camera.UpdateProjectionMatrix();
		return camera;
	}
	
	void Camera::SetPosition(const simd::float3 &position){
		m_Position=position;
		UpdateViewMatrix();
	}
	
	void Camera::SetRotation(const simd::float3 &eulerAngles){
		m_Rotation=eulerAngles;
		
		float cosPitch=cosf(m_Rotation.x);
		float sinPitch=sinf(m_Rotation.x);
		float cosYaw=cosf(m_Rotation.y);
		float sinYaw=sinf(m_Rotation.y);
		
		m_Forward=simd::normalize(simd::float3{cosYaw*cosPitch,sinPitch,sinYaw*cosPitch});
		m_Right=simd::normalize(simd::cross(m_Forward, simd::float3{0,1,0}));
		m_Up=simd::normalize(simd::cross(m_Right, m_Forward));
		
		UpdateViewMatrix();
	}
	
	void Camera::LookAt(const simd::float3 &target){
		m_Forward=simd::normalize(target-m_Position);
		m_Right=simd::normalize(simd::cross(m_Forward, simd::float3{0,1,0}));
		m_Up=simd::normalize(simd::cross(m_Right, m_Forward));
		
		UpdateViewMatrix();
	}
	
	void Camera::UpdateViewMatrix(){
		simd::float3 z=simd::normalize(m_Forward);
		simd::float3 x=simd::normalize(simd::cross(simd::float3{0,1,0}, z));
		simd::float3 y=simd::cross(z, x);
		
		simd::float3 p=m_Position;
		
		m_ViewMatrix=simd::float4x4{
			simd::float4{x.x,x.y,x.z,-simd::dot(x, p)},
			simd::float4{y.x,y.y,y.z,-simd::dot(y, p)},
			simd::float4{z.x,z.y,z.z,-simd::dot(z, p)},
			simd::float4{0	,0	,0	,1}
		};
		m_ViewProjectionMatrix=m_ViewMatrix*m_ProjectionMatrix;
	}
	
	void Camera::UpdateProjectionMatrix(){
		if(m_IsPerspective){
			float fovRadians=m_FOV*M_PI/180.f;
			float yScale=1.0f/tanf(fovRadians*0.5f);
			float xScale=yScale/m_AspectRatio;
			float zRange=m_FarZ-m_NearZ;
			
			m_ProjectionMatrix=(simd::float4x4){
				(simd::float4){xScale,0.0f,0.0f,0.0f},
				(simd::float4){0.0f,yScale,0.0f,0.0f},
				(simd::float4){0.0f,0.0f,-m_FarZ/zRange,-1.0f},
				(simd::float4){0.0f,0.0f,-m_NearZ*m_FarZ/zRange,0.0f}
			};
		}
		else{
			m_ProjectionMatrix=(simd::float4x4){
				(simd::float4){2.0f/(m_OrthoRight-m_OrthoLeft),0.0f,0.0f,0.0f},
				(simd::float4){0.0f,2.0f/(m_OrthoTop-m_OrthoBottom),0.0f,0.0f},
				(simd::float4){0.0f,0.0f,-1.0f/(m_FarZ-m_NearZ),0.0f},
				(simd::float4){-(m_OrthoRight+m_OrthoLeft)/(m_OrthoRight-m_OrthoLeft),-(m_OrthoTop+m_OrthoBottom)/(m_OrthoTop-m_OrthoBottom),
					-m_NearZ/(m_FarZ-m_NearZ),1.0f}
			};
		}
		m_ViewProjectionMatrix=m_ViewMatrix*m_ProjectionMatrix;
	}
}

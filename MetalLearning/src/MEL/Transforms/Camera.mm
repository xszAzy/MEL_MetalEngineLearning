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
		m_Orientation=simd_quaternion(0.0f,0.0f,0.0f,1.0f);
		
		RotateYaw(eulerAngles.y);
		RotatePitch(eulerAngles.x);
		RotateRoll(eulerAngles.z);
	}
	
	void Camera::RotatePitch(float delta){
		simd_quatf rot=simd_quaternion(delta,-m_Right);
		m_Orientation=simd::normalize(simd_mul(m_Orientation,rot));
		UpdateViewMatrix();
	}
	
	void Camera::RotateYaw(float delta){
		simd_quatf rot=simd_quaternion(delta,simd::float3{0,1,0});
		m_Orientation=simd::normalize(simd_mul(m_Orientation,rot));
		UpdateViewMatrix();
	}
	
	void Camera::RotateRoll(float delta){
		simd_quatf rot=simd_quaternion(delta,m_Forward);
		m_Orientation=simd::normalize(simd_mul(m_Orientation,rot));
		UpdateViewMatrix();
	}
	
	void Camera::UpdateDirections(){
		m_Right=simd::normalize(simd_act(m_Orientation, simd::float3{1,0,0}));
		m_Up=simd::normalize(simd_act(m_Orientation, simd::float3{0,1,0}));
		m_Forward=simd::normalize(simd_act(m_Orientation, simd::float3{0,0,-1}));
		
		
	}
	
	void Camera::LookAt(const simd::float3 &target){
		simd::float3 worldUp={0,1,0};
		simd::float3 newForward=simd::normalize(target-m_Position);
		
		if(fabs(simd::dot(newForward,worldUp))>0.999f){
			worldUp={0,0,1};
		}
		
		simd::float3 newRight=simd::normalize(simd::cross(worldUp, newForward));
		simd::float3 newUp=simd::normalize(simd::cross(newForward, newRight));
		
		simd::float4x4 rotationMatrix={
			simd::float4{newRight.x,newUp.x,-newForward.x,0},
			simd::float4{newRight.y,newUp.y,-newForward.y,0},
			simd::float4{newRight.z,newUp.z,-newForward.z,0},
			simd::float4{0,0,0,1}
		};
		
		m_Orientation=simd_quaternion(rotationMatrix);
		m_Orientation=simd_normalize(m_Orientation);
		
		m_Forward=newForward;
		m_Right=newRight;
		m_Up=newUp;
		
		UpdateViewMatrix();
	}
	
	void Camera::UpdateViewMatrix(){
		UpdateDirections();
		simd::float3 z=-simd::normalize(m_Forward);
		simd::float3 x=simd::normalize(m_Right);
		simd::float3 y=simd::normalize(m_Up);
		
		simd::float3 p=m_Position;
		
		m_ViewMatrix=simd::float4x4{
			simd::float4{x.x,y.x,z.x,0.0f},
			simd::float4{x.y,y.y,z.y,0.0f},
			simd::float4{x.z,y.z,z.z,0.0f},
			simd::float4{-simd::dot(x,p),-simd::dot(y, p),-simd::dot(z, p),1.0f}
		};
		m_ViewProjectionMatrix=m_ProjectionMatrix*m_ViewMatrix;
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
		m_ViewProjectionMatrix=m_ProjectionMatrix*m_ViewMatrix;
	}
}

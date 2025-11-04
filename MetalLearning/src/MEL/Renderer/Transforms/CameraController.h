#pragma once
#include "Camera.h"
#include "Core/Timestep.h"
#include "Events/ApplicationEvent.h"
#include "Events/MouseEvent.h"
#include "Renderer.h"

namespace MEL {
	class CameraController{
	public:
		static void PerspectiveController(float fovDegrees,float aspectRatio,
								   float nearZ,float farZ);
		static void OrthographicController(float left,float right,
									float bottom,float top,
									float nearZ,float farZ);
		void OnUpdate(Timestep ts);
		void OnEvent(Event& e);
		
		Ref<Camera> GetCamera(){return s_Camera;}
		const Camera GetCamera() const{return *s_Camera;}
		
		void SetPosition(simd::float3 position){
			m_CameraPosition=position;
			s_Camera->SetPosition(position);
		}
		void LookAt(simd::float3 target){
			s_Camera->LookAt(target);
		}
	private:
		bool OnMouseScrolled(MouseScrolledEvent& e);
		bool OnWindowResized(WindowResizeEvent& e);
	private:
		float m_AspectRatio;
		
		static Ref<Camera> s_Camera;
		
		simd::float3 m_CameraPosition;
		float m_CameraRotation=.0f;
		float m_CameraTranslationSpeed=1.0f,m_CameraRotationSpeed=1.0f;
		
		static Renderer* s_Renderer;
		
		static bool s_IsOrtho;
		float m_Zoom=5;
	};
}

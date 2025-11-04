#include "CameraController.h"

#include "MacInput.h"

namespace MEL{
	Renderer* CameraController::s_Renderer=nullptr;
	Ref<Camera> CameraController::s_Camera=nullptr;
	bool CameraController::s_IsOrtho=false;
	void CameraController::PerspectiveController(float fovDegrees, float aspectRatio, float nearZ, float farZ){
		s_Camera=std::make_shared<Camera>();
		*s_Camera=Camera::CreatePerspective(fovDegrees, aspectRatio, nearZ, farZ);
		s_IsOrtho=false;
	}
	
	void CameraController::OrthographicController(float left, float right, float bottom, float top, float nearZ, float farZ){
		s_Camera=std::make_shared<Camera>();
		*s_Camera=Camera::CreateOrthographic(left, right, bottom, top, nearZ, farZ);
		s_IsOrtho=true;
	}
	
	void CameraController::OnUpdate(Timestep ts){
		if(!s_IsOrtho){
			if(MEL::MacInput::IsKeyPressed(MEL::Key::J)){
				s_Camera->RotateYaw(-m_CameraRotationSpeed*ts);
			}
			else if(MEL::MacInput::IsKeyPressed(MEL::Key::L)){
				s_Camera->RotateYaw(m_CameraRotationSpeed*ts);
			}
			
			if(MEL::MacInput::IsKeyPressed(MEL::Key::I)){
				s_Camera->RotatePitch(-m_CameraRotationSpeed*ts);
			}
			else if(MEL::MacInput::IsKeyPressed(MEL::Key::K)){
				s_Camera->RotatePitch(m_CameraRotationSpeed*ts);
			}
		}
		if(MEL::MacInput::IsKeyPressed(MEL::Key::Left)){
			m_CameraPosition.x-=m_CameraTranslationSpeed*ts;
		}
		else if (MEL::MacInput::IsKeyPressed(MEL::Key::Right)){
			m_CameraPosition.x+=m_CameraTranslationSpeed*ts;
		}
		
		if(MEL::MacInput::IsKeyPressed(MEL::Key::Up)){
			m_CameraPosition.y+=m_CameraTranslationSpeed*ts;
		}
		else if (MEL::MacInput::IsKeyPressed(MEL::Key::Down)){
			m_CameraPosition.y-=m_CameraTranslationSpeed*ts;
		}
		s_Camera->SetPosition(m_CameraPosition);
		
		if(MEL::MacInput::IsKeyPressed(MEL::Key::A)){
			s_Camera->RotateRoll(-m_CameraRotationSpeed*ts);
		}
		else if(MEL::MacInput::IsKeyPressed(MEL::Key::D)){
			s_Camera->RotateRoll(m_CameraRotationSpeed*ts);
		}
	}
	
	void CameraController::OnEvent(Event &e){
		EventDispatcher dispatcher(e);
		dispatcher.Dispatch<MouseScrolledEvent>(MEL_BIND_EVENT_FN(CameraController::OnMouseScrolled));
		dispatcher.Dispatch<WindowResizeEvent>(MEL_BIND_EVENT_FN(CameraController::OnWindowResized));
	}
	
	bool CameraController::OnMouseScrolled(MouseScrolledEvent &e){
		if(s_IsOrtho){
			m_Zoom-=e.GetYOffset()*0.1f;
			if(m_Zoom<1.0f)m_Zoom=1.0f;
			else if(m_Zoom>20.0f)m_Zoom=20.0f;
			s_Camera->SetOrthoZoom(m_Zoom);
		}
		else{
			m_CameraPosition.z-=e.GetYOffset()*0.15f;
			if(m_CameraPosition.z<0.5f)m_CameraPosition.z=.5f;
			s_Camera->SetPosition(m_CameraPosition);
		}
			
		return false;
	}
	
	bool CameraController::OnWindowResized(WindowResizeEvent &e){
		m_AspectRatio=(float)e.GetWidth()/e.GetHeight();
		s_Camera->SetAspectRatio(m_AspectRatio);
		return false;
	}
}

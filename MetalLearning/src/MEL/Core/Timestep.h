#pragma once

namespace MEL {
	class Timestep{
	public:
		Timestep(float time=0.0f):m_Time(time){}
		
		operator float() const {return m_Time;}
		float GetSeconds()const{return m_Time;}
		float GetMilliSeconds()const {return m_Time*100.f;}
	private:
		float m_Time;
	};
}

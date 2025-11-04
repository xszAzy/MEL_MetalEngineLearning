#pragma once
#include<chrono>

class Time{
public:
	static void Init(){
		s_StartTime=Clock::now();
	}
	static float GetTime(){
		auto now=Clock::now();
		auto duration=now-s_StartTime;
		return std::chrono::duration<float>(duration).count();
	}
private:
	using Clock=std::chrono::high_resolution_clock;
	static Clock::time_point s_StartTime;
};

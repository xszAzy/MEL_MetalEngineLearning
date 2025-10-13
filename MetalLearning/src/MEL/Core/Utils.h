#pragma once
#include<chrono>

class Time{
public:
	static float GetTime(){
		auto now=std::chrono::high_resolution_clock::now();
		auto duration=now.time_since_epoch();
		return std::chrono::duration<float>(duration).count();
	}
};

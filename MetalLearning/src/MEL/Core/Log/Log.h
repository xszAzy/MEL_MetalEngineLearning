#pragma once
//I'm using Hazel's log system
#include "Core.h"
#include "spdlog/spdlog.h"
#include "spdlog/fmt/ostr.h"
//if occurr "use quotes" error in spdlog source file,add "include" dir to "header search path" to solve it
namespace MEL {
	class Log{
	public:
		static void Init();
		static Ref<spdlog::logger>& GetCoreLogger();
		static Ref<spdlog::logger>& GetClientLogger();
		
	private:
		static Ref<spdlog::logger> s_CoreLogger;
		static Ref<spdlog::logger> s_ClientLogger;
	};
}

//Core log macros
#define MEL_CORE_TRACE(...) 	::MEL::Log::GetCoreLogger()->trace(__VA_ARGS__)
#define MEL_CORE_INFO(...) 		::MEL::Log::GetCoreLogger()->info(__VA_ARGS__)
#define MEL_CORE_WARN(...) 		::MEL::Log::GetCoreLogger()->warn(__VA_ARGS__)
#define MEL_CORE_ERROR(...) 	::MEL::Log::GetCoreLogger()->error(__VA_ARGS__)

//Client log macros

#define MEL_TRACE(...)		 	::MEL::Log::GetClientLogger()->trace(__VA_ARGS__)
#define MEL_INFO(...) 		 	::MEL::Log::GetClientLogger()->info(__VA_ARGS__)
#define MEL_WARN(...) 		 	::MEL::Log::GetClientLogger()->error(__VA_ARGS__)
#define MEL_ERROR(...)		 	::MEL::Log::GetClientLogger()->error(__VA_ARGS__)


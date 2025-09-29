#pragma once
//I'm using Hazel's log system

#include <memory>
#include "Core.h"
#include "spdlog/spdlog.h"
#include "spdlog/sinks/stdout_color_sinks.h"
//if occurr "use quotes" error in spdlog source file,add "include" dir to "header search path" to solve it
namespace MEL {
	class Log{
	public:
		static void Init();
		inline static std::shared_ptr<spdlog::logger>& GetCoreLogger(){return s_CoreLogger;}
		inline static std::shared_ptr<spdlog::logger>& GetClientLogger(){return s_ClientLogger;}
		
	private:
		static std::shared_ptr<spdlog::logger> s_CoreLogger;
		static std::shared_ptr<spdlog::logger> s_ClientLogger;
	};
}

//Core log macros
#define MEL_CORE_TRACE(...) 	::MEL::Log::GetCoreLogger()->trace(__VA_ARGS__)
#define MEL_CORE_INFO(...) 		::MEL::Log::GetCoreLogger()->info(__VA_ARGS__)
#define MEL_CORE_WARN(...) 		::MEL::Log::GetCoreLogger()->warn(__VA_ARGS__)
#define MEL_CORE_ERROR(...) 	::MEL::Log::GetCoreLogger()->error(__VA_ARGS__)

//Client log macros

#define MEL_TRACE(...)		 	::MEL::Log::GetClientLogger()->trace(__VA_ARGS__)
#define MEL_INFO(...) 		 	::MEL::Log::GetClientLogger()->trace(__VA_ARGS__)
#define MEL_WARN(...) 		 	::MEL::Log::GetClientLogger()->trace(__VA_ARGS__)
#define MEL_ERROR(...)		 	::MEL::Log::GetClientLogger()->trace(__VA_ARGS__)


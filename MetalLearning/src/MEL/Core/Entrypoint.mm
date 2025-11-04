#import "melpch.h"
#include "Application.h"
#include "Log.h"

MEL::Application* MEL::CreateApplication();

int main(int argc,const char* argv[]){
	MEL::Log::Init();
	MEL_CORE_INFO("Testing");
	
	auto app =MEL::CreateApplication();
	app->Run();
	delete app;
	
	return 0;
}

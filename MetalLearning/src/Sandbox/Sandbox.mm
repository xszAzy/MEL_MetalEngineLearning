#include "MEL.h"
class Sandbox:public MEL::Application{
public:
	Sandbox(){
		
	}
	~Sandbox(){
		
	}
private:
	
};

MEL::Application* MEL::CreateApplication(){
	return new Sandbox();
}

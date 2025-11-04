#import "Delegates.h"
#include "Application.h"
#include "Renderer/Renderer.h"
#include "Shader/Shader.h"
#include "Window.h"

@implementation MELMTKViewDelegate{
	MEL::Application* _application;
}

-(instancetype)initWithApplication:(MEL::Application*)application{
	self=[super init];
	if(self){
		_application=application;
	}
	return self;
}

-(void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
	MEL_CORE_INFO("Drawable Size Will change to:{}x{}",(int)size.width,(int)size.height);
	
	if(_application&&_application->GetRenderer()){
		_application->GetRenderer()->OnResize((uint32_t)size.width, (uint32_t)size.height);
	}
}

-(void)drawInMTKView:(MTKView *)view{
	if(!_application)return;
	if(view.hidden||
	   view.window==nil||
	   !view.window.visible||
	   view.currentDrawable==nil||
	   view.currentRenderPassDescriptor==nil){
		return;
	}
	@try{
		_application->RenderOneFrame();
	}
	@catch (NSException* exception){
		NSLog(@"Rendering error:%@",exception);
	}
}
@end


@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification{
	NSLog(@"finished launching application");
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
	return YES;
}

-(void)applicationDidBecomeActive:(NSNotification *)notification{
	NSLog(@"Application became active");
}

-(void)applicationDidResignActive:(NSNotification *)notification{
	NSLog(@"Application resigned active");
}

@end

#import "MetalRenderer.h"

#import "imgui.h"
#import "imgui_impl_metal.h"
#import "imgui_impl_osx.h"

@implementation MetalRenderer{
	id<MTLDevice> _device;
	id<MTLRenderPipelineState> _pipelineState;
	id<MTLCommandQueue> _commandQueue;
	vector_uint2 _viewportSize;
	MTKView* _mtkView;
}

-(nonnull instancetype)initWithMetalKitView:(MTKView *)mtkView{
	self=[super init];
	if(self){
		_device=mtkView.device;
		_mtkView=mtkView;
		_commandQueue=[_device newCommandQueue];
		_viewportSize=(vector_uint2)
		{
			(uint32_t)mtkView.drawableSize.width,
			(uint32_t)mtkView.drawableSize.height
		};
		[self _setupPipeline];
	}
	return self;
}

-(void)setupImGui{
	ImGui::CreateContext();
	ImGui_ImplMetal_Init(_device);
	ImGui_ImplOSX_Init(_mtkView);
	ImGui::StyleColorsDark();
	
	ImGuiIO& io=ImGui::GetIO();
	io.Fonts->AddFontDefault();
}

-(void)_setupPipeline{
	id<MTLLibrary> defaultLibrary=[_device newDefaultLibrary];
	
	NSError* error=nil;
	
	if(!defaultLibrary){
		NSBundle* mainBundle=[NSBundle mainBundle];
		NSURL* metalLibraryURL=[mainBundle URLForResource:@"default" withExtension:@"metallib"];
		defaultLibrary=[_device newLibraryWithURL:metalLibraryURL error:&error];
	}
	
	if(!defaultLibrary){
		NSLog(@"Failed to load Metal library: %@",error);
	}
	error=nil;
	
	id<MTLFunction> vertexFunction=[defaultLibrary newFunctionWithName:@"vertexShader"];
	id<MTLFunction> fragmentFunction=[defaultLibrary newFunctionWithName:@"fragmentShader"];
	
	if(!vertexFunction || !fragmentFunction){
		NSLog(@"Note:Custom shaders not found,only ImGui rendering will be available!");
		return;
	}
	
	MTLRenderPipelineDescriptor* pipeLineDescriptor=[[MTLRenderPipelineDescriptor alloc] init];
	pipeLineDescriptor.label=@"Simple Pipeline";
	
	pipeLineDescriptor.vertexFunction=vertexFunction;
	pipeLineDescriptor.fragmentFunction=fragmentFunction;
	
	pipeLineDescriptor.colorAttachments[0].pixelFormat=MTLPixelFormatBGRA8Unorm;
	
	_pipelineState=[_device newRenderPipelineStateWithDescriptor:pipeLineDescriptor
														   error:&error];
	
	if(!_pipelineState){
		NSLog(@"create pipeline state failed:%@",error);
	}
}

#pragma mark - MTKViewDelegate

-(void)drawInMTKView:(MTKView *)view{
	id<MTLCommandBuffer> commandBuffer=[_commandQueue commandBuffer];
	commandBuffer.label=@"MyCommandBuffer";
	
	MTLRenderPassDescriptor* renderPassDescriptor=view.currentRenderPassDescriptor;
	if(renderPassDescriptor==nil){
		[commandBuffer commit];
		return;
	}
	//begin imgui render
	ImGui_ImplMetal_NewFrame(renderPassDescriptor);
	ImGui_ImplOSX_NewFrame(view);
	ImGui::NewFrame();
	//draw imgui (that's imguilayer::end() in hazel)
	[self _drawImGui];
	
	ImGui::Render();
	
	id<MTLRenderCommandEncoder> renderEncoder=[commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
	renderEncoder.label=@"MyRenderEncoder";
	
	if(_pipelineState){
		
		[renderEncoder setRenderPipelineState:_pipelineState];
		
		[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
						  vertexStart:0
						  vertexCount:3];
	}
	
	ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderEncoder);
	
	[renderEncoder endEncoding];
	[commandBuffer presentDrawable:view.currentDrawable];
	[commandBuffer commit];
	
	if(ImGui::GetIO().ConfigFlags & ImGuiConfigFlags_ViewportsEnable){
		ImGui::UpdatePlatformWindows();
		ImGui::RenderPlatformWindowsDefault();
	}
}

-(void)_drawImGui{
	//render ImGui things here,it's really clear!!
	ImGui::Begin("MEL Engine - Metal Implementation");
	ImGui::Text("Hello, Metal! This is your engine");
	
	ImGui::Text("Application average %.3f ms/frame (%.1f FPS)",1000.0f/ImGui::GetIO().Framerate,ImGui::GetIO().Framerate);
	
	ImGui::ShowDemoWindow();
	
	ImGui::End();
}

-(void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
	_viewportSize.x=(uint32_t)size.width;
	_viewportSize.y=(uint32_t)size.height;
}

-(void)cleanup{
	ImGui_ImplOSX_Shutdown();
	ImGui_ImplMetal_Shutdown();
	ImGui::DestroyContext();
}

@end
#pragma mark - TODO:
//I'll add multi-window later,not now. :P

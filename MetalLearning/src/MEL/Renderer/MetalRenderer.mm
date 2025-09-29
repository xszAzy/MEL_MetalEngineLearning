#import "MetalRenderer.h"

@implementation MetalRenderer{
	id<MTLDevice> _device;
	id<MTLRenderPipelineState> _pipelineState;
	id<MTLCommandQueue> _commandQueue;
	vector_uint2 _viewportSize;
}

-(nonnull instancetype)initWithMetalKitView:(MTKView *)mtkView{
	self=[super init];
	if(self){
		_device=mtkView.device;
		[self _setupPipeline];
		_commandQueue=[_device newCommandQueue];
		
		_viewportSize=(vector_uint2)
		{
			(uint32_t)mtkView.drawableSize.width,
			(uint32_t)mtkView.drawableSize.height
		};
	}
	return self;
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
	
	//renderPassDescriptor.colorAttachments[0].clearColor=MTLClearColorMake(0.1, 0.1, 0.1, 1.0);
	
	id<MTLRenderCommandEncoder> renderEncoder=[commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
	renderEncoder.label=@"MyRenderEncoder";
	
	[renderEncoder setRenderPipelineState:_pipelineState];
	
	[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
					  vertexStart:0
					  vertexCount:3];
	
	[renderEncoder endEncoding];
	[commandBuffer presentDrawable:view.currentDrawable];
	[commandBuffer commit];
}

-(void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
	_viewportSize.x=(uint32_t)size.width;
	_viewportSize.y=(uint32_t)size.height;
}

@end

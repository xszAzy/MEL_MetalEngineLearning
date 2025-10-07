#import "ViewController.h"

@interface ViewController()

@property (nonatomic,strong)MTKView* metalView;

@end;

@implementation ViewController

-(void)viewDidLoad{
	[super viewDidLoad];

	self.metalView=[[MTKView alloc] initWithFrame:self.view.bounds];
	self.metalView.device=MTLCreateSystemDefaultDevice();
	self.metalView.clearColor=MTLClearColorMake(0.1, 0.1, 0.1, 1.0);
	self.metalView.colorPixelFormat=MTLPixelFormatBGRA8Unorm;
	
	self.metalView.enableSetNeedsDisplay=NO;
	self.metalView.paused=NO;
	self.metalView.preferredFramesPerSecond=60;
	
	[self.view addSubview:self.metalView];
}

-(void)viewDidLayout{
	[super viewDidLayout];
	self.metalView.frame=self.view.bounds;
}

-(void)loadView{
	self.view=[[NSView alloc] init];
	self.view.wantsLayer=YES;
}

-(void)viewWillDisappear{
	[super viewWillDisappear];

}

-(void)viewDidAppear{
	[super viewDidAppear];
}
/*
#pragma mark - MTKViewDelegate

-(void)drawInMTKView:(MTKView *)view{
	
}

-(void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
	auto renderer=
}
*/
-(MTKView*)getMetalView{
	return self.metalView;
}

@end

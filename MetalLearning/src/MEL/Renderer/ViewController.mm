#import "ViewController.h"
#import "MetalRenderer.h"

@interface ViewController()

@property (nonatomic,strong)MTKView* metalView;
@property (nonatomic,strong)MetalRenderer* renderer;
@property (nonatomic,strong)id<MTLCommandQueue> commandQueue;

@end;

@implementation ViewController

-(void)viewDidLoad{
	[super viewDidLoad];
	
	self.metalView=[[MTKView alloc] initWithFrame:self.view.bounds];
	self.metalView.device=MTLCreateSystemDefaultDevice();
	self.metalView.clearColor=MTLClearColorMake(0.1, 0.1, 0.1, 1.0);
	self.metalView.colorPixelFormat=MTLPixelFormatBGRA8Unorm;
	
	[self.view addSubview:self.metalView];
	
	self.renderer=[[MetalRenderer alloc] initWithMetalKitView:self.metalView];
	
	[self.renderer setupImGui];
	
	self.metalView.delegate=self.renderer;
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
	[self.renderer cleanup];
}

@end

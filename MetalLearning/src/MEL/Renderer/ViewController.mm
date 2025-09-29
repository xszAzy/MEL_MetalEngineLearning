#import "ViewController.h"
#import "MetalRenderer.h"

@interface ViewController()

@property (nonatomic,strong)MTKView* metalView;
@property (nonatomic,strong)MetalRenderer* renderer;

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
	self.metalView.delegate=self.renderer;
}

-(void)viewDidLayout{
	[super viewDidLayout];
	self.metalView.frame=self.view.bounds;
}

@end

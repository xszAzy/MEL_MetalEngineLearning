#import "melpch.h"

@interface MetalRenderer:NSObject<MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:
(nonnull MTKView*)mtkView;

-(void)setupImGui;
-(void)cleanup;

@property (readonly)uint64_t windowID;

@end

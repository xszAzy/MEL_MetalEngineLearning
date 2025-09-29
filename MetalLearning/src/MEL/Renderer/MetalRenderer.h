#import "melpch.h"

@interface MetalRenderer:NSObject<MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:
(nonnull MTKView*)mtkView;

@end

#import "melpch.h"
namespace MEL{
	class Application;
}

@interface MELMTKViewDelegate : NSObject<MTKViewDelegate>

-(instancetype)initWithApplication:
(MEL::Application*)application;

@end
@interface AppDelegate : NSObject<NSApplicationDelegate>

@end

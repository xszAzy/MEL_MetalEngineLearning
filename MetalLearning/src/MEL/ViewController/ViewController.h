#import "melpch.h"

@interface ViewController : NSViewController

@property (nonatomic,strong,readonly)MTKView* metalView;

-(MTKView*)getMetalView;

@end

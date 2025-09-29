#import <Cocoa/Cocoa.h>

@class ViewController;

@interface WindowManager:NSObject

@property (nonatomic,strong,readonly)NSWindow* window;
@property (nonatomic,strong,readonly)ViewController* viewController;

-(instancetype)initWithFrame:
(NSRect)frame title:(NSString*)title;
-(void)show;

@end

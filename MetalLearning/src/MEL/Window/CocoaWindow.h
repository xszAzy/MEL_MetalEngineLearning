#pragma once

#import <Cocoa/Cocoa.h>
namespace MEL {
	class Event;
}
typedef void (^MELEventCallback)(MEL::Event& event);

@interface CocoaWindow :NSWindow<NSWindowDelegate>

@property (nonatomic,copy)MELEventCallback eventCallback;

-(instancetype)initWithFrame:
(NSRect)frame styleMask:(NSWindowStyleMask)styleMask title:(NSString*)title;

-(void)dispatchEvent:
(MEL::Event&)event;

@end

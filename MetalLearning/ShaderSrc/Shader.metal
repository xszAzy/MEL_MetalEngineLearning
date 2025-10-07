#include <metal_stdlib>
using namespace metal;

struct VertexIn {
	float3 position [[attribute(0)]];
	float3 color [[attribute(1)]];
};

struct VertexOut{
	float4 position [[position]];
	float4 color;
};

vertex VertexOut vertexShader(const VertexIn in [[stage_in]]){
	VertexOut out;
	out.position=float4(in.position,1.0);
	out.color=float4(in.color,1.0);
	return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]){
	return in.color;
}


#include <metal_stdlib>
using namespace metal;

struct VertexIn {
	float3 position [[attribute(0)]];
	float4 color [[attribute(1)]];
};

struct CameraData{
	float4x4 viewProjectionMatrix;
	float3 cameraPosition;
	float padding;
};

struct VertexOut{
	float4 position [[position]];
	float4 color;
};

vertex VertexOut vertexShader(const VertexIn in [[stage_in]],constant CameraData& cameraData [[buffer(1)]]){
	VertexOut out;
	out.position=cameraData.viewProjectionMatrix*float4(in.position,1.0);
	out.color=in.color;
	return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]){
	return in.color;
}


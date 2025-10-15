#include <metal_stdlib>
using namespace metal;

struct VertexIn {
	float3 position [[attribute(0)]];
	float4 color [[attribute(1)]];
};

struct TransformData{
	float4x4 modelMatrix;
	float4 color;
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

vertex VertexOut vertexShader(const VertexIn in [[stage_in]],
							  constant CameraData& cameraData [[buffer(1)]],
							  constant TransformData& transformData [[buffer(2)]]){
	VertexOut out;
	float4 worldPosition=transformData.modelMatrix*float4(in.position,1.0);
	out.position=cameraData.viewProjectionMatrix*worldPosition;
	
	out.color=transformData.color;
	return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]){
	return in.color;
}


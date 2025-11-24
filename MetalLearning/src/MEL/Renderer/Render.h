#pragma once
#include "MEL.h"
#include "GameObject.h"

namespace MEL {
	class Render{
	public:
		Render(Renderer* renderer);
		
		static void SetCamera(CameraController cameraController);
		static Ref<VertexArray> CreateVA(void* data,uint32_t dataSize,
										 uint32_t* indices,uint32_t indicesSize,
										 const BufferLayout& layout);
		static void UpdateCamera(Timestep ts);
		static void Draw(std::vector<Ref<GameObject>> gameObjects,int loc,float color[4],
						 const std::string shaderName,bool isTransform,bool isTexture);
		
		static void LoadShaderFromFile(const std::string &name, const std::string &filepath,
								NSString *vertexFuncName, NSString *fragmentFuncName,
								const BufferLayout& layout,BlendType blendType=BlendType::Opaque);
		static void LoadShaderFromSource(const std::string &name, const std::string &source,
								  NSString *vertexFuncName, NSString *fragmentFuncName,
								  const BufferLayout& layout,BlendType blendType=BlendType::Opaque);
		
	private:
		static Renderer* s_Renderer;
		static CameraController s_CameraController;
	};
}

#pragma once
#import "Buffer/VertexBuffer.h"
#import "Buffer/IndexBuffer.h"
#import "Buffer/UniformBuffer.h"
#import "Buffer/BufferLayout.h"

#include "Renderer.h"
#include "Shader.h"
#include "MacInput.h"

#import "Transforms/Camera.h"
#import "Transforms/Transform.h"

#import "VertexArray/VertexArray.h"
namespace MEL{
	class RenderCommand{
	public:
		static void Init(Renderer* renderer);
		static void BeginFrame();
		static void BeginScene(const std::shared_ptr<Camera> &camera);
		
		static void Submit(const std::shared_ptr<Shader>& shader,
						   const std::shared_ptr<VertexArray>& vertexArray);
		
		static void EndScene();
		static void EndFrame();
	private:
		static Renderer* s_Renderer;
		static std::shared_ptr<Camera> s_CurrentCamera;
	};
}

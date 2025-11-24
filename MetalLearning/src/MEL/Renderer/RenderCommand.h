#pragma once
#include "MEL.h"

#import "Buffer/BufferLayout.h"

namespace MEL{
	class VertexArray;
	class RenderCommand{
	public:
		static void Init(Renderer* renderer);
		static void BeginFrame();
		static void BeginScene(const Ref<Camera> &camera);
		
		static void Submit(const Ref<Shader>& shader,
						   const Ref<VertexArray>& vertexArray);
		
		static void EndScene();
		static void EndFrame();
	private:
		static Renderer* s_Renderer;
		static Ref<Camera> s_CurrentCamera;
	};
}

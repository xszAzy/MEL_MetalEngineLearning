#include "Render.h"

namespace MEL{
	Renderer* Render::s_Renderer=nullptr;
	CameraController Render::s_CameraController;
	Render::Render(Renderer* renderer){
		s_Renderer=renderer;
	}
	
	void Render::SetCamera(CameraController cameraController){
		s_CameraController=cameraController;
		s_Renderer->SetSceneCamera(s_CameraController.GetCamera());
	}
	
	Ref<VertexArray> Render::CreateVA(void* data, uint32_t dataSize,
									  uint32_t* indices, uint32_t indicesSize,
									  const BufferLayout& layout){
		auto va=VertexArray::Create();
		auto VB=VertexBuffer::Create(data, dataSize);
		auto IB=IndexBuffer::Create(indices, indicesSize);
		
		VB->SetSlot(0);
		VB->SetLayout(layout);
		
		va->AddVertexBuffer(VB);
		va->SetIndexBuffer(IB);
		
		return va;
	}
	
	void Render::UpdateCamera(Timestep ts){
		s_CameraController.OnUpdate(ts);
		s_Renderer->UpdateCameraUniform();
	}
	
	void Render::Draw(std::vector<Ref<GameObject>> gameObjects, int loc, float *color,
					  const std::string shaderName, bool isTransform,bool isTexture){
		if(isTransform)
			gameObjects[loc]->BindTransform();
		if(isTexture)
			gameObjects[loc]->BindTexture();
		
		gameObjects[loc]->SetColor(color);
		
		RenderCommand::Submit(s_Renderer->GetShaderLibrary().Get(shaderName), gameObjects[loc]->GetVertexArray());
	}
	
	void Render::LoadShaderFromFile(const std::string &name, const std::string &filepath,
									NSString *vertexFuncName, NSString *fragmentFuncName,
									const BufferLayout& layout,BlendType blendType){
		s_Renderer->GetShaderLibrary().LoadFromFile(name, filepath, vertexFuncName, fragmentFuncName, layout,blendType);
	}
	
	void Render::LoadShaderFromSource(const std::string &name, const std::string &source,
									  NSString *vertexFuncName, NSString *fragmentFuncName,
									  const BufferLayout& layout,BlendType blendType){
		s_Renderer->GetShaderLibrary().LoadFromSource(name, source, vertexFuncName, fragmentFuncName, layout,blendType);
	}
}

#include "RenderCommand.h"
namespace MEL{
	Renderer* RenderCommand::s_Renderer=nullptr;
	Ref<Camera> RenderCommand::s_CurrentCamera=nullptr;
	void RenderCommand::Init(Renderer *renderer){
		s_Renderer=renderer;
	}
	
	void RenderCommand::BeginFrame(){
		s_Renderer->BeginFrame();
	}
	void RenderCommand::BeginScene(const Ref<Camera> &camera){
		s_CurrentCamera=camera;
		s_Renderer->BeginScene();
		
		if(s_Renderer->GetCameraUniform()){
			struct CameraData{
				simd::float4x4 viewProjection;
				simd::float3 position;
			} cameradata;
			
			cameradata.viewProjection=camera->GetViewProjectionMatrix();
			cameradata.position=camera->GetPosition();
			
			s_Renderer->GetCameraUniform()->SetData(&cameradata, sizeof(cameradata));
		}
	}
	
	void RenderCommand::Submit(const Ref<Shader> &shader, const Ref<VertexArray> &vertexArray){
		shader->Bind();
		if(s_Renderer->GetCameraUniform()){
			s_Renderer->GetCameraUniform()->Bind();
		}
		vertexArray->Bind();
		s_Renderer->DrawIndexed(vertexArray);
	}
	
	void RenderCommand::EndScene(){
		s_Renderer->EndScene();
	}
	
	void RenderCommand::EndFrame(){
		s_Renderer->EndFrame();
	}
}

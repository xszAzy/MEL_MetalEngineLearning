#include "MEL.h"
#include "imgui.h"
#include <stdio.h>
#include "MacInput.h"

#import "Buffer/VertexBuffer.h"
#import "Buffer/IndexBuffer.h"
#import "Buffer/UniformBuffer.h"
#import "Buffer/BufferLayout.h"
#import "VertexArray/VertexArray.h"

#include "RenderCommand.h"
#include "Core/Timestep.h"


class ExampleLayer:public MEL::Layer{
public:
	ExampleLayer()
	:Layer("Example"){
		
	}
	void OnImGuiRender()override{
		ImGui::Begin("MEL Engine - Metal Implementation");
		ImGui::Text("Hello, Metal! This is your engine");
		
		ImGui::Text("Application average %.3f ms/frame (%.1f FPS)",1000.0f/ImGui::GetIO().Framerate,ImGui::GetIO().Framerate);
		static bool show=0;
		if(show)
			ImGui::ShowDemoWindow(&show);
		
		ImGui::End();
	}
	
	void OnUpdate(MEL::Timestep ts) override{
		//MEL_INFO("testing update");
		//set camera
		auto camera=m_Renderer->GetSceneCamera();
		simd::float3 position=camera->GetPosition();
		float moveSpeed=1.0f;
		float rotateSpeed=1.0f;
		
		if(MEL::MacInput::IsKeyPressed(MEL::Key::W)){
			if(camera){
				position.z-=moveSpeed*ts*2.0f;
				MEL_INFO("Set Camera to position {:.2f},{:.2f},{:.2f}",
						 (float)position[0],(float)position[1],(float)position[2]);
			}
		}
		else if (MEL::MacInput::IsKeyPressed(MEL::Key::S)){
			if(camera){
				position.z+=moveSpeed*ts*2.0f;
				MEL_INFO("Set Camera to position {:.2f},{:.2f},{:.2f}",
						 (float)position[0],(float)position[1],(float)position[2]);
			}
		}
		
		if(MEL::MacInput::IsKeyPressed(MEL::Key::A)){
			if(camera){
				camera->RotateRoll(-rotateSpeed*ts);
			}
		}
		else if(MEL::MacInput::IsKeyPressed(MEL::Key::D)){
			if(camera){
				camera->RotateRoll(rotateSpeed*ts);
			}
		}
		
		if(MEL::MacInput::IsKeyPressed(MEL::Key::J)){
			if(camera){
				camera->RotateYaw(-rotateSpeed*ts);
			}
		}
		else if(MEL::MacInput::IsKeyPressed(MEL::Key::L)){
			if(camera){
				camera->RotateYaw(rotateSpeed*ts);
			}
		}
		
		if(MEL::MacInput::IsKeyPressed(MEL::Key::I)){
			if(camera){
				camera->RotatePitch(-rotateSpeed*ts);
			}
		}
		else if(MEL::MacInput::IsKeyPressed(MEL::Key::K)){
			if(camera){
				camera->RotatePitch(rotateSpeed*ts);
			}
		}
		
		if(MEL::MacInput::IsKeyPressed(MEL::Key::Left)){
			if(camera){
				position-=camera->GetRight()*(moveSpeed*ts);
				MEL_INFO("Set Camera to position {:.2f},{:.2f},{:.2f}",
						 (float)position[0],(float)position[1],(float)position[2]);
			}
		}
		else if (MEL::MacInput::IsKeyPressed(MEL::Key::Right)){
			if(camera){
				position+=camera->GetRight()*(moveSpeed*ts);
				MEL_INFO("Set Camera to position {:.2f},{:.2f},{:.2f}",
						 (float)position[0],(float)position[1],(float)position[2]);
			}
		}
		
		if(MEL::MacInput::IsKeyPressed(MEL::Key::Up)){
			if(camera){
				position+=camera->GetUp()*(moveSpeed*ts);
				MEL_INFO("Set Camera to position {:.2f},{:.2f},{:.2f}",
						 (float)position[0],(float)position[1],(float)position[2]);
			}
		}
		else if (MEL::MacInput::IsKeyPressed(MEL::Key::Down)){
			if(camera){
				position-=camera->GetUp()*(moveSpeed*ts);
				MEL_INFO("Set Camera to position {:.2f},{:.2f},{:.2f}",
						 (float)position[0],(float)position[1],(float)position[2]);
			}
		}
		camera->SetPosition(position);
		m_Renderer->UpdateCameraUniform();
		
		//draw
		
		MEL::RenderCommand::Submit(m_CurrentShader, m_VertexArray);
		MEL::RenderCommand::Submit(m_CurrentShader, m_TriangleVA);
	}
	
	void OnAttach() override{
		
		m_Renderer=MEL::Application::Get().GetRenderer();
		
		//shadersource
		/*
		const char* ShaderSource=R"(
  #include <metal_stdlib>
  using namespace metal;
  
  struct VertexIn{
  float3 position[[attribute(0)]];
  float4 color[[attribute(1)]];
  };
  
  struct VertexOut{
  float4 position[[position]];
  float4 color;
  };
  
  vertex VertexOut vertexMain(const VertexIn in [[stage_in]]){
  VertexOut out;
  out.position=float4(in.position,1.0);
  out.color=in.color;
  return out;
  }
  
  fragment float4 fragmentMain(VertexOut in [[stage_in]]){
  return in.color;
  }
  )";
		 */
		m_VertexArray=MEL::VertexArray::Create();
		//set buffers
		struct Vertex{
			float position[3];
			float color[4];
		};
		
		auto camera=std::make_shared<MEL::Camera>();
		//*camera=MEL::Camera::CreateOrthographic(-1.0f, 1.0f, -1.0f, 1.0f, 0.1f, 100.f);
		*camera=MEL::Camera::CreatePerspective(60.0f, 16.0f/9.0f, 0.1f, 100.0f);
		camera->SetPosition({0.0f,0.0f,3.0f});
		//camera->LookAt({.0f,.0f,.0f});
		
		m_Renderer->SetSceneCamera(camera);
		
		Vertex SquareVertices[]={
			{{-0.5f,-0.5f,0.0f},
				{0.4f,0.2f,0.4f,1.0f}},
			
			{{0.5f,-0.5f,0.0f},
				{0.1f,0.7f,0.1f,1.0f}},
			
			{{0.5f,0.5f,0.0f},
				{0.1f,0.3f,0.4f,1.0f}},
			
			{{-0.5f,0.5f,0.0f},
				{0.2f,0.3f,0.1f,1.0f}}
		};
		
		uint32_t SquareIndices[]={0,1,2,
			2,3,0};
		
		//create bufferlayout
		MEL::BufferLayout layout={
			{MEL::ShaderDataType::Float3,"a_Position"},
			{MEL::ShaderDataType::Float4,"a_Color"}
		};
		
		//Set buffers
		auto SquareVB=MEL::VertexBuffer::Create(SquareVertices, sizeof(SquareVertices));
		auto SquareIB=MEL::IndexBuffer::Create(SquareIndices, 6);
		SquareVB->SetSlot(0);
		SquareVB->SetLayout(layout);
		
		m_VertexArray->AddVertexBuffer(SquareVB);
		m_VertexArray->SetIndexBuffer(SquareIB);
		
		//Set another source
		
		m_TriangleVA=MEL::VertexArray::Create();
		
		Vertex TriVertices[]={
			{{-0.5f,-0.5f,0.0f},
				{0.8f,0.2f,0.4f,1.0f}},
			
			{{0.5f,-0.5f,0.0f},
				{0.1f,0.7f,0.1f,1.0f}},
			
			{{0.0f,0.5f,0.0f},
				{0.0f,0.2f,0.8f,1.0f}}
		};
		
		uint32_t TriIndices[]={0,1,2};
		
		auto TriVB=MEL::VertexBuffer::Create(TriVertices, sizeof(TriVertices));
		auto TriIB=MEL::IndexBuffer::Create(TriIndices, 3);
		TriVB->SetSlot(0);
		TriVB->SetLayout(layout);
		
		m_TriangleVA->AddVertexBuffer(TriVB);
		m_TriangleVA->SetIndexBuffer(TriIB);
		
		//create shader(this can be done in sandbox)
		auto defaultShader=MEL::Shader::CreateFromDefaultLibrary("DefaultShader", @"vertexShader", @"fragmentShader");
		if(defaultShader)
			defaultShader->CreatePipelineState(layout);
		
		m_CurrentShader=defaultShader;
		
	}
	
	void OnEvent(MEL::Event& e) override{
		MEL_INFO("testing event{0}",e.ToString());
	}
	
private:
	std::shared_ptr<MEL::Shader> m_CurrentShader;
	MEL::Renderer* m_Renderer;
	std::shared_ptr<MEL::VertexArray> m_VertexArray;
	std::shared_ptr<MEL::VertexArray> m_TriangleVA;
};

class Sandbox:public MEL::Application{
public:
	Sandbox(){
		PushLayer(new ExampleLayer());
		
	}
	~Sandbox(){
		
	}
private:
	
};

MEL::Application* MEL::CreateApplication(){
	return new Sandbox();
}

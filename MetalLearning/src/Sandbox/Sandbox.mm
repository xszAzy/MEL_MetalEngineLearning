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

#include "GameObject.h"

class ExampleLayer:public MEL::Layer{
public:
	ExampleLayer()
	:Layer("Example"){
		
	}
	void OnImGuiRender()override{
		ImGui::Begin("MEL Engine - Metal Implementation");
		ImGui::Text("Hello, Metal! This is your engine");
		
		ImGui::Text("Application average %.3f ms/frame (%.1f FPS)",1000.0f/ImGui::GetIO().Framerate,ImGui::GetIO().Framerate);
		ImGui::ColorEdit3("Triangle Color", m_TriColor);
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
#pragma mark - move controll
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
#pragma mark - other sets
		camera->SetPosition(position);
		m_Renderer->UpdateCameraUniform();
			
		for(size_t i=0;i<m_GameObjects.size();i++){
			auto& obj=m_GameObjects[i];
			//other settings
			if(i==1){
				obj->SetColor({m_TriColor[0],m_TriColor[1],m_TriColor[2]});
			}
			//bind transform
			obj->BindTransform();
			MEL::RenderCommand::Submit(m_CurrentShader, obj->GetVertexArray());
		}
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
#pragma mark - Set source
		//set camera
		auto camera=std::make_shared<MEL::Camera>();
		//*camera=MEL::Camera::CreateOrthographic(-1.0f, 1.0f, -1.0f, 1.0f, 0.1f, 100.f);
		*camera=MEL::Camera::CreatePerspective(60.0f, 16.0f/9.0f, 0.1f, 100.0f);
		camera->SetPosition({0.0f,0.0f,3.0f});
		camera->LookAt({.0f,.0f,.0f});
		
		m_Renderer->SetSceneCamera(camera);

		CreateObjects();
		//create shader(this can be done in sandbox)
		auto defaultShader=MEL::Shader::CreateFromDefaultLibrary("DefaultShader", @"vertexShader", @"fragmentShader");
		if(defaultShader)
			defaultShader->CreatePipelineState(m_Layout);
		
		m_CurrentShader=defaultShader;
		
	}
	
	void OnEvent(MEL::Event& e) override{
		MEL_INFO("testing event{0}",e.ToString());
	}
#pragma mark - Create objects
public:
	void CreateObjects(){
		//create square
		auto squareObject=std::make_shared<MEL::GameObject>("Square");
		squareObject->SetVertexArray(CreateSquareVA());
		squareObject->GetTransform().SetPosition({-1.0f,-1.0f,0.0f});
		squareObject->GetTransform().SetScale({0.1f,0.1f,0.1f});
		squareObject->SetColor({1,0,0});
		
		m_GameObjects.push_back(squareObject);
		//create triangle
		auto triangleObject=std::make_shared<MEL::GameObject>("Triangle");
		triangleObject->SetVertexArray(CreateTriVA());
		triangleObject->GetTransform().SetPosition({0,0,0});
		triangleObject->SetColor({m_TriColor[0],m_TriColor[1],m_TriColor[2]});
		
		m_GameObjects.push_back(triangleObject);
		//create extra
		for(size_t i=0;i<21;i++){
			for(size_t j=0;j<20;j++){
				auto extraObject=std::make_shared<MEL::GameObject>("extra");
				extraObject->SetVertexArray(CreateSquareVA());
				extraObject->GetTransform().SetScale({0.1f,0.1f,0.1f});
				extraObject->GetTransform().SetPosition({0.11f*i,0.11f*j,0});
				extraObject->SetColor({.0f,.0f,1.0f});
				
				m_GameObjects.push_back(extraObject);
			}
		}
	}
#pragma mark - private objects
private:
	std::shared_ptr<MEL::VertexArray> CreateSquareVA(){
		//set vertex layout
		struct Vertex{
			float position[3];
			float color[4];
		};
		//set layout
		MEL::BufferLayout layout={
			{MEL::ShaderDataType::Float3,"a_Position"},
			{MEL::ShaderDataType::Float4,"a_Color"}
		};
		
		auto va=MEL::VertexArray::Create();
		//set data
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
		//Set buffers
		auto SquareVB=MEL::VertexBuffer::Create(SquareVertices, sizeof(SquareVertices));
		auto SquareIB=MEL::IndexBuffer::Create(SquareIndices, 6);
		SquareVB->SetSlot(0);
		SquareVB->SetLayout(layout);
		
		va->AddVertexBuffer(SquareVB);
		va->SetIndexBuffer(SquareIB);
		return va;
	}
	
	std::shared_ptr<MEL::VertexArray> CreateTriVA(){
		//set vertex layout
		struct Vertex{
			float position[3];
			float color[4];
		};
		//set layout
		MEL::BufferLayout layout={
			{MEL::ShaderDataType::Float3,"a_Position"},
			{MEL::ShaderDataType::Float4,"a_Color"}
		};
		
		auto va=MEL::VertexArray::Create();
		
		Vertex TriVertices[]={
			{{-0.5f,-0.5f,0.0f},
				{0.8f,0.2f,0.4f,1.0f}},
			
			{{0.5f,-0.5f,0.0f},
				{0.1f,0.7f,0.1f,1.0f}},
			
			{{0.0f,0.5f,0.0f},
				{0.0f,0.2f,0.8f,1.0f}}
		};
		
		uint32_t TriIndices[]={0,1,2};
		//set buffers
		auto TriVB=MEL::VertexBuffer::Create(TriVertices, sizeof(TriVertices));
		auto TriIB=MEL::IndexBuffer::Create(TriIndices, 3);
		TriVB->SetSlot(0);
		TriVB->SetLayout(layout);
		
		va->AddVertexBuffer(TriVB);
		va->SetIndexBuffer(TriIB);
		return va;
	}
	
private:
	MEL::Renderer* m_Renderer;
	
	std::vector<std::shared_ptr<MEL::GameObject>> m_GameObjects;
	std::shared_ptr<MEL::Shader> m_CurrentShader;
	MEL::BufferLayout m_Layout={
		{MEL::ShaderDataType::Float3,"a_Position"},
		{MEL::ShaderDataType::Float4,"a_Color"}
	};
	
	float m_TriColor[4]={0.2,0.3,0.6,1.0};
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
